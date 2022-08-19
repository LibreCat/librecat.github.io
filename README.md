# LibreCat Homepage

[This git repository](https://github.com/LibreCat/librecat.github.io) contains
the main part of LibreCat homepage. View it live at <http://librecat.org/>!

The homepage is build with [Jekyll](http://jekyllrb.com/) from static files.
Some parts ([Catmandu Documentation](http://librecat.org/Catmandu) and overview
of [Catmandu Distributions](http://librecat.org/distributions.html) are
dynamically build for updates.

## Local usage

See [GitHub pages](https://help.github.com/articles/using-jekyll-with-pages/)
for local usage of this homepage.

To build **Catmandu Documentation**, clone the
[Catmandu wiki](https://github.com/LibreCat/Catmandu/wiki):

    git clone https://github.com/LibreCat/Catmandu.wiki.git wiki
    ln -s wiki/book Catmandu
    cd wiki/book; make # build HTML documentation

To update **Catmandu Distributions** install
[Catmandu](https://metacpan.org/release/Catmandu) and run:

    make local  # once or when update script changed
    make data
    make date

Information about Catmandu Distributions is build in directory `_data` and must
be committed to update the website:

    git add _data _config.yml
    git commit -m "autoupdate distributions"
    git push

## Install and run jekyll

    bundle install
    jekyll serve

## Deployment

Pushing to GitHub will update the page <http://librecat.org/> except
<http://librecat.org/Catmandu/>.  The latter published via the `gh-pages`
branch of repository <https://github.com/LibreCat/Catmandu> from the
[Catmandu wiki](https://github.com/LibreCat/Catmandu/wiki).
