unit class ArrayHash:ver<0.3>:auth<Sterling Hanenkamp (hanenkamp@cpan.org)> does Associative does Positional;

use v6;

=NAME ArrayHash - a data structure that is both Array and Hash

=begin SYNOPSIS

    use ArrayHash;

    my @array := array-hash('a' => 1, 'b' => 2);
    my %hash := @array;

    @array[0].say; #> "a" => 1
    %hash<b> = 3;
    @array[1].say; #> "b" => 3;

    # The order of the keys is preserved
    for %hash.kv -> $k, $v {
        say "$k: $v";
    }

    # Note, the special ip operation, here is a significant interface
    # difference from a usual array, .kv is always a key-value alternation,
    # there's also an .ikv:
    for @array.ip -> $i, $p {
        say "$p.key: $p.value is #$i";
    }

=end SYNOPSIS

=begin DESCRIPTION

B<Experimental:> The API here is experimental. Some important aspects of the API may change without warning.

You can think of this as a L<Hash> that always iterates in insertion order or you can think of this as an L<Array> of L<Pair>s with fast lookups by key. Both are correct, though it really is more hashish than arrayish because of the Pairs, which is why it's an ArrayHash and not a HashArray.

An ArrayHash is both Associative and Positional. This means you can use either a C<@> sigil or a C<%> sigil safely. However, there is some amount of conflicting tension between a L<Positional> and L<Assocative> data structure. An Associative object in Perl requires unique keys and has no set order. A Positional, on the othe rhand, is a set order, but no inherent uniqueness invariant. The primary way this tension is resolved depends on whether the operations you are performing are hashish or arrayish.

By hashish, we mean operations that are either related to Associative objects or operations receiving named arguments. By arrayish, we mean operations that are either related to Positional objects or operations receiving positional arguments. In Perl 6, a Pair may generally be passed either Positionally or as a named argument. A bare name generally implies a named argument, e.g., C<:a(1)> or C<<a => 1>> are named while C<<'a' => 1>> is positional.

For example, consider this C<push> operation:

    my @a := array-hash('a' => 1, 'b' => 2);
    @a.push: 'a' => 3, b => 4;
    @a.perl.say;
    #> array-hash(:b(4), :a(3));

Here, the C<push> is an arrayish operation, but it is given both a Pair, C<<'a' => 3>>, and a hashish argument C<<b => 4>>. Therefore, the L<Pair> keyed with C<"a"> is pushed onto the end of the ArrayHash and the earlier value is nullified. The L<Pair> keyed with C<"b"> performs a more hash-like operation and replaces the value on the existing pair.

Now, compare this to a similar C<unshift> operation:

    my @a := array-hash('a' => 1, 'b' => 2);
    @a.unshift: 'a' => 3, b => 4;
    @a.perl.say;
    #> array-hash('a' => 1, 'b' => 2);

What happened? Why didn't the values changed and where did this extra L<Pair> come from? Again, C<unshift> is arrayish and we have an arrayish and a hashish argument, but this time we demonstrate another normal principle of Perl hashes that is enforced, which is, when dealing with a list of L<Pair>s, the latest Pair is the one that bequeaths its value to the hash. That is,

    my %h = a => 1, a => 2;
    say "a = %h<a>";
    #> a = 2

Since an L<ArrayHash> maintains its order, this rule always applies. A value added near the end will win over a value at the beginning. Adding a value near the beginning will lose to a value nearer the end.

So, returning to the C<unshift> example above, the arrayish value with key C<"a"> gets unshifted to the front of the array, but immediately nullified because of the later value. The hashish value with key C<"b"> sees an existing value for the same key and the existing value wins since it would come after it.

The same rule holds for all operations: If the key already exists, but before the position the value is being added, the new value wins. If the key already exists, but after the position we are inserting, the old value wins.

For a regular ArrayHash, the losing value will either be replaced, if the operation is hashish, or will be nullified, if the operation is arrayish.

This might not always be the desired behavior so this module also provides a multi-valued ArrayHash, or multi-hash interface:

    my @a := multi-hash('a' => 1, 'b' => 2);
    @a.push: 'a' => 3, b => 4;
    @a.perl.say;
    #> multi-hash('a' => 1, "b" => 4, "a" => 3);

The operations all work the same, but array values are not nullified and it is fine for there to be multiple values in the array. This is the same class, ArrayHash, but the L<has $.multivalued> property is set to true.

