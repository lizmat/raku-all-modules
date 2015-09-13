unit class Hash::MultiValue is Associative;

use v6;

=TITLE Hash::MultiValue

=SUBTITLE Store multiple values per key, but act like a regular hash too

=begin SYNOPSIS

    my %mv := Hash::MultiValue.from-pairs: (a => 1, b => 2, c => 3, a => 4);
    
    say %mv<a>; # 4
    say %mv<b>; # 2

    say %mv('a').join(', '); # 1, 4
    say %mv('b').join(', '); # 2

    %mv<a>   = 5;
    %mv<d>   = 6;
    %mv('e') = 7, 8, 9;

    say %mv.all-pairs».fmt("%s: %s").join("\n");
    # a: 5
    # b: 2
    # c: 3
    # d: 6
    # e: 7
    # e: 8
    # e: 9

=end SYNOPSIS

=begin DESCRIPTION

This class is useful in cases where a program needs to have a hash that may or may not have multiple values per key, but frequently assumes only one value per key. This is commonly the case when dealing with URI query strings. This class also generally preserves the order the keys are encountered, which can also be a useful characteristic when working with query strings.

If some code is handed this object where a common L<Associative> object (like a L<Hash>) is expected, it will work as expected. Each value will only have a single value available. However, when one of these objects is used as function or using the various C<.all-*> alternative methods, the full multi-valued contents of the keys can be fetched, modified, and iterated.

=end DESCRIPTION

=head1 Methods

has @.all-pairs; #= Stores all keys and values for the hash
has %.singles = @!all-pairs.hash; #= Stores a simplified version of the hash with all keys, but only the last value

multi method add-pairs(@new is copy) {
    for @!all-pairs.kv -> $i, $v {
        next if $v.defined;
        @!all-pairs[$i] = @new.shift;
        last unless @new;
    }

    @!all-pairs.push: @new;
}

multi method add-pairs(*@new) {
    self.add-pairs(@new);
}

=begin pod
=head2 method from-pairs

    multi method from-pairs(@pairs) returns Hash::MultiValue
    multi method from-pairs(*@pairs) returns Hash::MultiValue

This takes a list of pairs and constructs a L<Hash::MultiValue> object from it. Use this method or L</method from-mixed-hash> instead of L</new>. Multiple pairs with the same key may be included in this list and all values will be associated with that key. 

Please note, that because of the way Perl 6 handles pairs in slurpy context, you may need to wrap them in a list for this to work:

    # THIS
    my %h := Hash::MultiValue.from-pairs: (a => 1, b => 2);
    # NOT this
    my %h := Hash::MultiValue.from-pairs(a => 1, b => 2);

=end pod

#| Construct a Hash::MultiValue object from an list of pairs
multi method from-pairs(@pairs) returns Hash::MultiValue {
    self.bless(all-pairs => @pairs);
}

#| Construct a Hash::MultiValue object from a list of pairs
multi method from-pairs(*@pairs) returns Hash::MultiValue {
    self.bless(all-pairs => @pairs);
}

=begin pod
=head2 method from-mixed-hash

    multi method from-mixed-hash(%hash)
    multi method from-mixed-hash(*%hash)

This takes a hash and constructs a new L<Hash::MultiValue> from it. If any value in the hash is L<Positional>, it will be interpreted as a multi-valued key. If you need Positional objects preserved as values, then you'll have to use L</method from-pairs> instead and build your own list of pairs for construction. That method is more precise.

=end pod

#| Construct a Hash::MultiValue object from a mixed value hash
multi method from-mixed-hash(%hash) returns Hash::MultiValue {
    my @pairs = do for %hash.kv -> $k, $v {
        given $v {
            when Positional { .map($k => *).Slip }
            default         { $k => $v }
        }
    }
    self.bless(all-pairs => @pairs);
}

#| Construct a Hash::MultiValue object from a mixed value hash
multi method from-mixed-hash(*%hash) returns Hash::MultiValue {
    my $x = self.from-mixed-hash(%hash); # CALLWITH Y U NO WORK???
    return $x;
}

=begin pod
=head2 method postcircumfix:<{ }>

    method postcircumfix:<{ }> (%key) is rw

Whenever reading or writing keys using the C<{ }> operator, the hash will behave as a regular built-in L<Hash>. Any write will overwrite all values that have been set on the multi-value hash with a single value. 

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    %mv<a> = 4;
    say %mv('a').join(', '); # 4

Any read will only read a single value, even if multiple values are stored for that key. 

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv<a>; # 3

Of those values the last value will always be used. This is in keeping with the usual semantics of what happens when you add two pairs with the same key twice in Perl 6.

You may also use the C<:delete> and C<:exists> adverbs with these objects.

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv<a> :delete; # 3 (both 1 and 3 are gone)
    say %mv<b> :exists; # True

One operation that is B<not> supported by L<Hash::MultiValue> is binding. For example,

    my $a = 4;
    %mv<a> := $a;
    $a = 5;
    say %mv<a>; # 4

Binding is not supported at this time, but might be in the future.

=end pod

method AT-KEY($key) { 
    %!singles{$key} 
}

method ASSIGN-KEY($key, $value) { 
    @!all-pairs[ @!all-pairs.grep-index({ .defined && .key eqv $key }) ] :delete;
    self.add-pairs(($key => $value).list);
    %!singles{$key} = $value;
    $value;
}

