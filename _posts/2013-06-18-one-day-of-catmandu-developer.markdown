---
layout: post
title: One Day of a Catmandu Developer
author: Patrick
tags: perl, catmandu
---
At Ghent University Library we are using Catmandu these days in a project to create a new discovery
interface for our Aleph catalog. Daily we export MARC sequential files from several ALEPH catalogs and store them
in a [MongoDB](http://www.mongodb.org/) store. Into this store we also add records from our 
[SFX](http://en.wikipedia.org/wiki/SFX_%28software%29) server and our institutional repository 
[Biblio](http://biblio.ugent.be). 

We use the MongoDB store to do cleaning of our datasets plus a FRBR-ized merge of records. This <em>merge</em>
is logical in our setup. One collection contains MARC records, one other collection is used to create
relations between these records. When the data is cleaned and merged, we export the data to a Solr indexer which is used by the [BlackLight](http://projectblacklight.org/) frontend.

In the image below the architecture is shown. The Catmandu trail is 
clearly visible. For importing MARC records into MongoDB we use Catmandu importers. When we have all the data
in the store we run a bunch of Catmandu fixers to cleanup the data. At the end of the day we use Catmandu exporters
to send the data as JSON files to Solr where we index the data and make it available in BlackLight.

![DicoveryArchitecture](/assets/img/20130618_discovery.jpg)