---
supertitle: Dropbox Express with ECMAScript 6+
subtitle: "Part 7: Promises."
title: "Dropbox Express 7: Promises."
date: 2015-06-13 23:16 UTC
tags: dropbox, node.js, es.next, promises, refactoring 
---

*This is how I built a simple server-side JavaScript app on top of the
Dropbox API, using Express.js, ECMAScript 6 (and one thing I hope will
be in ES 7), and Zombie.js for testing. It was my first time using any
of these things (except JavaScript, natch), so there are probably
better ways to do some of it. [Let me know!][contact]*

In [part 6], we expanded our use of the Dropbox API, and saw our code
become more complex. Let's try to simplify it, using ECMAScript 6's
Promises.
READMORE

## Promises.

Promises have been implemented by various libraries for a while,
but ES6 makes them a standard part of the language. They provide
a way to call functions asynchronously. What a `Promise`
promises is that either a value will be passed to a callback at
some point, or an error will be passed to a different callback.

It's easier shown than told, so let's look at an example. In [part 4],
we read the contents of a Dropbox folder by passing a callback function
to a Dropbox API method. Here's a simplified version.

~~~
client.readdir('/', (error, entries) => {
  if (error) {
    return res.send(error.response.error);
  }

  res.send(`Files found: ${entries.length}`);
});
~~~
{: .lang-javascript}

In the Dropbox API, a single callback handles both success and failure.
With Promises, we separate these into two functions:

~~~
client.readdir('/')
  .then((entries) => {
    res.send(`Files found: ${entries.length}`);
  })
  .catch((error) => {
    return res.send(error.response.error);
  });
~~~
{: .lang-javascript}

This code isn't necessarily shorter, but it it's a bit easier to follow:
Read the directory, `then` display the result. We handle the error case
at the end, which is an advantage especially when we need to deal with
errors from multiple promises.

## A Promise wrapper.

We'd like to write our application code in this form, but we can't,
because the Dropbox API doesn't return Promises. To get around this,
we can introduce Promises as an intermediary between Dropbox and our
application code.
 
Given a function like Dropbox's `readdir`, which takes a path and a
callback, here's one way to turn it into a promise:

