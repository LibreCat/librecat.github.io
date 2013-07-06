---
layout: post
title: Extend Catmandu without Perl
author: Patrick
tags: "perl, catmandu"
published: true
categores: catmandu
categore: catmandu
categor: catmandu
category: catmandu
---

With Catmandu we create [ETL](http://en.wikipedia.org/wiki/Extract,_transform,_load)-pipelines for library workflows. Read data from OAI, SRU, Z39.50, PubMed, arXive, transform it with Catmandu Fixes and load the results into Solr, MongoDB, CouchDB or serialize into YAML, CSV, XML whatever you like. Read my blog post about the [Catmandu Cheat Sheet](/catmandu/2013/06/21/catmandu-cheat-sheet.html)
to get a quick recap.

Today I want to show you how you can create your own Fix routines in any programming language using the [Catmandu::Fix::cmd](http://search.cpan.org/~nics/Catmandu-Fix-cmd-0.01/) which Nicolas Steenlant created.


First we create a small Perl script to generate some sample JSON we will use in our examples (you can use your own JSON file or translate this trivial script into Python, Ruby, Java, C, Clojore, Go ...).

Here is our little JSON generator:

{% highlight perl %}
#!/usr/bin/env perl
# file: generate.pl

use JSON;

for (1...1000) {
    print encode_json({ random => rand }) , "\n";
}
{% endhighlight %}

When we execute the script we'll get one thousand lines of JSON in our terminal:

{% highlight bash %}
$ ./generate.pl
{"random":0.721613357218615}
{"random":0.491180438229559}
{"random":0.868290266595814}
.
.
.
{% endhighlight %}

It is now easy to use Catmandu Fixes to transform these JSON records. E.g. we can add a new field 'title' with content 'test':

{% highlight bash %}
$ ./generate.pl | catmandu convert JSON --fix 'add_field("title","test")'
{"random":0.611390470122803,"title":"test"}
{"random":0.915937067437753,"title":"test"}
{"random":0.461684127836374,"title":"test"}
.
.
.
{% endhighlight %}

This add_field() Fix was written in Perl. What if you need to write a new complicated Fix-routine and don't want to use Perl? Well, we have Catmandu::Fix::Cmd to the rescue! You can create fixes in any language you like, as long as your program can read JSON records from the standard input and can write JSON records to the standard output you are cool. Lets try that out.

As example we create a Python script to read JSON from the stdin, add a title field and write the JSON back to stdout.

{% highlight python %}
#!/usr/bin/env python
# file: catjson.py
import sys
import json

while 1:
    line = sys.stdin.readline()
    if not line: break
    data = json.loads(line.strip())
    data['title'] = "test";
    print json.dumps(data)
{% endhighlight %}

If we run this we can see the expected result.

{% highlight bash %}
$ ./generate.pl | ./catjson.py
{"random": 0.530965947974309, "title": "test"}
{"random": 0.371021223752646, "title": "test"}
{"random": 0.0907161737840951, "title": "test"}
.
.
.
{% endhighlight %}

With the Catmandu Fix 'cmd' we can make this Python program part of an ETL-pipeline. In the simple example below we will repeat the previous test:

{% highlight bash %}
$ ./generate.pl | catmandu convert JSON --fix 'cmd("./catjson.py")'
{"random":0.554686750713572,"title":"test"}
{"random":0.275637603863029,"title":"test"}
{"random":0.318374223918873,"title":"test"}
.
.
.
{% endhighlight %}

Now this is working you can add the whole Catmandu stack to this pipeline. Add different importers, new fixes, store into ElasticSearch or MongoDB. E.g. we can do an SRU query and use our Python and Perl fixes simultaneously:

{% highlight bash %}
$ catmandu convert SRU --base http://www.unicat.be/sru --query dna --fix 'cmd("./catjson.py");remove_field("recordData")'
{"recordPacking":"xml","recordPosition":"1","title":"test","recordSchema":"info:srw/schema/1/dc-schema"}
{"recordPacking":"xml","recordPosition":"2","title":"test","recordSchema":"info:srw/schema/1/dc-schema"}
{"recordPacking":"xml","recordPosition":"3","title":"test","recordSchema":"info:srw/schema/1/dc-schema"}
.
.
.
{% endhighlight %}

Here is how the same program might look like in Lua
{% highlight lua %}
#!/usr/bin/env luajit
# file: catjson.lua
-- requires dkjson http://chiselapp.com/user/dhkolf/repository/dkjson/home
local json = require ("dkjson")

for line in io.lines() do
    local obj, pos, err = json.decode (line, 1, nil)
    obj['title'] = 'test'
    print(json.encode(obj))
end
{% endhighlight %}

With the same expected results:
{% highlight bash %}
$ ./generate.pl | catmandu convert JSON --fix 'cmd("./catjson.lua")'
{"random":0.54868770433573,"title":"test"}
{"random":0.26483418097243,"title":"test"}
{"random":0.15708750198151,"title":"test"}
.
.
.
{% endhighlight %}

Using Catmandu::Fix::cmd you can create complicated fix routines to extend your data crunching needs.
