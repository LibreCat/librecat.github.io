# LibreCat Homepage

[This git repository](https://github.com/LibreCat/librecat.github.io) contains
the main part of LibreCat homepage. View it live at <http://librecat.org/>!

Catmandu documentation (<http://librecat.org/Catmandu>) is managed in  
[Catmandu wiki](https://github.com/LibreCat/Catmandu/wiki).

## Local usage

See [GitHub pages documentation](https://help.github.com/articles/using-jekyll-with-pages/)
for local usage of this homepage. To also include Catmandu documentation 

    git clone https://github.com/LibreCat/Catmandu.wiki.git wiki
    ln -s wiki/book Catmandu
    cd wiki; make # build HTML documentation

