---
title: Infinite iterator.
date: 2012-11-14 00:12 -06:00
tags: ruby, tricks, loops
---

~~~
> ring = %w\[one two three\].cycle
> puts ring.take(4)
one
two
three
one
~~~

-- James Edward Gray II, &ldquo;[<s>10</s> Things You Didn't Know Ruby Could Do](https://speakerdeck.com/jeg2/10-things-you-didnt-know-ruby-could-do)&rdquo;
