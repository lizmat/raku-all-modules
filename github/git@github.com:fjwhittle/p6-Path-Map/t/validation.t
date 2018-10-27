use v6;

use Test;
use Path::Map;

plan 9;

my $mapper = Path::Map.new;

$mapper.add_handler('foo/:bar', 'Constrained', :bar({ try { +$_  ~~ Int } }));
$mapper.add_handler('bar', 'Unconstrained');

ok $mapper.lookup('foo/42').?handler ~~ 'Constrained',
  q{lookup('foo/42') mapped to Constrained.};

ok $mapper.lookup('bar').?handler ~~ 'Unconstrained',
  q{lookup('bar') mapped to Unconstrained};

ok !defined($mapper.lookup('foo/bar')),
  q{lookup('foo/bar') does not match with no fallback.};

$mapper.add_handler('foo/*', 'Wildcard');

ok $mapper.lookup('foo/bar').?handler ~~ 'Wildcard',
  q{lookup('foo/bar') matches with wildcard fallback.};

ok $mapper.lookup('foo/42').?handler ~~ 'Constrained',
  q{lookup('foo/42') mapped to Constrained with wildcard fallback.};

$mapper.add_handler('foo/:baz', 'Regex Constrained', :baz({ try { $_ ~~ / 'hello-' [ 'world' || 'perl6' ] / } }));

ok $mapper.lookup('foo/42').?handler ~~ 'Constrained',
  q{lookup('foo/42') mapped to Constrained with multiple constraints.};

ok $mapper.lookup('foo/hello-perl6').?handler ~~ 'Regex Constrained',
  q{lookup('foo/hello-perl6') mapped to 'Regex Constrained'.};

ok $mapper.lookup('foo/hello-wombat').?handler ~~ 'Wildcard',
  q{lookup('foo/hello-wombat') fell through to Wildcard.};

$mapper.add_handler('pony/:breed', 'Magical', :breed( -> $breed is rw { $breed = :unicorn«$breed»; }));

ok $mapper.lookup('pony/Newfoundland').variables<breed> ~~ :unicorn<Newfoundland>, 'Pony converted to unicorn.';
