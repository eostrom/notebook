---
title: Run Gridsome in a debugger.
date: 2019-03-13 20:10 UTC
tags: javascript, node.js
---
New web site coming soon. Meanwhile, it's time to start writing things
down again.

Here's how to debug [Gridsome][], the Vue-based static site
generator, in [JetBrains][] IDEs such as WebStorm. (I'm using RubyMine,
but it should be the same.)

READMORE

In `package.json` in your Gridsome project folder, find the line where
the `develop` script is defined. Replace the definition with this one:

~~~javascript
    "develop": "node $NODE_DEBUG_OPTION node_modules/.bin/gridsome develop",
~~~

Voila. Now you can run it in debug mode by clicking the green "Run Script"
triangle and then "Debug `develop`".

$NODE_DEBUG_OPTION seems to be specific to JetBrains products, and has a
different value depending on whether you're running the script in the
debugger. If you're using another debugger, you can pass the flag
explicitly:

~~~sh
node --inspect node_modules/.bin/gridsome develop
~~~

Similar techniques apply for [Nuxt.js][] and other
Node servers.

[Gridsome]: https://gridsome.org
[JetBrains]: https://www.jetbrains.com
[Nuxt.js]: https://nuxtjs.org
