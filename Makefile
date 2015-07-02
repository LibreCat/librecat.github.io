.PHONY: local _data/distributions.json

distributions: _data/modules.json

# collect information about all Catmandu distributions
_data/distributions.json:
	perl -Ilocal/lib/perl5 distributions.pl
 
_data/modules.json: _data/distributions.json
	perl -Ilocal/lib/perl5 modules.pl

# install missing modules to local/
local:
	cpanm -l local --skip-satisfied --installdeps .

# locally serve with Jekyll
serve:
	bundle exec jekyll serve --port 6666
