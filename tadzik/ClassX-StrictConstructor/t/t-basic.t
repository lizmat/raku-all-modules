use Test;
use ClassX::StrictConstructor;

plan 10;

class Standard {
    has $.thing;
}

class Stricter does ClassX::StrictConstructor {
    has $.thing;
}

class Subclass is Stricter does ClassX::StrictConstructor {
    has $.size;
}

class StrictSubclass is Stricter {
    has $.size;
}

class OtherStrictSubclass is Standard does ClassX::StrictConstructor {
    has $.size;
}

class Tricky does ClassX::StrictConstructor {
    has $.thing;
    
    method new(*%attrs) {
        %attrs<spy>:delete;
        self.ClassX::StrictConstructor::new(|%attrs);
    }
}

lives_ok { Standard.new(thing => 1, bad => 99) }, 'standard class ignores unknown arguments';
throws_like { Stricter.new(thing => 1, bad => 99) }, X::UnknownAttribute;
lives_ok { Subclass.new(thing => 1, size => 'large') },
         'subclass constructor handles known attributes correctly';
throws_like { Subclass.new(thing => 1, bad => 99) }, X::UnknownAttribute;
lives_ok { StrictSubclass.new(thing => 1, size => 'large') },
         "subclass that doesn't use strict correctly recognizes bad attribute";
throws_like { StrictSubclass.new(thing => 1, bad => 99) }, X::UnknownAttribute;
lives_ok { OtherStrictSubclass.new(thing => 1, size => 'large') },
         "strict subclass from parent that doesn't use strict constructor handles known "
         ~ "attributes correctly";
throws_like { OtherStrictSubclass.new(thing => 1, bad => 99) }, X::UnknownAttribute;
lives_ok { Tricky.new(thing => 1, spy => 99) },
         'can work around strict constructor by deleting params in new()';
throws_like { Tricky.new(thing => 1, agent => 99) }, X::UnknownAttribute;

# MooseX::StrictConstructor InitArg tests are not here, because nothing like init_arg
# exists in Perl 6
