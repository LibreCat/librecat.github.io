use v5.14;
use Catmandu -all, -load;

my $modules = { };

importer('YAML', file => '_data/distributions.yml')->each(sub {
    my $d = shift;
    foreach (@{$d->{provides}}) {
        next unless /^Catmandu::(Importer|Exporter|Store|Fix)::([^:]+)$/;
        push @{$modules->{$1}}, $2;
    }
});

foreach my $ns ( keys %$modules ) {
    $modules->{$ns} = [
        map { {
            name => $_,
            module => "Catmandu::${ns}::$_",
        } }
        sort @{ $modules->{$ns} }
    ]
}

exporter('YAML', file => '_data/modules.yml')->add($modules);
