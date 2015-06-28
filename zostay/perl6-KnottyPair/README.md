NAME
====

KnottyPair - A subclass of Pair with binding on values

SYNOPSIS
========

    use KnottyPair;

    # Like a Pair a => 1, but you must quote the left hand side. This usage is
    # basically equivalent to a regular Pair.
    my $kp = 'a' =x> 1;
    say "TRUE" if $kp ~~ KnottyPair; #> TRUE
    say "TRUE" if $kp ~~ Pair;       #> TRUE

    # Uppercase =X> version performs a binding operaiton
    my $x = 41;
    my $answer = 'Life, Universe, Everything' =X> $x;
    $x++;
    say "The answer to {$answer.key} is {$answer.value}.";
    #> The answer to Life, Universe, Everything is 42.

    sub slurpy-test(*@a, *%h) {
        say "a = ", @a.perl;
        say "h = ", %h.perl;
    }

    # Normal pairs are passed through as named args
    slurpy-test(a => 1, b => 2, c => 3);
    #> a = []<>
    #> h = {:a(1), :b(2), :c(3)}<>

    # Knotty pairs are pass through as positional args
    slurpy-test('a' =x> 1, 'b' =x> 2, 'c' =x> 3);
    #> a = ["a" =x> 1, "b" =x> 2, "c" =x> 3]<>
    #> h = {}<>

DESCRIPTION
===========

For certain data structures, I find some aspects of the built-in [Pair](Pair) to be inconvenient. Pairs are closely tied to [Associative](Associative) data structures and there are several ways in which the Perl 6 language treats them specially. This is fine. This is good, but sometimes, I want a Pair that's exempt from some of that and sometimes I want a Pair that can be bound to a value in the same way a [Hash](Hash) key may be bound. The built-in Pairs cannot do that.

METHODS
=======

method new
----------

    method new(:$key, :$value) returns KnottyPair:D;

This is the constructor for creating a new KnottyPair. However, you will probably use the `=x> ` and `=X> ` operators instead most of the time.

method key
----------

    method key(KnottyPair:D:) returns Mu

Returns the key value. This can be any kind of object. It is not assumed to be a string.

method value
------------

    method value(KnottyPair:D:) is rw returns Mu

Returns the value of the pair. This can be any kind of object. You may also assign to this value. (However, if you want to bind, you need to see [#method bind-value](#method bind-value).

method antipair
---------------

    method antipair(KnottyPair:D:) returns KnottyPair:D

Returns a new KnottyPair object with the key and value swapped.

method keys
-----------

    method keys(KnottyPair:D:) returns List:D

Returns a single value list containing the key.

method kv
---------

    method kv(KnottyPair:D:) returns List:D

Returns the key and value as two elements of a list.

method values
-------------

    method values(KnottyPair:D:) returns List:D

Returns the value in a single value list.

method pairs
------------

    method pairs(KnottyPair:D:) returns List:D

Returns the object itself in a single value list.

method antipairs
----------------

    method antipairs(KnottyPair:D:) returns List:D

Returns the result of [#method antipair](#method antipair) in a single value list.

method invert
-------------

    method invert(KnottyPair:D:) returns List:D

Returns the result of [#method antipair](#method antipair) in a single value list.

method Str
----------

    method Str(KnottPair:D:) returns Str:D

Returns a string containing the stringified key and value separated by a tab.

method gist
-----------

    method gist(KnottyPair:D:) returns Str:D

Returns a string containing the key and value gists joined by `=x> `.

method perl
-----------

    method perl(KnottyPair:D:) returns Str:D

method fmt
----------

    method fmt(KnottyPair:D: Str $format = "%s\t%s") returns Str:D

Given a printf-style format, returns the key/value pair formatted as requested.

adverb :exists
--------------

You may use the `:exists` adverb to test for the existence of a key when using an hash lookup or slice. Returns true only for the key returned by [#method key](#method key).

method ACCEPTS
--------------

    multi method ACCEPTS(KnottyPair:D: %h) returns Bool:D
    multi method ACCEPTS(KnottyPair:D: Mu $other) returns Bool:D

Allows this object to be applied to smart match against other objects. 

  * When applied to a hash, it returns true as long as the hash, `%h`, contains a value at the key matching this key in a lookup that matches against this KnottyPair's value.

  * When applied to anything else, it attempts to test the methdo named for the KnottyPair's key and see if it's boolean value matches the boolean value of the KnottyPair's value.

method postcircumfix:<{ }>
--------------------------

    method postcircumfix:<{ }> (KnottyPair:D: Mu $key) is rw returns Mu

Performs a lookup on the pair. Returns an [Any](Any) type object unless `$key` is structurally equivalent (i.e., using `eqv`) to the KnottyPair's key, in which case it returns the value. You may also assign to this value or even bind using the associative lookup operator.

method bind-value
-----------------

    method bind-value(KnottyPair:D: $new is rw)

This causes the variable passed to be bound to the KnottyPair's value.

OPERATORS
=========

method infix:«=x>»
------------------

    method infix:«=x>» (Mu $key, Mu $value) returns KnottyPair:D

This is the assignment constructor for KnottyPair. The `$value` will not be bound.

method infix:«=X>»
------------------

    method infix:«=X>» (Mu $key, Mu $value is rw) returns KnottyPair:D

This is teh binding constructor for KnottyPair. The `$value` will be bound to the given value.
