---
layout: post
title: Versioning using Catmandu::Plugin
author: Patrick
tags: "perl, catmandu, versioning"
published: true
category: catmandu
---

Recently we had in our [mailing list](http://mail.librecat.org/mailman/listinfo/librecat-dev) a question by
Jakob Voss if Catmandu supports versioning of records. Indeed we do! In this post I'll give an example what is
possible using the Catmandu::Plugin modules developed by Nicolas Steenlant.

First, lets create a sample application in Perl to store some records in an in-memory hash for test purposes:

{% highlight perl %}
#!/usr/bin/env perl

use Catmandu::Store::Hash;
use Data::Dumper;

my $store = Catmandu::Store::Hash->new();

$store->bag->add({
	'_id'  => '001',
	'name' => 'John Doe'
});

$store->bag->add({
	'_id'  => '001',
	'name' => 'John Moo'
});

$store->each(sub { print Dumper($_[0]) });
{% endhighlight %}

First we store in a record with id '001' a 'John Doe' and then we overwrite this record with 'John Moo'. As result you
should see only the version 'John Moo' printed on screen.

To add versioning we have to edit the initiation of the Hash and add a 'Versioning' plugin to the 'data' bag. As you
may recall 'data' is the default name of the storage container in your Catmandu::Store. Using the get_history method
all the versions of your records can be retrieved.

{% highlight perl %}
#!/usr/bin/env perl

use Catmandu::Store::Hash;
use Data::Dumper;

my $store = Catmandu::Store::Hash->new(
				bags => {
					'data' => {
						plugins => [qw(Versioning)]
					}
				});

$store->bag->add({
	'_id'  => '001',
	'name' => 'John Doe'
});

$store->bag->add({
	'_id'  => '001',
	'name' => 'John Moo'
});

print "Versions:\n";

for (@{$store->bag->get_history('001')}) {
    print Dumper($_);
}
{% endhighlight %}

Or, you can get one particular version with the 'get_version' method:

{% highlight perl %}
  my $obj = $store->bag->get_version('001',2);
{% endhighlight %}

Or, the previous version with 'get_previous_version':

{% highlight perl %}
  my $obj = $store->bag->get_previous_version('001');
{% endhighlight %}

Sometimes you don't want to create a new version records when nothing changed to the data except for some date field for instance.
This can be set using the 'version_compare_ignore' field when creating a store:

{% highlight perl %}
  my $store = Catmandu::Store::Hash->new(
				bags => {
					'data' => {
						plugins => [qw(Versioning)] ,
						version_compare_ignore => [qw(access_date)],
					}
				});
{% endhighlight %}

Using this setting, new versions will only be created when any field except 'access_date' will change in value.

