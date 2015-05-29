---
supertitle: Dropbox Express with ECMAScript 6+
subtitle: "Part 5: A sandbox."
title: "Dropbox Express 5: A sandbox."
date: 2015-05-28 21:31 UTC
tags: node.js, express.js, es.next, dropbox, testing
---

*This is how I built a simple server-side JavaScript app on top of the
Dropbox API, using Express.js, ECMAScript 6 (and one thing I hope will
be in ES 7), and Zombie.js for testing. It was my first time using any
of these things (except JavaScript, natch), so there are probably
better ways to do some of it. [Let me know!][contact]*

In [part 4], we wrote a simple app that counts files in a Dropbox
folder. It passes its test! Now let's see what it looks like in the
browser.
READMORE

## Up and running.

If you run `npm start` now, you'll get an error: "No API key supplied."
We made our test load its configuration via `dotenv`, but we didn't
make the application do it. Add this line to the top of `index.js`:

~~~
require('dotenv').load();
~~~

Visit <http://localhost:3000/> and it will tell you that there are
0 files in the folder.

## Be suspicious.

Of course, any good QA engineer knows that doesn't mean it's *working*.
We could just have an app that says there are 0 files, no matter how many
files there actually are. Let's make sure this is for real by adding a
file to the Dropbox.

If you named your app "journal dev" like I did, and you have the Dropbox
desktop app installed, by this point you should have an empty folder, also
called `journal dev`, inside the `Apps` folder of your dropbox. You can
add some empty files to it from the command line:

~~~
touch ~/Dropbox/Apps/journal\ test/2015-05-27.html
touch ~/Dropbox/Apps/journal\ test/2015-05-28.html
~~~
{: .language-bash}

Reload <http://localhost:3000/>. Voila! Two files. The system works!
 
## Isolate tests.

One problem: Now if you run `npm test`, you'll get an error:

~~~
Expected "Files found: 2" to match "/Files found: 0/i"
~~~
{: .language-bash}

We meddled with the folder we used for testing, and now the test's
assumption of an empty folder is no longer true. We could update
the test to reflect the new reality, but we don't want to have to
change the test every time we put something in the folder. Instead,
we need separate environments for testing and development.

The best way I've found is to create a separate Dropbox app. Just like
in [part 4][part-4-dropbox-app], use the [Dropbox App Console] to create
a new app, again limited to its own folder (I called mine "journal test"),
and generate an application token for it.

Create a second configuration file for our test environment, called
`.env.test`. It should look just the same as `.env`, but with the new
token:

~~~
DROPBOX_AUTH_TOKEN=Y0urN3wAcc355T0k3nF0rD3vG03sH3r3
~~~

In `test/acceptance_test.js`, change the `dotenv` line:

~~~
require('dotenv').load({path: '.env.test'});
~~~

And make sure you don't check your new access token into git:

~~~
git ignore .env.test
~~~
{: .language-bash}

`npm test` passes again, because your new test app's folder is empty.
`npm start` and your dev environment counts files in the dev folder.
But file counts are boring. In part 6, we'll choose a file and see
what's inside it.

[contact]: #comments
[part 4]: /2015/05/25/dropbox-express-4-dropbox-at-last.html
[part-4-dropbox-app]: /2015/05/25/dropbox-express-4-dropbox-at-last.html#a-test-app 
[dropbox app console]: https://www.dropbox.com/developers/apps