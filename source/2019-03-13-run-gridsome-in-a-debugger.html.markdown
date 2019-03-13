---
title: Run Gridsome in a debugger.
date: 2019-03-13 20:10 UTC
tags: javascript, node.js
---
New web site coming soon. Meanwhile, it's time to start writing things
down again.

Here's how to debug [Gridsome](gridsome), the Vue-based static site
generator, in JetBrains IDEs such as WebStorm. (I'm using RubyMine,
but it should be the same.)

READMORE

In `package.json` in your Gridsome project folder, find the line where
the `develop` script is defined. Replace the definition with this one:

~~~javascript
    "develop": "node $NODE_DEBUG_OPTION node_modules/.bin/gridsome develop",
~~~

Voila.

$NODE_DEBUG_OPTION seems to be specific to JetBrains products, a way to
support old versions of Node. If you're using another debugger (like
Visual Studio Code), or if you're running Node 7+ (*very likely*),
you can pass the flag directly:

~~~javascript
    "develop": "node --inspect node_modules/.bin/gridsome develop",
~~~
