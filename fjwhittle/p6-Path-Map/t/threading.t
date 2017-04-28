use v6;

use Test;

use Path::Map;

plan 2;

my $mapper = Path::Map.new();

# Sleeping in the validator forces the first handler to keep its Promise later than the second
$mapper.add_handler('/foo/:bar', 'the one', :bar({ sleep 1/10; +$_ ~~ (Int) }));
$mapper.add_handler('/foo/:baz', 'not the one', :baz({ True }));

ok $mapper.lookup('/foo/42').?handler eq 'the one', 'deterministic resolution order';
ok $mapper.lookup('/foo/bar').?handler eq 'not the one', 'skip constraint';
