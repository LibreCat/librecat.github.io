---
layout: post
title:  "What is this Dancer anyway?"
author: Christian
date: 2013-06-20 18:18
tags: dancer catmandu webdev
categores: catmandu
---

Today a colleague with a background in PHP and CGI scripting asked me,
"What is this Dancer thing you keep bringing up?"

Me: [Dancer](http://www.perldancer.org/) is a microframework for web
development in Perl, like Mojolicious. What
[Sinatra](http://en.wikipedia.org/wiki/Sinatra_%28software%29) is for Ruby, or
Flask or Bottle for Python.

He: ???

Me: It has a built-in web server. In contrast to PHP or CGI scripts,
you can use one file with Perl code to define what should happen when
different URLs are requested. It's like a collection of if--then rules
with a URL pattern to the left and the associated action to the right.

He: Why would I want that?

Me: These rules can be quite compact, giving you a nice overview of
what your web application does (its REST API, if you will). More
importantly, this approach allows you to decouple the URL layout from
your program logic. In contrast to Ruby on Rails or Django, Dancer does not
enforce a strict
[MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)
architecture, but keeping to MVC principles is dead easy using Dancer, if you
want to. Details of the view can be left for the templating system to deal
with.

He: A templating system? Sounds complicated.

Me: Not at all. Writing templates is much like writing PHP, but
simpler. It's basically an HTML file with some placeholders in
it. Web designers love it. Some of them can even be tricked into using the
limited control structures (IF, FOREACH, etc.) offered by templating engines --
realizing only later that they have started to do programming.

He: So why are they called microframeworks? Are they for toy projects only?

Me: Certainly not. Perhaps the name came up because overly complicated
web frameworks such as Zope and all that Java Enterprise stuff had
given web frameworks and web application servers a bad name. Microframeworks
are leaner and do not force programmers into a straightjacket.

He: So why are my favourite open-source web applications all written
in PHP?

Me: I have honestly no idea.

He: Does Dancer make it easy to integrate a database and a search engine into
my web app? I need to create a
[SCRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) web app
for searching, creating, reading, updating and deleting data records.

Me: No. Perhaps this is why it is a called a microframework. But if you add
Catmandu into the mix, you get exactly what you want. How about heading over to
the [Catmandu tutorial](/tutorial)? The second part, [Dancer & Catmandu:
Writing web applications should be easy and fun](/tutorial/dancer.html) teaches
you exactly what you need to know.


-----

I would like to apologise to my colleague for making him look a
little daft in this rendition of our dialogue. No offense intended! I
felt I had to do it for clarity of exposition I guess.