[For future consideration: Consider adding a C<has $.collapse> attribute or some such to govern whether a replaced value in a C<$.multivalued> array hash is replaced with a type object or spiced out. Or perhaps change the C<$.multivalued> into an enum of operational modes.]

[For future consideration: A parameterizable version of this class could be created with some sort of general keyable object trait rather than Pair.]

=end DESCRIPTION

has %!hash;
has Pair @!array handles <
    elems Bool Int end Numeric Str
    flat list lol flattens Capture Parcel Supply
    pick roll reduce combinations
>;

=begin pod

=head1 Methods

=head2 method multivalued

    method multivalued() returns Bool:D

This setting determines whether the ArrayHash is a regular array-hash or a multi-hash. Usually, you will use the L<sub array-hash> or L<sub multi-hash> constructors rather than setting this directly on the C<new> constructor.

=end pod

has Bool $.multivalued = False;

# TODO make this a macro...
sub want($key) {
    & = { .defined && .key eqv $key }
}

=begin pod

=head2 method new

    method new(Bool :multivalued = False, *@a, *%h) returns ArrayHash:D

Constructs a new ArrayHash. This is not the preferred method of construction. You should use L<sub array-hash> or L<sub multi-hash> instead.

=end pod

method new(Bool :$multivalued = False, *@a, *%h)  {
    my $self = self.bless(:$multivalued);
    $self.push: |@a, |%h;
    $self
}

submethod BUILD(:$!multivalued) { self }

=begin pod

=head2 method of

    method of() returns Mu:U

Returns what type of values are stored. This always returns a L<Pair> type object.

=end pod

method of() {
    self.Positional::of();
}

method !clear-before($pos, $key) {
    my @pos = @!array[0 .. $pos - 1].grep(want($key), :k);
    @!array[@pos] :delete;
}

method !found-after($pos, $key) returns Bool {
    @!array[$pos + 1 .. @!array.end].first(want($key), :k) ~~ Int
}

=begin pod

=head2 method postcircumfix:<{ }>

    method postcircumfix:<{ }>(ArrayHash:D: $key) returns Mu

This provides the usual value lookup by key. You can use this to retrieve a value, assign a value, or bind a value. You may also combine this with the hash adverbs C<:delete> and C<:exists>.

=end pod

method AT-KEY(ArrayHash:D: $key) {
    %!hash{$key}
}

=begin pod

=head2 method postcircumfix:<[ ]>

    method postcircumfix:<[ ]>(ArrayHash:D: Int:D $pos) returns Pair

This returns the value lookup by index. You can use this to retrieve the pair at the given index or assign a new pair or even bind a pair. It may be combined with the array adverbs C<:delete> and C<:exists> as well.

=end pod

method AT-POS(ArrayHash:D: $pos) returns Pair {
    @!array[$pos];
}

method ASSIGN-KEY(ArrayHash:D: $key, $value is copy) {
    POST { %!hash{$key} =:= @!array[ @!array.first(want($key), :k, :end) ].value }

    if %!hash{$key} :exists {
        %!hash{$key} = $value;

        CATCH {
            # Handle the case where value is immutable
            when X::Assignment::RO {
                %!hash{$key} := $value;
                @!array[ @!array.first(want($key), :k, :end) ] := $key => $value;
            }
        }
    }
    else {
        @!array.push: $key => $value;
        %!hash{$key} := $value;
    }
}

method ASSIGN-POS(ArrayHash:D: $pos, Pair:D $pair) {
    PRE  { $!multivalued || @!array.grep(want($pair.key)).elems <= 1 }
    POST { $!multivalued || @!array.grep(want($pair.key)).elems <= 1 }
    POST { %!hash{$pair.key} =:= @!array[ @!array.first(want($pair.key), :k, :end) ].value }

    if !$!multivalued && (%!hash{ $pair.key } :exists) {
        self!clear-before($pos, $pair.key);
    }

    if @!array[$pos] :exists && @!array[$pos].defined {
        %!hash{ @!array[$pos].key } :delete;
    }

    my $orig = @!array[ $pos ];

    if self!found-after($pos, $pair.key) {
        if $!multivalued {
            @!array[ $pos ] := $pair;
        }
        else {
            @!array[ $pos ] := Pair;
        }
    }
    else {
        # Make sure the stored value is a key => $var binding
        my $v := $pair.value;
        my $p := $pair.key => $v;

        %!hash{ $p.key } := $p.value;
        @!array[ $pos ]  := $p;
    }

    if $!multivalued && $orig.defined {
        my $npos = @!array.first(want($orig.key), :k, :end);
        if $npos ~~ Int {
            %!hash{ $orig.key } := @!array[$npos].value;
        }
    }

    $pair;
}

