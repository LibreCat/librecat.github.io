---
layout: post
title: Catmandu - Cheat Sheet
author: Patrick
tags: "perl, catmandu"
published: true
categores: catmandu
categore: catmandu
categor: catmandu
category: catmandu
---

### Help

{% highlight bash %}
 $ catmandu help
 $ catmandu help convert
{% endhighlight %}

### Convert

{% highlight bash %}
 # Use Catmandu Importers to read data into your environment
 $ catmandu convert MARC to JSON < records.mrc
 $ catmandu convert MARC to YAML < records.mrc
 $ catmandu convert MARC to JSON --pretty 1 < records.mrc
 $ catmandu convert MARC to JSON --fix 'marc_map("245","title");remove_field("record")' < records.mrc
 $ catmandu convert MARC to CSV --fix 'marc_map("245","title"); remove_field("record");' < records.mrc
 $ catmandu convert OAI --url http://biblio.ugent.be/oai --set allFtxt to JSON
 $ catmandu convert OAI --url http://biblio.ugent.be/oai --set allFtxt to JSON --fix 'retain_field("title")'
 $ catmandu convert SRU --base http://www.unicat.be/sru --query dna	
 $ catmandu convert ArXiv --query 'all:electron'
 $ catmandu convert PubMed --term 'hochstenbach'
 $ cat test.tt
[%- FOREACH f IN record %]
[% _id %] [% f.shift %][% f.shift %][% f.shift %][% f.join(":") %]
[%- END %]
 $ catmandu convert MARC to Template --template `pwd`/test.tt < records.mrc 
{% endhighlight %}

### Import/Export
{% highlight bash %}
 # Use Catmandu Store to store/retrieve data from a database
 $ catmandu import JSON to MongoDB --database_name mydb --bag data < records.json
 $ catmandu import MARC to MongoDB --database_name mydb --bag data < records.mrc
 $ catmandu import MARC to ElasticSearch --database_name mydb --bag data < records.mrc
 $ catmandu import MARC to ElasticSearch --database_name mydb --bag data --fix 'marc_map("245a","title")' < records.mrc

 $ catmandu export MongoDB --database_name mydb --bag data to JSON
 $ catmandu export MongoDB --database_name mydb --bag data to JSON --fix 'retain_field("_id")'
 $ catmandu export Solr --url http://localhost:8983/solr to JSON
 $ catmandu export ElasticSearch --index_name mydb to JSON
{% endhighlight %}

### Lazy
{% highlight bash %}
 $ cat catmandu.yml
---
store:
  test1:
   package: MongoDB
   options:
    database_name: mydb
  test2:
   package: ElasticSearch
   options:
    index_name: mydb
  test3:
   package: Solr
   options:
    url: http://localhost:8983/solr

  $ catmandu import JSON to test1 < records.json # Mongo
  $ catmandu import MARC to test2 < records.mrc  # ElasticSearch
  $ catmandu import YAML to test3 < records.yaml # Solr
  $ catmandu export test1 to JSON                # Mongo
  $ catmandu export test2 to JSON                # ElasticSearch
  $ catmandy export test3                        # Solr very lazy JSON is the default exporter and importer
  $ cat fixes.txt
marc_map("245a","title");
marc_map("100","author.$append");
join("author",";");
marc_map("008_/10-13","language");
  $ catmandu import MARC to test2 --fix fixes.txt
{% endhighlight %}


### Fixes
{% highlight perl %}
# Fixes clean your data. As input you get a Perl HASH. Each fix function is a command
# to transform the Perl HASH. Some fixes such as marc_map contain logic to transform
# complex data structures such as MARC.
set_field("my.name","patrick");            # { my => { name => 'Patrick'} }
add_field("my.name2","nicolas"); 
move_field("my.name","your.name");
copy_field("your.name","your.name2");
remove_field("your.name");

upcase("title");                           # marc -> MARC
downcase("title");                         # MARC -> marc
capitalize("my.deeply.nested.field.0");    # marc -> Marc
trim("field_with_spaces");                 # "  marc  " -> marc
substring("title",0,1);                    # marc -> m
prepend("title","die ");                   # marc -> die marc
append("title"," must die");               # marc -> marc must die
lookup("title","dict.csv",-sep_char=>'|')  # lookup 'marc' in dict.csv and replace the value

split_field("foo",":");                    # marc:must:die -> ['marc','must','die']
join_field("foo",":");                     # ['marc','must','die'] -> marc:must:die
retain_field("id");                        # delete any field except 'id'
replace_all("title","a","x");              # marc -> mxrc

# Most functions can work also work on arrays. E.g.
replace_all("author.*","a","x");           # [ 'marc','jan'] => ['mxrc','jxn']
# Use:
#   authors.$end (last entry)
#   authors.$start (first entry)
#   authors.$append (last + 1)
#   authors.$prepend (first - 1)
#   authors.* (all authors)
#   authors.2 (3rd author)

collapse();                                # collapse deep nested hash to a flat hash
expand();                                  # expand flat hash to deep nested hash
clone();                                   # clone the perl hash and work on the clone

# Copy all 245 subfields into the my.title hash
marc_map('245','my.title');
# Copy the 245-$a$b$c subfields into the my.title hash
marc_map('245abc','my.title');
# Copy the 100 subfields into the my.authors array
marc_map('100','my.authors.$append');
# Add the 710 subfields into the my.authors array
marc_map('710','my.authors.$append');
# Copy the 600-$x subfields into the my.subjects array while packing each into a genre.text hash
marc_map('600x','my.subjects.$append.genre.text');
# Copy the 008 characters 35-35 into the my.language hash
marc_map('008_/35-35','my.language');
# Copy all the 600 fields into a my.stringy hash joining them by '; '
marc_map('600','my.stringy', -join => '; ');
# When 024 field exists create the my.has024 hash with value 'found'
marc_map('024','my.has024', -value => 'found');
# Do the same examples now with the marc fields in 'record2'
marc_map('245','my.title', -record => 'record2');

# uppercase the value of field 'foo' if all members of 'oogly' have the value 'doogly'
if_all_match('oogly.*', 'doogly');
  upcase('foo'); # foo => 'BAR'
end();
# inverted
unless_all_match('oogly.*', 'doogly');
  upcase('foo'); # foo => 'BAR'
end();

# uppercase the value of field 'foo' if field 'oogly' has the value 'doogly'
if_any_match('oogly', 'doogly');
  upcase('foo'); # foo => 'BAR'
end();
# inverted
unless_any_match('oogly', 'doogly');
  upcase('foo'); # foo => 'BAR'
end();

# uppercase the value of field 'foo' if the field 'oogly' exists
if_exists('oogly');
  upcase('foo'); # foo => 'BAR'
end();
# inverted
unless_exists('oogly');
  upcase('foo'); # foo => 'bar'
end();


{% endhighlight %}
