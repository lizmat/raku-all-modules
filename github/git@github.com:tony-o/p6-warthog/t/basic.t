use Test;
use System::Query;
use JSON::Fast;

plan 2;

is-deeply(system-collapse(${foo => {bar => {'baz' => 'qux'}}}), ${foo => {bar => {baz => 'qux'}}});

my $json = from-json( 't/data/basic.json'.IO.slurp );
if $*DISTRO.name eq qw<macosx win32>.any {
  is-deeply(system-collapse($json), from-json( "t/data/basic-{$*DISTRO.name}.json".IO.slurp ));
} else {
  dies-ok -> { system-collapse($json); }
}