method BIND-KEY(ArrayHash:D: $key, $value is rw) is rw {
    POST { %!hash{$key} =:= @!array.reverse.first(want($key)).value }

    if %!hash{$key} :exists {
        %!hash{$key} := $value;
        my $pos = @!array.first(want($key), :k, :end);
        @!array[$pos] := $key => $value;
    }
    else {
        %!hash{$key} := $value;
        @!array.push: $key => $value;
    }
}

method BIND-POS(ArrayHash:D: $pos, Pair:D \pair) {
    PRE  { $!multivalued || @!array.grep(want(pair.key)).elems <= 1 }
    POST { $!multivalued || @!array.grep(want(pair.key)).elems <= 1 }
    POST { %!hash{pair.key} =:= @!array.reverse.first(want(pair.key)).value }

    if !$!multivalued && (%!hash{ pair.key } :exists) {
        self!clear-before($pos, pair.key);
    }

    if @!array[$pos] :exists && @!array[$pos].defined {
        %!hash{ @!array[$pos].key } :delete;
    }

    if self!found-after($pos, pair.key) {
        if $!multivalued {
            @!array[ $pos ] := pair;
        }
        else {
            @!array[ $pos ] := Pair;
        }
    }
    else {
        %!hash{ pair.key } := pair.value;
        @!array[ $pos ]    := pair;
    }
}

method EXISTS-KEY(ArrayHash:D: $key) {
    %!hash{$key} :exists;
}

method EXISTS-POS(ArrayHash:D: $pos) {
    @!array[$pos] :exists;
}

method DELETE-KEY(ArrayHash:D: $key) {
    POST { %!hash{$key} :!exists }
    POST { @!array.first(want($key), :k) ~~ Nil }

    if %!hash{$key} :exists {
        for @!array.grep(want($key), :k).reverse -> $pos {
            @!array.splice($pos, 1);
        }
    }

    %!hash{$key} :delete;
}

method DELETE-POS(ArrayHash:D: $pos) returns Pair {
    my Pair $pair;

    POST { @!array[$pos] ~~ Pair:U }
    POST {
        $pair.defined && !$!multivalued ??
            @!array.first(want($pair.key), :k) ~~ Nil
        !! True
    }
    POST {
        $pair.defined && $!multivalued ??
            (@!array.first(want($pair.key), :k) ~~ Int
                and %!hash{ $pair.key } :exists)
         ^^ (@!array.first(want($pair.key), :k) ~~ Nil
                and %!hash{ $pair.key } :!exists)
        !! True
    }

    if $pair = @!array[ $pos ] :delete {
        %!hash{ $pair.key } :delete;
    }

    $pair;
}

=begin pod

=head2 method push

    method push(ArrayHash:D: *@values, *%values) returns ArrayHash:D

Adds the given values onto the end of the ArrayHash. These values will replace any existing values with matching keys.

    my @a := array-hash('a' => 1, 'b' => 2);
    @a.push: 'a' => 3, b => 4, 'c' => 5;
    @a.perl.say;
    #> array-hash("b" => 4, "a" => 3, "c" => 5);

    my @m := multi-hash('a' => 1, 'b' => 2);
    @m.push: 'a' => 3, b => 4, 'c' => 5;
    @m.perl.say;
    #> multi-hash("a" => 1, "b" => 4, "a" => 3, "b" => 4, "c" => 5);

=end pod

method push(ArrayHash:D: *@values, *%values) returns ArrayHash:D {
    for @values    -> $p     { self.ASSIGN-POS(@!array.elems, $p) }
    for %values.kv -> $k, $v { self.ASSIGN-KEY($k, $v) }
    self
}

=begin pod

=head2 method unshift

    method unshift(ArrayHash:D: *@values, *%values) returns ArrayHash:D

