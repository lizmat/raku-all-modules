unit class KnottyPair is Pair;

use v6;

=NAME KnottyPair - A subclass of Pair with binding on values

=begin SYNOPSIS

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

=end SYNOPSIS

=begin DESCRIPTION

For certain data structures, I find some aspects of the built-in L<Pair> to be inconvenient. Pairs are closely tied to L<Associative> data structures and there are several ways in which the Perl 6 language treats them specially. This is fine. This is good, but sometimes, I want a Pair that's exempt from some of that and sometimes I want a Pair that can be bound to a value in the same way a L<Hash> key may be bound. The built-in Pairs cannot do that.

=end DESCRIPTION

=begin pod

=head1 METHODS

=head2 method new

    method new(:$key, :$value) returns KnottyPair:D;

This is the constructor for creating a new KnottyPair. However, you will probably use the C<< =x> >> and C<< =X> >> operators instead most of the time.

=head2 method key

    method key(KnottyPair:D:) returns Mu

Returns the key value. This can be any kind of object. It is not assumed to be a string.

=head2 method value

    method value(KnottyPair:D:) is rw returns Mu

Returns the value of the pair. This can be any kind of object. You may also assign to this value. (However, if you want to bind, you need to see L<#method bind-value>.

=head2 method antipair

    method antipair(KnottyPair:D:) returns KnottyPair:D

Returns a new KnottyPair object with the key and value swapped.

=head2 method keys

    method keys(KnottyPair:D:) returns List:D

Returns a single value list containing the key.

=head2 method kv

    method kv(KnottyPair:D:) returns List:D

Returns the key and value as two elements of a list.

=head2 method values

    method values(KnottyPair:D:) returns List:D

Returns the value in a single value list.

=head2 method pairs

    method pairs(KnottyPair:D:) returns List:D

Returns the object itself in a single value list.

=head2 method antipairs

    method antipairs(KnottyPair:D:) returns List:D

Returns the result of L<#method antipair> in a single value list.

=head2 method invert

    method invert(KnottyPair:D:) returns List:D

Returns the result of L<#method antipair> in a single value list.

=head2 method Str

    method Str(KnottPair:D:) returns Str:D

Returns a string containing the stringified key and value separated by a tab.

=head2 method gist

    method gist(KnottyPair:D:) returns Str:D

Returns a string containing the key and value gists joined by C<< =x> >>.

=head2 method perl

    method perl(KnottyPair:D:) returns Str:D

=head2 method fmt

    method fmt(KnottyPair:D: Str $format = "%s\t%s") returns Str:D

Given a printf-style format, returns the key/value pair formatted as requested.

=head2 adverb :exists

You may use the C<:exists> adverb to test for the existence of a key when using an hash lookup or slice. Returns true only for the key returned by L<#method key>.

=head2 method ACCEPTS

    multi method ACCEPTS(KnottyPair:D: %h) returns Bool:D
    multi method ACCEPTS(KnottyPair:D: Mu $other) returns Bool:D

Allows this object to be applied to smart match against other objects. 

=item When applied to a hash, it returns true as long as the hash, C<%h>, contains a value at the key matching this key in a lookup that matches against this KnottyPair's value.

=item When applied to anything else, it attempts to test the methdo named for the KnottyPair's key and see if it's boolean value matches the boolean value of the KnottyPair's value.

=head2 method postcircumfix:<{ }>

    method postcircumfix:<{ }> (KnottyPair:D: Mu $key) is rw returns Mu

Performs a lookup on the pair. Returns an L<Any> type object unless C<$key> is structurally equivalent (i.e., using C<eqv>) to the KnottyPair's key, in which case it returns the value. You may also assign to this value or even bind using the associative lookup operator.

=head2 method bind-value

    method bind-value(KnottyPair:D: $new is rw)

This causes the variable passed to be bound to the KnottyPair's value.

=head1 OPERATORS

=head2 method infix:«=x>»

    method infix:«=x>» (Mu $key, Mu $value) returns KnottyPair:D

This is the assignment constructor for KnottyPair. The C<$value> will not be bound.

=head2 method infix:«=X>»

    method infix:«=X>» (Mu $key, Mu $value is rw) returns KnottyPair:D

This is teh binding constructor for KnottyPair. The C<$value> will be bound to the given value.

=end pod

has $.knotty-key;
has $.knotty-value is rw;

method key(KnottyPair:D:) { $!knotty-key }
method value(KnottyPair:D:) is rw { $!knotty-value }

submethod BUILD(KnottyPair:D: $key, $value) {
    $!knotty-key   = $key;
    $!knotty-value = $value;
    self;
}

method antipair(KnottyPair:D:) { self.new(key => $!knotty-value, value => $!knotty-key) }

multi method keys(KnottyPair:D:)      { ($!knotty-key,).list }
multi method kv(KnottyPair:D:)        { $!knotty-key, $!knotty-value }
multi method values(KnottyPair:D:)    { ($!knotty-value,).list }
multi method pairs(KnottyPair:D:)     { (self,).list }
multi method antipairs(KnottyPair:D:) { self.new(key => $!knotty-value, value => $!knotty-key) }
multi method invert(KnottyPair:D:)    { (KnottyPair.new($!knotty-value, $!knotty-key),).list }

multi method Str(KnottyPair:D:) { $!knotty-key ~ "\t" ~ $!knotty-value }

multi method gist(KnottyPair:D:) {
    $!knotty-key.gist ~ ' =x> ' ~ $!knotty-value.gist;
}

multi method perl(KnottyPair:D:) {
    $!knotty-key.perl ~ ' =x> ' ~ $!knotty-value.perl;
}

method fmt(KnottyPair:D: $format = "%s\t%s") {
    sprintf($format, $!knotty-key, $!knotty-value);
}

multi method EXISTS-KEY(KnottyPair:D: $key) { $key eqv $!knotty-key }

multi method ACCEPTS(KnottyPair:D: %h) {
    $.knotty-value.ACCEPTS(%h{$.knotty-key});
}

multi method ACCEPTS(KnottyPair:D: Mu $other) {
    $other."$.knotty-key"().Bool === $.knotty-value.Bool
}

multi method AT-KEY(KnottyPair:D: $key) { 
    $key eqv $.knotty-key ?? $!knotty-value !! Any
}

multi method ASSIGN-KEY(KnottyPair:D: $key, $value) {
    if $key eqv $.knotty-key {
        $!knotty-value = $value;
    }
}

multi method BIND-KEY(KnottyPair:D: $key, $value is rw) {
    if $key eqv $.knotty-key {
        $!knotty-value := $value;
    }
}

method bind-value(KnottyPair:D: $new is rw) {
    $!knotty-value := $new;
}

our sub infix:«=x>» ($key, $value) is export {
    KnottyPair.new(:$key, :$value);
}

our sub infix:«=X>» ($key, $value is rw) is export {
    my $pair = KnottyPair.new(:$key, value => Any);
    $pair.bind-value($value);
    $pair;
}
