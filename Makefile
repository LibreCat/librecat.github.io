.PHONY: local _data/distributions.json

data: _data/modules.json

# collect information about all Catmandu distributions
_data/distributions.json:
	perl -Ilocal/lib/perl5 distributions.pl
 
_data/modules.json: _data/distributions.json
	perl -Ilocal/lib/perl5 modules.pl

# update date in _config.yml if _data/ has uncommitted changes 
date:
	if [ "$$(git status --porcelain 2>/dev/null _data)" ]; then \
	   sed -i "s/^date:.*$$/date: $$(TZ=UTC date '+%Y-%m-%d %H:%M %Z')/" _config.yml; \
	fi

# install missing modules to local/
local:
	cpanm -l local --skip-satisfied --installdeps .

# locally serve with Jekyll
serve:
	bundle exec jekyll serve --port 6666
