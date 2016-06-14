use JSON::Fast;
my $Config;

sub EXPORT (Str:D $config-file = 'config.json') {
    $Config = from-json $config-file.IO.slurp;
    return {
        '&trait_mod:<is>' => &trait_mod:<is>,
    };
}

multi sub trait_mod:<is> (Variable $v, :$from-config!) {
    my ( $sigil, $name ) = .substr(0,1), .substr(1) given $v.var.VAR.name;
    $name = "$sigil$name" unless $sigil eq '$' | '%' | '@';

    $Config{ $name }:exists or die 'Unknown configuration variable';
    my $conf-val = $Config{ $name };

    $v.var = $sigil eq '%' ?? %$conf-val
        !! $sigil eq '@' ?? @$conf-val !! $conf-val;
}
