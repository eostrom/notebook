---
supertitle: Dropbox Express with ECMAScript 6+
subtitle: "Part 3: The Simplest App."
title: "Dropbox Express 3: The App."
date: 2015-05-24 17:51 UTC
tags: node.js, express.js, es.next, babel
---

*This is how I built a simple server-side JavaScript app on top of the
Dropbox API, using Express.js, ECMAScript 6 (and one thing I hope will
be in ES 7), and Zombie.js for testing. It was my first time using any
of these things (except JavaScript, natch), so there are probably
better ways to do some of it. [Let me know!][contact]*

In [part 2], we wrote an acceptance test for the simplest app I could
think of, but then we didn't write the app! What is wrong with us! Here,
we'll rectify that injustice.

READMORE

## The simplest app. 

Create a file in the root of your project folder called `app.js`:

~~~
const express = require('express');

// Create an Express application.
const app = express();

// When a browser requests `/`, respond with some hard-coded text.
app.get('/', (req, res) => {
  res.send('Hello!');
});

module.exports = app;
~~~

Run `npm test`. Voila! Our tests pass! Turn off the lights on your
way out! Oh wait, one more thing: let's make the app actually run in
a server, so we can look at it in a browser.

## The server.

Let's add a second script to `package.json`:

~~~
  "scripts": {
    "start": "node index.js",
    "test": "./node_modules/.bin/mocha --harmony --compilers js:babel/register"
  },
~~~
{: .language-json}

When we run `npm start`, Node will load `index.js`, so let's create it:

~~~
require('babel/register');
require('./server');
~~~

This is just a simple wrapper that loads the Babel compiler, so we can
use ES6, and loads `server.js`:

~~~
const app = require('./app');

const server = app.listen(3000, () => {
  const host = server.address().address;
  const port = server.address().port;

  console.log(`Example app listening at http://${host}:${port}`);
});
~~~

This just loads the `app.js` we created earlier and tells it to listen
to port 3000. Notice one more ES6 feature: the template string in the
log line, which lets us easily interpolate code (`host` and `port`) into
a string.

Run `npm start` and visit <http://localhost:3000/> in
your browser. It's so beautiful! Take a moment to breathe it all in.

In part 4, we'll finally start fetching files from Dropbox. 

[contact]: mailto:erik@echographia.com "I don't have comments set up yet."
[part 2]: /2015/05/23/dropbox-express-2-zombie-testing.html
