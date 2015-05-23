---
title: Dropbox Express with ECMAScript 6+.
subtitle: "Part 1: Express, Babel."
summary_title: "Dropbox Express: Express, Babel."
date: 2015-05-22 21:50 UTC
tags: node.js, express.js, es.next, babel, eslint
---

*This is how I built a simple server-side JavaScript app on top of the
Dropbox API, using Express.js, ECMAScript 6 (and [one thing][async-await]
that I hope will be in ES 7), and Zombie.js for testing. It was my first
time using any of these things (except JavaScript, natch), so there are
probably better ways to do some of it. [Let me know!][contact]*

In this post, I'll cover the initial setup. Future posts will be about
more interesting things.

READMORE

## Setting up.

Before writing any code, [install Node][node] and [Express][install-express].
If you're new to Node and the package manager `npm`, here are some things
to know about the `npm init` step:

1. None of it really matters, you're not going to be publishing this
   as a package for people to use.
2. We'll add a test command later.
3. For author you can just enter your name, [or more][npm-name-format].

When you install express, use the `--save` flag, so it'll be installed
when you deploy the app, too.

(You might as well `git init`, grab a [.gitignore](gitignore), and commit
the code at this point. If I were you, I'd commit at the end of each
section.)

## The next JavaScript.

[Exciting things are happening][es6] in the world of JavaScript! It will
be a while before browsers implement them, but for server-side development,
it's easy to get started now by installing [Babel](http://babeljs.io/).

~~~
npm install --save babel
npm install --save-dev babel-eslint
~~~

(The actual difference between `--save` and `--save-dev` is moot, but I'm
using it to distinguish between run-time and develop-time dependencies.)
 
`babel-eslint` lets the [ESlint] code checker use Babel's parser, so it
won't get thrown when we use some advanced language features.

We need to configure these tools. Create a file `.babelrc`:

~~~
{
  "stage": 1
}
~~~

This tells Babel to enable "stage 1" features (i.e., proposals) from
ECMAScript 7, specifically [`async/await`][async-await]. It's experimental
and subject to change, but it's so nice. So nice. You'll see.

And another file `.eslintrc`:

~~~
{
  "parser": "babel-eslint",

  "env": {
    "node": true,
    "es6": true,
    "mocha": true
  },
  "rules": {
    "strict": "global",
    "no-unused-vars": [1, {"args": "after-used"}],
    "no-underscore-dangle": false,
    "quotes": [1, "single", "avoid-escape"]
  }
}
~~~

This a combination of necessary configuration (the parser, the environments)
and my personal preferences (the rules).

In part 2, we'll start developing the app, test-first.

[contact]: mailto:erik@echographia.com "I don't have comments set up yet."
[node]: http://nodejs.org/
[install-express]: http://expressjs.com/starter/installing.html
[npm-name-format]: https://docs.npmjs.com/files/package.json#people-fields-author-contributors
[gitignore]: https://github.com/github/gitignore/blob/master/Node.gitignore
[es6]: http://es6-features.org/
[eslint]: http://eslint.org/
[async-await]: https://github.com/lukehoban/ecmascript-asyncawait
