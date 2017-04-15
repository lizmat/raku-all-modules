unit class Hash::MultiValue:ver<0.4>:auth<github:zostay> is Associative;

use v6;

=NAME Hash::MultiValue - Store multiple values per key, but act like a regular hash too

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

This class makes no guarantees to preserve the order of keys. However, the order of the multiple values stored within a key is guaranteed to be preserved. If you require key order to be preserved, you may want to look into L<ArrayHash> instead.

=end DESCRIPTION

=head1 Methods

has @.all-pairs; #= Stores all keys and values for the hash
has %.singles = @!all-pairs.hash; #= Stores a simplified version of the hash with all keys, but only the last value

# Internal method that fills in wholes with new pairs and appends the rest to
# the list of pairs.
multi method add-pairs(@new is copy) {
    # Helps to preserve order
    my %exists := bag(
        @new.grep({
            %!singles{ .key } :exists
        }).map({ .key })
    );
    my %encountered := BagHash.new;

    for @!all-pairs.kv -> $i, $v {
        with $v {
            %encountered{ .key }++;
            next;
        }

        next if %exists{ @new[0].key } && !%encountered{ @new[0].key } == %exists{ @new[0].key };

        @!all-pairs[$i] = @new.shift;

        last unless @new;
    }

    @!all-pairs.append: @new;
}

multi method add-pairs(*@new) {
    self.add-pairs(@new);
}

=begin pod

=head2 method new

    multi method new(Hash::MultiValue:U:) returns Hash::MultiValue:D
    multi method new(Hash::MultiValue:U: :@pairs!) returns Hash::MultiValue:D
    multi method new(Hash::MultiValue:U: :@kv!) returns Hash::MultiValue:D
    multi method new(Hash::MultiValue:U: :%mixed-hash!, :$iterate = Iterable, :&iterator) returns Hash::MultiValue:D

This method constructs a multi-value hash. If called with no arguments, an empty hash will be constructed.

    my %empty := Hash::MultiValue.new;

If called with the named C<pairs> argument, then the given pairs will be used to instantiate the list. This is similar to calling C<from-pairs> with the given list..

    my %from-pairs := Hash::MultiValue.new(
        pairs => (a => 1, b => 2, a => 3),
    );

If called with the named C<kv> argument, then the given list must have an even number of elements. The even-indexed items will be treated as keys, and the following odd-indexed items will be treated as the value for the preceding key. This is similar to calling C<from-kv>.

    my %from-kv = Hash::MultiValue.new(
        kv => ('a', 1, 'b', 2, 'a', 3),
    );

If called with the named C<mixed-hash> argument, then the given hash will be treated as a mixed value hash. A mixed value hash is complicated, so using it to initialize this data structure is not ideal.

In order to initialize from such a structure, every value in the given hash must be evaluted by type. If the type of the value matches the one found in C<$iterator> (L<Iterable> by default), then the key will be inserted multiple times, one for each item iterated. The iteration will be handled by just looping over the values using a C<map> operation. You can provide your own C<&iterator> as well, which will be called for each value matching C<$iterator>. The first argument will be key to return and the second will be the value that needs to be iterated. The C<&terator> should return a C<Seq> of C<Pair>s.

    my %from-mixed := Hash::MultiValue.new(
        mixed-hash => {
            a => [ 1, 3 ],
            b => 2,
        },
    );

=end pod

multi method new(:@pairs!) {
    self.new(all-pairs => @pairs);
}

multi method new(:@kv!) {
    fail "an even number of items is required" unless @kv.elems %% 2;
    self.new(all-pairs => @kv.map({ $^k => $^v }));
}

sub iterate-iterable($k, $v) { |$v.map($k => *) }

multi method new(:%mixed-hash!, :$iterate = Iterable, :&iterator = &iterate-iterable) {
    self.new(all-pairs => do for %mixed-hash.kv -> $k, $v {
        given $v {
            when $iterate { iterator($k, $v) }
            default       { $k => $v }
        }
    });
}

=begin pod

=head2 method from-pairs

    method from-pairs(Hash::MultiValue:U: *@pairs) returns Hash::MultiValue:D

This takes a list of pairs and constructs a L<Hash::MultiValue> object from it. Multiple pairs with the same key may be included in this list and all values will be associated with that key.

It should be noted that you may need to be a little careful with how you pass your pairs into this method. Perl 6 treats anything that looks like a named argument as a named argument. Here's a quick example of what works and what doesn't:

    # THIS
    my %h := Hash::MultiValue.from-pairs: (a => 1, b => 2, a => 3);
    # OR THIS
    my %h := Hash::MultiValue.from-pairs((a => 1, b => 2, a => 3));
    # OR THIS
    my %h := Hash::MultiValue.from-pairs('a' => 1, 'b' => 2, 'a' => 3);
    # OR THIS
    my @a := (a => 1, b => 2, a => 3);
    my %h := Hash::MultiValue.from-pairs(@a);

    # BUT NOT
    my %h := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    # ALSO NOT
    my %h := Hash::MultiValue.from-pairs(|@a);

