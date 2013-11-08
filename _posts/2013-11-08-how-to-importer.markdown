---
layout: post
title: How to create a new Catmandu importer
author: Vitali
tags: "perl, catmandu, importer"
published: true
category: catmandu
---

Within the [Catmandu](https://github.com/LibreCat/Catmandu) framework different kinds of importers have been implemented

- those for general formats like [JSON](https://metacpan.org/pod/Catmandu::Importer::JSON), [YAML](https://metacpan.org/pod/Catmandu::Importer::YAML) or [CSV](https://metacpan.org/pod/Catmandu::Importer::CSV)

- those for bibliographies formats, like [MARC](https://github.com/LibreCat/Catmandu-MARC) or [AlephX](https://github.com/LibreCat/Catmandu-AlephX)

- those for different Sources like [arXiv](https://github.com/LibreCat/Catmandu-ArXiv), [Pubmed](https://github.com/LibreCat/Catmandu-PubMed), [PloS](https://github.com/LibreCat/Catmandu-PLoS) or in general those with an [OAI-Interface](https://github.com/LibreCat/Catmandu-OAI)

Since Catmandu is designed for in a way, that can be extended... So in this little Tutorial we are going to create our own importer module *Catmandu::Importer::EuroPMC*. 

## Starting with a module

First of all, let us remember that

	1. importers have to be within the namespace *Catmandu::Importer::*
	2. Catmandu uses *Module::Build* as building tool

{% highlight bash %}
$ cpanm Module::Build Module::Starter
$ module-starter --builder="Module::Build" --module=Catmandu::Importer::EuroPMC --author="Vitali" /
-- email="vitali@example.com"
{% endhighlight %}

Now, change directory to Catmandu-Importer-EuroPMC and open the file lib/Catmandu/Importer/EuroPMC.pm.


## Structure of an importer module

{% highlight perl %}
package Catmandu::Importer::EuroPMC;

use Catmandu::Sane;
use Moo;

with 'Catmandu::Importer';

use constant BASE_URL => 'http://www.ebi.ac.uk/europepmc/webservices/rest';

has base => (is => 'ro', default => sub { return BASE_URL; });
has source => (is => 'ro', default => sub { return "MED"; });
has query => (is => 'ro', required => 1);

# public method
sub generator {
	my ($self) = @_;
	my $request = $self->base . "/" . $self->source . "/" . $self->query;
	# perform get request ....

	return $hashref;
}

1;

{% endhighlight %}

More insights in Catmandu will be dicussed in later posts.
