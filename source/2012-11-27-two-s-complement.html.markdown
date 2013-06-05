---
title: Two's Complement
date: 2012-11-27 00:16 -06:00
tags: math, computer science, binary
---

Two's Complement is a way of translating between decimal numbers and
fixed-width sets of bits (i.e., binary numbers) that allows for both
positive and negative numbers.

### Bits to digits

In pure math, negative binary numbers are easy: -8 decimal is -1000 binary.
But computers don't have a negative sign; they just have a bunch of switches that are either on or off. So we need a way to use those switches to talk about negative numbers.

Suppose we have a world where the only numbers you can talk about are ones that fit in four bits.  0000, 0001, 0010, ... 1111.

An obvious way to translate between those four bits and integers is to, you know, do binary the way you know about. So 0000 = 0, 0001 = 1, 0010 = 2, all the way up to 1111 = 8 + 4 + 2 + 1 = 15.

The problem with that is, now you have no way of talking about negative integers at all.

So another way of translating is: you say, okay, everything that starts with a 0, we do that way.  0000 = 0 up to 0111 = 7.  Then you wrap around to 1000 = -16, 1001 = -8, 1010 = -7, .... 1111 = -1. That's Two's Complement.

Another way of looking at it is like this: In regular binary numbers, looking from left to right, the bits stand for 8, 4, 2, 1. In Two's Complement, the leftmost digit doesn't stand for 8, it stands for *negative* 8.  So 1010 = -8 + 0 + 2 + 0 = -6.

You can do this with different numbers of bits, of course: 8, 16, 32,
64, whatever you have available.

Languages like Python and Ruby use Two's Complement, but they work with
**infinite** bits. So any binary number that starts with 0 is positive,
and any binary number that starts with 1 is negative.

### The complement operator

The bitwise complement operator (~) negates each bit of its operand. You might
think this means that ~3 decimal is ~11 binary, which is 00 binary,
which is 0 decimal. Thanks to Two's Complement, you are in for a
surprise!

In four-bit world, we pad binary numbers to four digits. So 3 decimal is 0011 binary, and ~3 is ~0011, which is
1100, which (Two's Complement!) is -8 + 4 + 0 + 0 = -4.

In infinite-bit world, we don't pad to a fixed number of digits, but we
do use a single digit to indicate the sign of the number. So 3 decimal
isn't 11, it's **0**11, and ~3 is ~011 is 100 is -4 + 0 + 0 is -4.

If you calculate a number of complements, you'll discover that ~x is
always equal to -(x + 1). I haven't done the math to understand why this
is, but it's pretty neat.

### Note: Binary numbers are syntax.

Ruby and Python support binary numbers as *syntax*, not as a data type.
So you can enter a number as 0b00whatever, but it comes back out as decimal.
Because they're both just integers, and the default output format for an integer is decimal.
