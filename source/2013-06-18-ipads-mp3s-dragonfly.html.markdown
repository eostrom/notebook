---
title: iPads, MP3s, Dragonfly.
date: 2013-06-18 21:13 UTC
tags: ruby, audio, heroku, mobile
---

We ran into a bug where MP3s hosted as "resources"
on [Refinery] worked fine on most platforms, but Safari on iPads
would play the first minute or so on a loop, and the controls didn't
work (no way to pause).

After some false leads, we compared HTTP headers with a site where MP3s
play just fine. The crucial difference was `Accept-Ranges: bytes`.
WordPress would serve partial content; Refinery (via
[Dragonfly]) gives you the whole file or nothing. My hypothesis: Mobile
Safari would rather annoy the user than download the whole file.

A longer-term fix would be to hack Dragonfly to support partial content,
or not use Refinery resources for our MP3s. But for now, we're just
serving the MP3s via a direct link to S3, using Dragonfly's
[`remote_url`][remote_url] method.
READMORE

[refinery]: http://refinerycms.com/ "Refinery CMS: Ruby on Rails CMS that supports Rails 3"
[dragonfly]: http://markevans.github.io/dragonfly/file.ServingRemotely.html "File: ServingRemotely — Documentation by YARD 0.8.6.1"
[remote_url]: http://markevans.github.io/dragonfly/file.ServingRemotely.html "File: ServingRemotely — Documentation by YARD 0.8.6.1"