# perl version
requires 'perl','>=5.10.1';

# modules
requires 'Catmandu'; # libcatmandu-perl
requires 'Catmandu::Importer::CPAN';
requires 'Catmandu::Importer::getJSON', '0.50';
requires 'Mozilla::CA';
requires 'LWP::Simple';

# cpanm -l local --skip-satisfied --installdeps .