Adds the given values onto the front of the ArrayHash. These values will never replace any existing values in the data structure. In a multi-hash, these unshifted pairs will be put onto the front of the data structure without changing the primary keyed value. These insertions will be nullified if the hash is not multivalued.

    my @a := array-hash('a' => 1, 'b' => 2);
    @a.unshift 'a' => 3, b => 4, 'c' => 5;
    @a.perl.say;
    #> array-hash("c" => 5, "a" => 1, "b" => 2);

    my @m := multi-hash('a' => 1, 'b' => 2);
    @m.push: 'a' => 3, b => 4, 'c' => 5;
    @m.perl.say;
    #> multi-hash("a" => 3, "b" => 4, "c" => 5, "a" => 1, "b" => 2);

=end pod

method unshift(ArrayHash:D: *@values, *%values) returns ArrayHash:D {
    for @values.kv -> $i, $p {
        if !$!multivalued and %!hash{ $p.key } :exists {
            @!array.unshift: Pair;
        }
        else {
            @!array.unshift: $p;
            %!hash{ $p.key } := $p.value
                unless self!found-after($i, $p.key);
        }
    }

    for %values.kv -> $k, $v {
        if %!hash{ $k } :!exists {
            @!array.unshift: $k => $v;
            %!hash{ $k } := $v;
        }
        elsif $!multivalued {
            @!array.unshift: $k => $v;
        }
    }

    self
}

=begin pod

=head2 method splice

    multi method splice(ArrayHash:D: &offset, Int(Cool) $size? *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: Int(Cool) $offset, &size, *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: &offset, &size, *@values, *%values) returns ArrayHash:D
    multi method splice(ArrayHash:D: Int(Cool) $offset = 0, Int(Cool) $size?, *@values, *%values) returns ArrayHash:D

This is a general purpose splice method for ArrayHash. As with L<Array> splice, it is able to perform most modification operations.

    my Pair $p;
    my @a := array-hash( ... );

    @a.splice: *, 0, "a" => 1;  # push
    $p = @a.splice: *, 1;       # pop
    @a.splice: 0, 0, "a" => 1;  # unshift
    $p = @a.splice: *, 1;       # shift
    @a.splice: 3, 1, "a" => 1;  # assignment
    @a.splice: 4, 1, "a" => $a; # binding
    @a.splice: 5, 1, Pair;      # deletion

    # And some operations that are uniqe to splice
    @a.splice: 1, 3;             # delete and squash
    @a.splice: 3, 0, "a" => 1;  # insertion

    # And the no-op, the $offset could be anything legal
    @a.splice: 4, 0;

The C<$offset> is a point in the ArrayHash to perform the work. It is not an index, but a boundary between indexes. The 0th offset is just before index 0, the 1st offset is after index 0 and before index 1, etc.

The C<$size> determines how many elements after C<$offset> will be removed. These are returned as a new ArrayHash.

The C<%values> and C<@values> are a list of new values to insert. If empty, no new values are inserted. The number of elements inserted need not have any relationship to the number of items removed.

This method will fail with an L<X::OutOfRange> exception if the C<$offset> or C<$size> is out of range.

B<Caveat:> It should be clarified that splice does not perform precisely the same sort of operation its named equivalent would. Unlike L<#method push> or L<#method unshift>, all arguments are treated as arrayish. This is because a splice is very specific about what parts of the data structure are being manipulated.

[For the future: Is the caveat correct or should L<Pair>s be treated as hashish instead anyway?]

=end pod

multi method splice(ArrayHash:D: &offset, Int(Cool) $size?, *@values, *%values) returns ArrayHash:D {
    callsame(offset(self.elems), $size, |@values, |%values)
}

multi method splice(ArrayHash:D: Int(Cool) $offset, &size, *@values, *%values) returns ArrayHash:D {
    callsame($offset, size(self.elems - $offset), |@values, |%values)
}

multi method splice(ArrayHash:D: &offset, &size, *@values, *%values) returns ArrayHash:D {
    my $o = offset(self.elems);
    callsame($o, size(self.elems - $o), |@values, |%values)
}

