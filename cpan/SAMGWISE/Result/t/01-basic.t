use v6.c;
use Test;
use lib 'lib';
plan 4;

use-ok 'Result::Imports';
use Result::Imports;

my $result = Result::OK.new( :value('test') :type(Str) );
is $result.defined, True, "Create defined Result::OK";
is $result.ok('testing'), 'test', "Result:OK resolves value";

$result = Result::Err.new( "I'm an error!" );
#is $result.defined, True, "Create defined Result::Err"; # Failure objects allways return false if not handled
dies-ok { $result.ok('testing') }, "Result:Err dies on resolution";
