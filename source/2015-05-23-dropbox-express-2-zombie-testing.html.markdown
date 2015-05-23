---
supertitle: Dropbox Express with ECMAScript 6+
subtitle: "Part 2: Zombie Testing."
title: "Dropbox Express 2: Zombie Testing."
date: 2015-05-23 18:18 UTC
tags: node.js, mocha.js, zombie.js, es.next, babel
---

*This is how I built a simple server-side JavaScript app on top of the
Dropbox API, using Express.js, ECMAScript 6 (and one thing I hope will
be in ES 7), and Zombie.js for testing. It was my first time using any
of these things (except JavaScript, natch), so there are probably
better ways to do some of it. [Let me know!][contact]*

In [part 1], we set up Node, Express, and Babel, some basic tools for
writing our application. But we're going to do test-driven development
(somewhat), so let's start by testing the most fundamental thing: Our
app does something.

READMORE

## Mmm, zombie mocha.

I'm a fan of [outside-in testing], where you start by writing high-level
tests and then write unit tests and application code to support them.
For this project, I wanted to be able to test client-side JavaScript,
because I thought I would be using [OAuth 2][dropbox-oauth] to
authenticate users with the Dropbox API (spoiler: I didn't), but I
didn't want the overhead of a browser-based tool like [Selenium], so I
settled on headless testing with [Zombie]. 

I also chose [Mocha] as a testing framework, because it's popular. Let's
install them!

~~~
npm install --save-dev zombie mocha
~~~
{: .language-bash}

## A test, first.

The first thing we're going to do is just test that our app renders
something when we hit the root URL. Create a folder called `test`
and put `acceptance_test.js` in it:
 
~~~
const browserContext = require('./browser_context');

describe('Home page', () => {
  browserContext();

  beforeEach(function () {
    return this.browser.visit('/');
  });

  it('says hello', function () {
    this.browser.assert.text('body', /hello/i);
  });
});
~~~

In this file, we `describe` a test for the home page. First, we set up a
browser context (see [below](#browser-context)), which gives us a Zombie
browser to work with. Before each test, we tell the browser to `visit`
the home page; and in our only actual test, we `assert` that the page
contains the word "hello."

Notice a couple of ECMAScript 6 features:

  * the [`const`][const] statement declares a constant; if anything
    tried to change the value of `browserContext` later in the program,
    we'd get an error
  * the [arrow function][fat-arrow] on line 3

In general, arrow functions make the meaning of the `this` variable
more intuitive, but we can't use them on lines 6 and 12. I think this
is because Mocha's `beforeEach` and `it` functions set `this` for the
functions they're passed, but I haven't dug into it.

## Configuring Mocha.

We need to tell Mocha we're using ES6. We can do this by setting up
a test command in `package.json`. Edit the "scripts" section:
 
~~~
  "scripts": {
    "test": "./node_modules/.bin/mocha --harmony --compilers js:babel/register"
  },
~~~
{: .language-json}
 
The `--harmony` flag tells Mocha to use Node's built-in ES6 support, and
the `--compilers` flag tells it to use Babel. (I don't know why we need
both.)

While we're in here, note that `package.json` is where the input from
`npm init` ended up, back in part 1. Also, as we've been using `npm
install`, our dependencies have been recorded here.

You should now be able to run `npm test` in the shell, and it will
run the `mocha` command we specified, but it will fail, because our
test requires a file that doesn't exist.

## Browser context.

Our acceptance test relies on a little glue to start up the app and
then point a Zombie browser at it. (I adapted this from a [post by
Victor Arias][browsercontext].) Create `test/browser_context.js`:

~~~
const app = require('../app');
const Browser = require('zombie');

module.exports = () => {
  // Before we run the tests, start up the app, and point a new
  // Zombie browser at it.
  before(function () {
    this.server = app.listen(3030);
    this.browser = new Browser({site: 'http://localhost:3030/'});
  });

  // After we're done, shut down the app.
  after(function (done) {
    this.server.close(done);
  });
};
~~~

When you `require` a file in Node, you're loading a module, and
specifically you're loading whatever it puts in `module.exports`. So
in this case, `browser_context.js` exports a function that sets up
some Mocha hooks. In `acceptance_test.js`, we set `browserContext` to
that function, and we run it in our test definition.
 
At this point, `npm test` still fails, because `browser_context.js`
requires another file that doesn't exist yet: the actual app. How
frustrating! We'll write it in part 3.

[contact]: mailto:erik@echographia.com "I don't have comments set up yet."
[part 1]: /2015/05/22/dropbox-express-with-ecmascript-6.html
[outside-in testing]: https://robots.thoughtbot.com/testing-from-the-outsidein
[zombie]: http://zombie.js.org/
[dropbox-oauth]: https://www.dropbox.com/developers/reference/oauthguide
[selenium]: http://www.seleniumhq.org/
[mocha]: http://mochajs.org/
[const]: http://es6-features.org/#Constants
[fat-arrow]: http://es6-features.org/#StatementBodies
[browsercontext]: http://victorarias.com.br/2014/08/24/end-to-end-testing-with-node-js.html
