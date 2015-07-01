use v5.14;
use Catmandu -all, -load;

my $modules = { };

importer('default', file => '_data/distributions.json')->each(sub {
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

exporter('default', file => '_data/modules.json')->add($modules);

