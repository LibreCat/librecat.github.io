# LibreCat Homepage

[This git repository](https://github.com/LibreCat/librecat.github.io) contains
the main part of LibreCat homepage. View it live at <http://librecat.org/>!

The homepage is build with [Jekyll](http://jekyllrb.com/) from static files.

## Local usage

See [GitHub pages](https://help.github.com/articles/using-jekyll-with-pages/)
for local usage of this homepage.

## Install and run jekyll

    bundle install
    jekyll serve

## Deployment

Pushing to GitHub will update the page <http://librecat.org/> except
<http://librecat.org/Catmandu/>.  The latter published via the `gh-pages`
branch of repository <https://github.com/LibreCat/Catmandu> from the
[Catmandu wiki](https://github.com/LibreCat/Catmandu/wiki). To update
and publish this part of the site:

     make -C wiki/book publish
