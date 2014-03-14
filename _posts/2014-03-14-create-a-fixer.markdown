---
layout: post
title: Create a fixer [Part 1]
author: Patrick
tags: "perl, catmandu, fix"
published: true
category: catmandu
---
This is part one of a two part overview of extending the Catmandu Fix language. As you might know already, the Fix language is used in Catmandu to transform JSON data. Our rationale for is is to ease the manipulation of library data formats. Fix is to JSON data what XSLT is for XML.

If you have a JSON input file containing name/value pairs you can use fixes to add
or delete fields:

{% highlight perl %}
 $ echo '{ "name": "Patrick" }' | catmandu convert
 {"name":"Patrick"}

 $ echo '{ "name": "Patrick" }' | catmandu convert --fix 'add_field("age","42")'
 {"age":42,"name":"Patrick"}
{% endhighlight %}

You can write fixes on the command line or in a file:

{% highlight perl %}
 $ cat myfixes.txt
 add_field("age","42");
 add_field("my.favorite.color","blue");
 $ echo '{ "name": "Patrick" }' | catmandu convert --fix myfixes.txt
 {"name":"Patrick","my":{"favorite":{"color":"blue"}},"age":42}
{% endhighlight %}

Check out our [Cheat Sheet](/catmandu/2013/06/21/catmandu-cheat-sheet.html) for more examples of possible fixes. 

Fix code can also be integrated into Perl scripts. We can repeat the experiments above with the Perl code below. 

{% highlight perl %}
  use Catmandu::Fix;
  use DDP;

  my $fixer = Catmandu::Fix->new(fixes => ['add_field("age","42")']);
  my $hash  = $fixer->fix({ name => 'Patrick '});

  p $hash;

  # Read the fixes from a file
  my $fixer = Catmandu::Fix->new(fixes => ['myfixes.txt']);
  my $hash  = $fixer->fix({ name => 'Patrick '});

  p $hash;
{% endhighlight %}

Starting from Catmandu version 0.8006 it is also possible to inline all the fixes.

{% highlight perl %}
  use Catmandu::Fix::add_field as => 'add_field';
  use DDP;

  my $hash  = { name => 'Patrick ' };

  add_field($hash,'age','42');
  add_field($hash,'my.favorite.color','blue');

  p $hash;
{% endhighlight %}

To extend the Fix language you need to create a new Perl package in the Catmandu::Fix namespace which implements a 'fix' method. This method gets as input a Perl hash and should return the changed Perl hash. Here is an trivial example of an 'invert_field' Fix which transforms a name/value-pair into a value/name pair:

{% highlight perl %}
package Catmandu::Fix::invert_field;

sub new {
    my ($class,$path) = @_;
    return bless { path => $path } , $class;
}

sub fix {
    my ($self,$data) = @_;
    my $name  = $self->{path};
    my $value = $data->{$name};

    delete $data->{$name};

    $data->{$value} = $name;

    $data;
}

1;
{% endhighlight %}

With this fix installed we can invert name/value pairs in our input data:

{% highlight perl %}
 $ echo '{ "name": "Patrick" }' | catmandu convert --fix 'invert_field("name")'
 {"Patrick":"name"}
{% endhighlight %}

If you know exactly where in the Perl hash you need to make data changes, then this method of creating Fix functions is quite easy and straight forward. Things get complicated when you want to manipulate deeply nested hashes and arrays. For instance, almost all of the Catmandy provided fixes can manipulate very deeply nested structures:


{% highlight perl %}
	add_field("my.very.deep.field.13.subfield.1.name","Patrick");
{% endhighlight %}

This 'add_field' fix above will operate on a very deep hash of arrays. To support this in your own created Fix functions you need to be able to parse JSON paths. In a next blog post we will go into more details of this process.