# Not supported, since Pair values can't be bound
# method BIND-KEY($key, $value is rw) { 
#     @!all-pairs = @!all-pairs.grep(*.key !eqv $key);
#     @!all-pairs.push: $key => $value;
#     %!singles{$key} := $value;
# }

method DELETE-KEY($key) {
    @!all-pairs[ @!all-pairs.grep-index({ .defined && .key eqv $key }) ] :delete;
    %!singles{$key} :delete;
}

method EXISTS-KEY($key) {
    %!singles{$key} :exists;
}

=begin pod
=head2 method postcircumfix:<( )>

    method postcircumfix:<( )> ($key) is rw

The C<( )> operator may be used in a fashion very similar to C<{ }>, but in that it always works with multiple values. You may use it to read multiple values from the object:

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv('a').join(', '); # 1, 3

You may also use it to write multiple values, which will replace all values currently set for that key:

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    %mv('a') = 4, 5;
    %mv('b') = 6, 7;
    %mv('c') = 8;
    say %mv('a').join(', '); # 4, 5
    say %mv('b').join(', '); # 6, 7
    say %mv('c').join(', '); # 8

At this time, this operator does not support slices (i.e., using a L<Range> or L<List> of keys to get values for more than one key at once). This might be supported in the future.
=end pod

method postcircumfix:<( )>($key) is rw {
    my $self = self;
    my @all-pairs := @!all-pairs;
    Proxy.new(
        FETCH => method () { 
            @(@all-pairs.grep({ .defined && .key eqv $key })».value)
        },
        STORE => method (*@new) {
            @all-pairs[ @all-pairs.grep-index({ .defined && .key eqv $key }) ] :delete;
            $self.add-pairs: @new.map($key => *);
            $self.singles{$key} = @new[*-1];
            @new
        },
    )
}

=begin pod
=head2 method kv

Returns a list alternating between key and value. Each key will only be listed once with a singular value. See L</method all-kv> for a multi-value version.

=head2 method pairs

Returns a list of L<Pair> objects. Each key is returned just once pointing to the last (or only) value in the multi-value hash. See L</method all-pairs> for the multi-value version.

=head2 method antipairs

This is identical to L</method pairs>, but with the value and keys swapped.

=head2 method invert

This is a synonym for L</method antipairs>.

=head2 method keys

Returns a list of keys. Each key is returned exactly once. See L</method all-keys> for the multi-value version.

=head2 method values

Returns a list of values. Only the last value of a multi-value key is returned. See L</method all-values> for the multi-value version.

=end pod

method kv { %!singles.kv }
method pairs { %!singles.pairs }
method antipairs { %!singles.antipairs }
method invert { %!singles.invert }
method keys { %!singles.keys }
method values { %!singles.values }
method elems { %!singles.elems }

=begin pod
=head2 method all-kv

Returns a list alternating between key and value. Multi-value key will be listed more than once.

=head2 method all-pairs

Returns a list of L<Pair> objects. Multi-value keys will be returned multiple times, once for each value associated with the key.

=head2 method all-antipairs

This is identical to L</method all-pairs>, but with key and value reversed.

=head2 method all-invert

This is a synonym for L</method all-antipairs>.

=head2 method keys

This returns a list of keys. Multi-valued keys will be returned more than once. If you want the unique key list, you want to see L</method keys>.

=head2 method values

This returns a list of all values, including the multiple values on a single key.

=end pod

method all-kv { flat @!all-pairs».kv }
method all-pairs { flat @!all-pairs }
method all-antipairs { flat @!all-pairs».invert }
method all-invert { flat @!all-pairs».antipair }
method all-keys { flat @!all-pairs».key }
method all-values { flat @!all-pairs».value }
method all-elems { @!all-pairs.elems }

=begin pod
=head2 method push

    method push(*@values)

This adds new pairs to the list. Any pairs given with a key matching an existing key will cause the single value version of that key to be replaced with the new value. This never overwrites existing values.

=end pod

method push(*@values) {
    my %new-singles;
    my ($previous, Bool $has-previous);
    for @values -> $v {
        if $has-previous {
            self.add-pairs: $previous => $v;
            %new-singles{ $previous } = $v;

            $has-previous--;
        }
        elsif $v ~~ Enum {
            self.add-pairs: $v.key => $v.value;
            %new-singles{ $v.key } = $v.value;
        }
        else {
            $has-previous++;
            $previous = $v;
        }
    }

    if ($has-previous) {
        warn "Training item in Hash::MultiValue.push";
    }

    %!singles = flat %!singles, %new-singles;
}

# For future consideration
# method classify-list ...
# method categorize-list ...

=begin pod
=head2 method perl

Returns code as a string that can be evaluated with C<EVAL> to recreate the object.
=end pod

multi method perl(Hash::MultiValue:D:) returns Str { 
    "Hash::MultiValue.from-pairs(" 
        ~ @!all-pairs.grep(*.defined).sort(*.key cmp *.key).map(*.perl).join(", ") 
        ~ ")"
}

=begin pod
=head2 method gist

Like L</method perl>, but only includes up to the first 100 keys.

=end pod

multi method gist(Hash::MultiValue:D:) {
    "Hash::MultiValue.from-pairs(" ~ 
        @!all-pairs.grep(*.defined).sort(*.key cmp *.key).map(-> $elem {
            given ++$ {
                when 101 { '...' }
                when 102 { last }
                default { $elem.gist }
            }
        }).join(", ") ~ ")"
}
