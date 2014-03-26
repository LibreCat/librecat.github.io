---
layout: post
title: Create a fixer [Part 2]
author: Patrick
tags: "perl, catmandu, fix"
published: true
category: catmandu
---

This is part two of a two-part overview of extending the Catmandu Fix language. In [Part 1](/catmandu/2014/03/14/create-a-fixer.html), we showed how a Catmandu Fix is just a simple Perl object that has a  ‘fix’ instance method. The only argument passed to the method is the Perl hash to transform; the return value should be the transformed/fixed Perl hash.

Using Moo a Fix can be written as:

{% highlight perl %}
 package Catmandu::Fix::do_nothing;

 use Moo;

 sub fix {
  my ($self,$data) = @_;
  # … your fixes on $data…
  $data;
 }

 1;
 {% endhighlight %}

Most of the cases the Fixes you create shouldn’t be any more complicated than this. 

Things change when you want to use the Fix path language. For instance, when you need to evaluate deeply nested Perl hashes with paths like:

{% highlight perl %}
 /foo/bar/1/*/test.$append
{% endhighlight %}

In these cases Fixes should extend the Catmandu::Fix::Base class and implement an emit function. In this post we shall create a 'md5sum' fix using emit functions. 

Lets start easy by creating a skeleton fix that does nothing:

{% highlight perl %}
 package Catmandu::Fix::nothing;

 use Catmandu::Sane; 
 use Moo;

 with 'Catmandu::Fix::Base';

 around BUILDARGS => sub {
    my ($orig, $class) = @_;
    $orig->($class);
 } ;

 sub emit {
    my ($self, $fixer) = @_;
    'undef';
 }

1;
{% endhighlight %}

We first declare ‘nothing‘ as a subclass of Catmandu::Fix::Base using Moo roles (the ‘with’ keyword). With around BUILDARGS we define how a new instance of the ‘nothing’ Fix can be created. This is also the place where you can add any required arguments or options for this fix command (more on this later).

The emit subroutine contains the logic of the transformation and should return a string. This string contains Perl code to transform input data. Catmandu will compile the string to speed up the processing of fixes. In the example above we return undef that is translated into a null-operation after compilation.

When Catmandu compiles the Perl emit code above it will generate something like this:

{% highlight perl %}
 sub {
   my $__0 = $_[0];
   eval {
		__FIX__1: {undef};
		1;
   } or do {
     my $__1 = $@;
     die $__1.Data::Dumper->Dump([$__0], [qw(data)]);
   };
   return $__0;
 };
{% endhighlight %}

Noticed how the ‘undef’ of the emit code gets inserted next to the \__FIX__1 directive? Catmandu will call this code with the input data as only argument. This maybe looks quite complicated, but it was created by Nicolas Steenlant to provide an easy (as in fast) and efficient (as in very fast) way to generate a lot of Perl code that can walk a deeply nested Perl hash.

Lets add some more code to explain the emit function a bit better. We will add hardcoded a string to add a ‘foo’ => ‘bar’ name-value pair in the input data:

{% highlight perl %}
sub emit {
    my ($self, $fixer) = @_;
    my $data = $fixer->var;
    "${data}->{foo} = 'bar'";
}
{% endhighlight %}

The attribute $fixer->var contains a reference to the input data we need to process. That is: $fixer->var contains the name of the variable that contains the input data. Internally in Catmandu this code gets compiled into:

{% highlight perl %}
sub {
   my $__0 = $_[0];
   eval {
		__FIX__1: { $__0->{foo} = 'bar'}};
		1;
   } or do {
     my $__1 = $@;
     die $__1.Data::Dumper->Dump([$__0], [qw(data)]);
   };
   return $__0;
};
{% endhighlight %}

We see that value of $fixer->var is the string ‘$__0’. When this subroutine is called with a Perl hash as input, then a new field ‘foo’ with value ‘bar’ is added to the input hash.

In the next examples we will skip the compiled code. Only try to remember that ‘emit’ returns a string that gets compiled into Perl code and that Catmandu::Fix has a lot of helper methods to generate a lot of Perl code to transform deeply nested hashes.

Lets try to do something with a deeply nested path. This is a pattern you will see in many of our Catmandu Fixes.  In the code below we create a MD5 hash sum in a deeply nested Perl hash. We would like to say something like:

{% highlight perl %}
 md5sum('my.deeply.nested.field');
{% endhighlight %}

or

{% highlight perl %} 
 md5sum('my.deeply.nested.*.field');
{% endhighlight %}

in case ‘nested’ was an array of hashes. 

In pseudo Perl code this could be coded as:

{% highlight perl %}
 $data->{my}->{deeply}->{nested}->{field} = md5sum($data->{my}->{deeply}->{nested}->{field});
{% endhighlight %}

and

{% highlight perl %}
 for (@{$data->{my}->{deeply}->{nested}}) {
	$_->{field} = md5sum($_->{field});
 }
{% endhighlight %}

In the first case you would end up with creating a lot of leaf nodes if ‘my.deeply.nested.field’ didn't exist in the hash. In the second case you will end up with a lot of nested for loops for every array in the path.

Catmandu can help you to walk this path by breaking this operation into two steps:

1.	Walk the deeply nested hash until you hit my.deeply.nested (or my.deeply.nested.* in the second case).
2.	Set the ‘field’ value to a md5sum of itself.

In emit code this will look like:

{% highlight perl %}
 01: sub emit {
 02:     my ($self, $fixer) = @_;
 03:     my $path = $fixer->split_path($self->path);
 04:     my $key = pop @$path;
 05:
 06:     $fixer->emit_walk_path($fixer->var, $path, sub {
 07:       my $var = shift;
 08:       $fixer->emit_get_key($var, $key, sub {
 09:           my $var = shift;
 10:           "if (is_string(${var})) {" .
 11:               "${var} = Digest::MD5::md5_hex(${var});" .
 12:          "}";
 13:       });
 14:     });
 15: }
{% endhighlight %}

In line 03 we read the path and split it into parts: my , deeply , nested , * , field. 

In line 04 we create two things: 1) the path we want to walk \[my, deeply, nested, \*] and 2) the key ‘field’ we need to change into a md5sum.

In line 06 we start walking the deeply nested hash starting from $fixer->var which is the input data. For every end node in the path a callback function is called. This is the anonymous subroutine on line 06, which gets one argument: the current node. 

In line 08 we change the current node by asking for the ‘field’ key and changing the value with a callback function.

All these $fixer->emits return strings that get concatenated into a very large string (depending on the size of your path) at the end of the emit_walk_path function. The resulting string will be compiled into Perl code as stated above.

Our new fixer can work on any type of path. We can fix:

{% highlight perl %}
  md5sum("my.deeply.nested.field");
{% endhighlight %}

In this case emit_walk_path walks to 'my.deeply.nested' and changes 'field' into its MD5 value.

We can fix:

{% highlight perl %}
  md5sum("my.deeply.nested.*.field");
{% endhighlight %}

In the case emit_walk_path loops into the 'my.deeply.nested' array of hashes and changes 'field' into its MD5 value.

There are other emit helper functions you can use.

Use:

{% highlight perl %}
 $fixer->emit_get_key($var, $key, sub {}); 
{% endhighlight %}

to change the value of a variable that gets passed on by emit_walk_path.

Use:

{% highlight perl %}
 $fixer->emit_delete_key($var, $key);
{% endhighlight %}

to delete a key from the variable that gets passed on by emit_walk_path

Use:

{% highlight perl %}
  $fixer->emit_create_path($var, [ 'still','deeper','path'] , sub {});
{% endhighlight %}

to create a new path and possibly set its value.


Below we provide a complete example to generate the MD5 fix that can serve as a template for your fixes:

{% highlight perl %}
package Catmandu::Fix::md5sum;

use Catmandu::Sane;
use Digest::MD5;
use Moo;

with 'Catmandu::Fix::Base';

has path => (is => 'ro', required => 1);

around BUILDARGS => sub {
    my ($orig, $class, $path) = @_;
    $orig->($class, path => $path);
};

sub emit {
    my ($self, $fixer) = @_;
    my $path = $fixer->split_path($self->path);
    my $key = pop @$path;
    $fixer->emit_walk_path($fixer->var, $path, sub {
        my $var = shift;
        $fixer->emit_get_key($var, $key, sub {
            my $var = shift;
            "if (is_string(${var})) {" .
                "${var} = Digest::MD5::md5_hex(${var});" .
            "}";
        });
    });
}

1;
{% endhighlight %}