To protect from accidentally passing these as named arguments, the method will fail if any named arguments are detected.

=end pod

#| Construct a Hash::MultiValue object from a list of pairs
method from-pairs(*@pairs, *%badness) returns Hash::MultiValue:D {
    fail "named arguments passed to from-pairs, only a list argument is permitted"
        if %badness;

    self.new(all-pairs => @pairs);
}

=begin pod
=head2 method from-kv

    method from-kv(Hash::MultiValue:U: +@kv) returns Hash::MultiValue:D

This takes a list of keys and values in a single list and turns them into pairs. The given list of items must have an even number of elements or the method will fail.

The even-indexed items will be treated as keys, and the following odd-indexed items will be treated as the value for the preceding key. This is similar to calling C<from-kv>.

=end pod

method from-kv(+@kv) { self.new(:@kv) }

=begin pod
=head2 method from-mixed-hash

    multi method from-mixed-hash(Hash::MultiValue:U: %hash, :$iterate = Iterable, :&iterate) returns Hash::MultiValue:D
    multi method from-mixed-hash(Hash::MultiValue:U: *%hash) returns Hash::MultiValue:D

This takes a hash and constructs a new L<Hash::MultiValue> from it as a mixed-value hash. A mixed value hash is complicated, so using it to initialize this data structure is not ideal.

In order to initialize from such a structure, every value in the given hash must be evaluted by type. If the type of the value matches the one found in C<$iterator> (L<Iterable> by default), then the key will be inserted multiple times, one for each item iterated. The iteration will be handled by just looping over the values using a C<map> operation. You can provide your own C<&iterator> as well, which will be called for each value matching C<$iterator>. The first argument will be key to return and the second will be the value that needs to be iterated. The C<&terator> should return a C<Seq> of C<Pair>s.

    my %from-mixed := Hash::MultiValue.from-mixed-hash(
        a => [ 1, 3 ],
        b => 2,
    );

    # The above is basically identical to:
    # Hash::MultiValue.from-pairs: (a => 1, a => 3, b => 2);

B<Caution:> If you use the slurpy version of this method, you have no additional named options. Passing C<iterate> or C<iterator> will just result in those being put into the data structure.

=end pod

#| Construct a Hash::MultiValue object from a mixed value hash
multi method from-mixed-hash(%mixed-hash, :$iterate = Iterable, :&iterator = &iterate-iterable) returns Hash::MultiValue:D {
    self.new(:%mixed-hash, :$iterate, :&iterator);
}

#| Construct a Hash::MultiValue object from a mixed value hash
multi method from-mixed-hash(*%mixed-hash) returns Hash::MultiValue:D {
    self.new(:%mixed-hash);
}

=begin pod
=head2 method postcircumfix:<{ }>

    method postcircumfix:<{ }> (Hash::MultiValue:D: %key) is rw

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

Binding is also supported. For example,

    my $a = 4;
    %mv<a> := $a;
    $a = 5;
    say %mv<a>; # 4

=end pod

method AT-KEY(Hash::MultiValue:D: $key) {
    %!singles{$key}
}

method ASSIGN-KEY(Hash::MultiValue:D: $key, $value) {
    @!all-pairs[ @!all-pairs.grep({ .defined && .key eqv $key }, :k) ] :delete;
    self.add-pairs(($key => $value).list);
    %!singles{$key} = $value;
    $value;
}

method BIND-KEY($key, $value is rw) {
    @!all-pairs[ @!all-pairs.grep({ .defined && .key eqv $key }, :k) ] :delete;
    self.add-pairs(($key => $value,));
    %!singles{$key} := $value;
}

method DELETE-KEY(Hash::MultiValue:D: $key) {
    @!all-pairs[ @!all-pairs.grep({ .defined && .key eqv $key }, :k) ] :delete;
    %!singles{$key} :delete;
}

method EXISTS-KEY(Hash::MultiValue:D: $key) {
    %!singles{$key} :exists;
}

=begin pod
=head2 method postcircumfix:<( )>

    method postcircumfix:<( )> (Hash::MultiValue:D: $key) is rw

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

method CALL-ME($key) is rw {
    my $self = self;
    my @all-pairs := @!all-pairs;
    Proxy.new(
        FETCH => method () {
            @(@all-pairs.grep({ .defined && .key eqv $key })».value)
        },
        STORE => method (*@new) {
            @all-pairs[ @all-pairs.grep({ .defined && .key eqv $key }, :k) ] :delete;
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

method push(*@values, *%values) {
    my %new-singles;
    my ($previous, Bool $has-previous);
    for flat @values, %values.pairs -> $v {
        if $has-previous {
            self.add-pairs: ($previous => $v,);
            %new-singles{ $previous } = $v;

            $has-previous--;
        }
        elsif $v ~~ Pair {
            self.add-pairs: ($v,);
            %new-singles.push: $v;
        }
        else {
            $has-previous++;
            $previous = $v;
        }
    }

    if ($has-previous) {
        warn "Trailing item in Hash::MultiValue.push";
    }

    %!singles = %!singles.Slip, %new-singles.Slip;
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
