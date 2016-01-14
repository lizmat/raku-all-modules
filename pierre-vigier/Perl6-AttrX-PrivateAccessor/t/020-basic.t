use v6;
use Test;
use AttrX::PrivateAccessor;

plan 2;

class Teenager {
    has $!diary is providing-private-accessor;

    method init( $value ) {
        $!diary = $value;
    }

    method inspect(Teenager:D: Teenager $other) {
        return $other!diary;
    }
}

my $bob = Teenager.new();
$bob.init( "bob's diary" );
my $steve = Teenager.new();
$steve.init( "steve's diary" );

dies-ok { $bob.diary }, "No public method";
is $steve.inspect( $bob ), "bob's diary", "Can access other instance's private attributes";

#TODO: test duplicate method, private vs public, ...