multi method splice(ArrayHash:D: Int(Cool) $offset = 0, Int(Cool) $size?, *@values, *%values) returns ArrayHash:D {
    $size //= self.elems - ($offset min self.elems);

    unless 0 <= $offset <= self.elems {
        X::OutOfRange.new(
            what  => 'offset argument to ArrayHash.splice',
            got   => $offset,
            range => ^self.elems,
        ).fail;
    }

    unless 0 <= $size <= self.elems - $offset {
        X::OutOfRange.new(
            what  => 'size argument to ArrayHash.splice',
            got   => $size,
            range => ^(self.elems - $offset),
        ).fail;
    }

    # Compile the list of replacements, nullifying those that have keys
    # matching pairs later in the list (the later items are kept).
    my @repl;
    for @values.Slip, %values.pairs.Slip -> $pair {
        my $p = do given $pair {
            when Pair:D { $pair }
            when .defined { $pair.key => $pair.value }
            default { Pair }
        };

        my $pos = do if !$!multivalued && $p.defined {
            @!array[$offset + $size .. @!array.end].first(want($p.key), :k);
        }
        else { Nil }

        @repl.push($pos ~~ Int ?? Pair !! $p);
    }

    # Splice the array
    my @ret = @!array.splice($offset, $size, @repl);

    # Delete the removed keys
    for @ret -> $p {
        %!hash{ $p.key } :delete
            if !$!multivalued || !@!array.first(want($p.key));
    }

    # Replace hash elements with new values
    for @repl -> $p {
        %!hash{ $p.key } := $p.value
            if $p.defined && !self!found-after($offset + @repl.elems - 1, $p.key);
    }

    # Nullify earlier values that have just been replaced
    unless $!multivalued {
        for @!array[0 .. $offset - 1].kv -> $i, $p {
            @!array[$i] :delete
                if $p.defined && @repl.first(want($p.key)).defined;
        }
    }

    # Return the removed elements
    return ArrayHash.new(:$!multivalued).push(|@ret);
}

=begin pod

=head2 method sort

    method sort(ArrayHash:D: 5by = &infix:<cmp>) returns ArrayHash:D

This is not yet implemented.

=end pod

method sort(ArrayHash:D: $by = &infix:<cmp>) returns ArrayHash:D {
    die "not yet implemented";
}

=begin pod

=head2 method unique

    method unique(ArrayHash:D:) returns ArrayHash:D

For a multivalued hash, this returns the same hash as a non-multivalued hash. Otherwise, it returns itself.

=end pod

method unique(ArrayHash:D:) returns ArrayHash:D {
    if $!multivalued {
        array-hash(self.pairs)
    }
    else {
        self
    }
}

=begin pod

=head2 method squish

    method squish(ArrayHash:D:) returns ArrayHash:D

This is not yet implemented.

=end pod

method squish(ArrayHash:D:) returns ArrayHash:D {
    die "not yet implemented";
}

=begin pod

=head2 method rotor

Not yet implemented.

=end pod

method rotor(ArrayHash:D:) {
    die "not yet implemented";
}

=begin pod

=head2 method pop

    method pop(ArrayHash:D:) returns Pair

Takes the last element off the ArrayHash and returns it.

=end pod

method pop(ArrayHash:D:) returns Pair {
    self.DELETE-POS(@!array.end)
}

=begin pod

=head2 method shift

    method shift(ArrayHash:D:) returns Pair

Takes the first element off the ArrayHash and returns it.

=end pod

method shift(ArrayHash:D) returns Pair {
    my $head;
    $head = @!array.shift
        andthen %!hash{ $head.key } :delete;
    return $head;
}

=begin pod

=head2 method values

    method values() returns List:D

Returns all the values of the stored pairs in insertion order.

=head2 method keys

    method keys() returns List:D

Returns all the keys of the stored pairs in insertion order.

=head2 method indexes

    method index() returns List:D

This returns the indexes of the ArrayHash, similar to what would be returned by L<Array#method keys>.

=head2 method kv

    method kv() returns List:D

This returns an alternating list of key/value pairs. The list is always returned in insertion order.

=head2 method ip

    method ip() returns List:D

This returns an alternating list of index/pair pairs. This is similar to what would be returned by L<Array#method kv> storing L<Pair>s.

=head2 method ikv

    method ikv() returns List:D

This returns an alternating list of index/key/value tuples. This list is always returne d in insertion order.

=head2 method pairs

    method pairs() returns List:D

This returns a list of pairs stored in the ArrayHash.

=end pod

method values() returns List:D { @!array».value.List }
method keys() returns List:D { @!array».key.List }
method indexes() returns List:D { @!array.keys }
method kv() returns List:D { @!array».kv.List }
method ip() returns List:D { @!array.kv }
method ikv() returns List:D {
    @!array.kv.flatmap({ .defined && Pair ?? .kv !! $_ })
}
method pairs() returns List:D { @!array }