~~~
let readdirWrapped = function(path) {
  // Instantiate a Promise that takes a `resolve` and a `reject` callback.
  return new Promise((resolve, reject) => {
    // Call Dropbox's readdir method with a callback....
    client.readdir(path, (dirError, entries, dirstat, filestats) => {
      // If there's an error, call the `reject` callback and exit.
      if (error) {
        return reject(error);
      }
      
      // Otherwise, call the `resolve` callback.  
      resolve([entries, dirstat, filestats]);
    });
};
~~~
{: .lang-javascript}

This is how we create a `Promise`: pass it a function that takes
two functions, `resolve` and `reject`, as parameters. (These functions
will be created by the `Promise` object.) If our code completes
successfully, we call `resolve` with a return value. If there's
a problem, we call `reject` with an error.

Note that `resolve` takes only one parameter. If we want to provide
more than one result (as Dropbox does when it passes `entries`,
`dirstat`, and `filestats` to the callback), we have to marshall
them into a single value (which we do here by joining them in an
array).

## A wrapper class.

We want to wrap two Dropbox method in promises for our app. We could
define `readdirWrapped` and `readFileWrapped` as above, but all that
repeated code would obscure the differences between them, and in a
real app we'd probably want to wrap more than two methods, so it would
keep getting worse. Instead, we can put the Promise logic in a single
reusable function, and use ECMAScript 6's [`class`][class] syntax to
provide a single access point for all our wrapped methods.  Put this
in a file called `promisebox.js`:

~~~
/**
 * Wraps a Dropbox API Client in promises.
 */

class Promisebox {
  constructor (client) {
    this.client = client;
  }

  readdir (path, options) {
    return this._promise('readdir', path, options);
  }

  readFile (path, options) {
    return this._promise('readFile', path, options);
  }

  _promise (method, ...params) {
    return new Promise((resolve, reject) => {
      this.client[method](...params, (error, ...results) => {
        if (error) {
          // If there's an error, call `reject` and exit.
          return reject(error);
        }
        resolve(results);
      });
    });
  }
}

module.exports = Promisebox;
~~~
{: .lang-javascript}

The `class` keyword doesn't define a class of the sort found in other
languages like Ruby and Java. It's just syntax for creating a constructor
and its prototype, like we've always done in JavaScript. Here we define:

  * a constructor that stores a Dropbox API client on the object
  * a pseudo-private `_promise` method that returns a `Promise` that
    calls a method on the Dropbox client
  * `readdir` and `readFile` methods that are named wrappers around
    `_promise`

(ES6 classes don't have truly private methods. There are ways to achieve
the same result, but here, I'm just using a common convention: Don't call
a method that starts with an underscore from outside the object.) 

As we discussed earlier, Dropbox's `readdir` method passes three results
to its callback, but we can only pass one value to `resolve`. We handle
this using the ES6 [spread operator]. Our callback function has the
parameters `(error, ...results)`. This means that the first parameter
is assigned to the local variable `error`, and *all subsequent parameters*
are collected into an array and assigned to `results`.

Similarly, our `_promise` function takes a `method` name and any number of
`... params`. When it calls `this.client[method](...params)`, each element
 of the `params` array is passed *as a separate parameter* to the underlying
 Dropbox method.

## The app, with promises.

Given this class, we can rewrite `app.js` to load the module,
wrap our Dropbox client in a `Promisebox`, and call its methods in sequence
(seemingly):

~~~
const express = require('express'),
  Dropbox = require('dropbox'),
  Promisebox = require('./promisebox');

// Initialize a Dropbox client.
let client = new Dropbox.Client({
  // Get auth token from `.env` or environment variables.
  token: process.env.DROPBOX_AUTH_TOKEN
});
// Wrap it in a Promisebox.
client = new Promisebox(client);

// Create an Express application.
const app = express();

// When a browser requests `/`, display the latest file from the
// Dropbox folder.
app.get('/', (req, res) => {
  // Ask Dropbox for a promise to list files in the app folder.
  client.readdir('/')
    // When the promise is fulfilled...
    .then(([entries, dirstat, filestats]) => {
      // Return a Dropbox promise to read the contents of the file.
      return client.readFile(latestPath(filestats));
    })
    // When the second promise is fulfilled...
    .then(([contents]) => {
      // Display the file contents to the user.
      res.send(contents);
    })
    // If something goes wrong...
    .catch((error) => {
      // Display the error message to the user.
      return res.send(error.response.error);
    });
});

const latestPath = (filestats) => {
  // Ignore files without dates in their names.
  const datedFiles = filestats.filter(e => /^[0-9-]*\.html$/.test(e.name));
  // Get the last one.
  const latest = datedFiles.sort()[datedFiles.length - 1];

  return latest.path;
};

module.exports = app;
~~~
{: .lang-javascript}

Again, the code is presented in a more sequential way, with the "happy
path" presented first, and error handling at the end. Some things to
note here:

1. If the first promise fails, the `then` callbacks aren't executed,
   and instead control flows to the `catch` callback at the end. That allows
   us to use a single callback for both failure cases. 

2. If the first promise succeeds, its `then` callback returns another
   promise (returned by `client.readFile`). This promise, on success,
   automatically flows to the second `then` callback.

3. As we discussed, the `resolve` method only lets us pass one parameter
   along to our `then` callback. In `Promisebox`, we combined `readdir`'s
   `entries`, `dirstat`, and `filestats` into a single array. Here, we
   use ES6's `array destructuring` syntax to automatically assign them
   to distinct variables.
   
(I've also moved the "search through filestats for the latest entry's
path" code to a separate function, so we can focus on the asynchronous
logic in the URL handler.)

This new version of the URL handler is almost exactly the same length,
but it is a little easier to follow from top to bottom. It's still a lot
of "functions passing functions to functions," though. We can do better.
In part 8, we'll use generators to strip away some of the noise.

[contact]: #comments
[part 4]: /2015/05/25/dropbox-express-4-dropbox-at-last.html
[part 6]: /2015/05/30/dropbox-express-6-double-dropbox.html
[spread operator]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_operator

[array destructuring]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment
[class]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/class
