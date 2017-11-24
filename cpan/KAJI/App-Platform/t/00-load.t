use v6;
use lib 'lib';
use Test;
use JSON::Tiny;

my $content = "META6.json".IO.slurp;
my %data = from-json($content);
for %data{'provides'}.kv -> $key, $val {
    use-ok $key, "load $val";
}

done-testing;