=begin pod

=head2 method invert

    method invert() returns List:D

Not yet implemented.

=head2 method antipairs

    method antipairs() returns List:D

Not yet implemented.

=head2 method permutations

Not yet implemented.

=end pod

method invert() returns List:D {
    die 'not yet implemented'
}

method antipairs() returns List:D {
    die 'not yet implemented'
}

method permutations() {
    die 'not yet implmeneted'
}

=begin pod

=head2 method perl

    multi method perl(ArrayHash:D:) returns Str:D

Returns the Perl code that could be used to recreate this list.

=head2 method gist

    multi method gist(ArrayHash:D:) returns Str:D

Returns the Perl code that could be used to recreate this list, up to the 100th element.

=end pod

multi method perl(ArrayHash:D:) returns Str:D {
    my $type = $!multivalued ?? 'multi-hash' !! 'array-hash';
    $type ~ '(' ~ @!array.map({ .defined ?? .perl !! 'Pair' }).join(', ') ~ ')'
}

multi method gist(ArrayHash:D:) returns Str:D {
    my $type = $!multivalued ?? 'multi-hash' !! 'array-hash';
    $type ~ '(' ~ do for @!array -> $elem {
        given ++$ {
            when 101 { '...' }
            when 102 { last }
            default { $elem.gist }
        }
    }.join(', ') ~ ')'
}

=begin pod

=head2 method fmt

    method fmt($format = "%s\t%s", $sep = "\n") returns Str:D

Prints the contents of the ArrayHash using the given format and separator.

=end pod

method fmt($format = "%s\t%s", $sep = "\n") returns Str:D {
    do for @!array -> $e {
        $e.fmt($format)
    }.join($sep)
}

=begin pod

=head2 method reverse

    method reverse(ArrayHash:D:) returns ArrayHash:D

Returns the ArrayHash, but with pairs inserted in reverse order.

=end pod

method reverse(ArrayHash:D:) returns ArrayHash:D {
    ArrayHash.new(:$!multivalued).push(|@!array.reverse)
}

=begin pod

=head2 method rotate

    method rotate(ArrayHash:D: Int $n = 1) returns ArrayHash:D

Returns the ArrayHash, but with the pairs inserted rotated by C<$n> elements.

=end pod

method rotate(ArrayHash:D: Int $n = 1) returns ArrayHash:D {
    ArrayHash.new(;$!multivalued).push(|@!array.rotate($n))
}

# my role TypedArrayHash[::TValue] does Associative[TValue] does Positional[Pair] {
#
# }
#
# my role TypedArrayHash[::TValue, ::TKey] does Associative[TValue] does Positional[Pair] {
# }
#
# # Taken from Hash.pm
# method ^parameterize(Mu:U \hash, Mu:U \t, |c) {
#     if c.elems == 0 {
#         my $what := hash.^mixin(TypedArrayHash[t]);
#         # needs to be done in COMPOSE phaser when that works
#         $what.^set_name("{hash.^name}[{t.^name}]");
#         $what;
#     }
#     elsif c.elems == 1 {
#         my $what := hash.^mixin(TypedArrayHash[t, c[0].WHAT]);
#         # needs to be done in COMPOSE phaser when that works
#         $what.^set_name("{hash.^name}[{t.^name},{c[0].^name}]");
#         $what;
#     }
#     else {
#         die "Can only type-constrain ArrayHash with [ValueType] or [ValueType,KeyType]";
#     }
# }

=begin pod

=head2 sub array-hash

    sub array-hash(*@a, *%h) returns ArrayHash:D where { !*.multivalued }

Constructs a new ArrayHash with multivalued being false, containing the given initial pairs in the given order (or whichever order Perl picks arbitrarily if passed as L<Pair>s.

=head2 sub multi-hash

    sub multi-hash(*@a, *%h) returns ArrayHash:D where { *.multivalued }

Constructs a new multivalued ArrayHash containing the given initial pairs in the given order. (Again, if you use L<Pair>s to do the initial insertion, the order will be randomized, but stable upon insertion.)

=end pod

our sub array-hash(*@a, *%h) is export { ArrayHash.new(|@a, |%h) }
our sub multi-hash(*@a, *%h) is export { ArrayHash.new(:multivalued).push(|@a, |%h) }
