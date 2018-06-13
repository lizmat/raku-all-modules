use X::Trie::MultipleValues;
use OrderedHash;
unit class Trie does Associative does Positional;
trusts Trie;
has             $!children   = OrderedHash[Trie].new;
has             %!decendents;
has             $.value      = Nil;
has atomicint   $.elems      = 0;

method of { Any }

method Hash(--> Hash()) {
    (:__value__($_) with $!value),
    |$!children.kv.map: -> $key, $val { $key => $val.Hash }
}

method AT-KEY(::?CLASS:D: $key) {
    self.get-all: $key
}

method EXISTS-KEY(::?CLASS:D: $key) {
    ?self.get-node: $key
}

method DELETE-KEY(::?CLASS:D: $key) {
    my \value = self{$key};
    self.delete: $key;
    value
}

method ASSIGN-KEY(::?CLASS:D: $key, $value) {
    self.insert: $key, $value
}

method AT-POS(::?CLASS:D: $index is copy) {
    return Any if $index >= $!elems;
    my @keys = $!children.keys;
    return $!value.clone // $!children{@keys.head}.AT-POS: 0 if $index ~~ 0;
    --$index with $!value;
    repeat {
        my $key = @keys.shift;
        if $index >= $!children{$key}.elems {
            $index -= $!children{$key}.elems
        } else {
            return $!children{$key}.AT-POS: $index
        }
    } while $index >= 0;
}

method EXISTS-POS(::?CLASS:D: $index) { $index ~~ ^$!elems }

multi method insert([], $data) {
    die "Value already set" with $!value;
    $!value = $data;
    $!elems⚛++;
    self
}

multi method insert(@chars [$first, *@arr], $data) {
    my $child       = $!children{$first};
    $child          = $!children{$first} = ::?CLASS.new without $child;
    my $child-elems = $child.elems;
    my @gchild      = $child.insert: @arr, $data;
    $!elems⚛++ if $child-elems !~~ $child.elems;
    for @chars.kv -> \i, \char {
        %!decendents{char} ∪= [$child, |@gchild].[i]
    }
    $child, |@gchild
}

multi method insert(Str $string, $data = $string) {
    self.insert($string.comb, $data).tail
}

method single {
    do with $!value {
        X::Trie::MultipleValues.new.throw if $!children.elems;
        $!value
    } elsif $!children.elems > 1 {
        X::Trie::MultipleValues.new.throw if $!children.elems;
    } elsif $!children.elems == 1 {
        $!children.values.first.single
    }
}

method all {
    gather {
        self!all
    }
}

method !all {
    return unless self.DEFINITE;
    .take with $!value;
    $!children.values>>!all
}

method children { $!children.elems }

method !children-and-value { $!children.elems + ($!value.DEFINITE ?? 1 !! 0) }

multi method delete(@arr) { self.del(@arr, :root) }

multi method delete(Str() $key) { self.delete: $key.comb }

multi method del([], :$root) {
    return unless self.DEFINITE;
    $!elems⚛--;
    $!value = Nil;
    not $!children.elems
}

multi method del([$first, *@arr], Bool :$root) {
    my $elems = $!children{$first}.elems;
    my Bool $del = $!children{$first}.del: @arr;
    $!elems⚛-- if $elems > $!children{$first}.elems;
    do if $root or self!children-and-value > 1 {
        if $del {
            $!children{$first}:delete
        }
        False
    } else {
        $del
    }
}

multi method get-path([]) { [ self ] }

multi method get-path([$first, *@arr]) {
    return Trie unless $!children{$first}:exists;
    [ self, |$!children{$first}.get-path: @arr ]
}

multi method get-path(Str $string) {
    self.get-path: $string.comb
}

multi method get-node { self }

multi method get-node([]) { self.get-node }

multi method get-node([$first, *@arr]) {
    return Trie unless $!children{$first}:exists;
    $!children{$first}.get-node: @arr
}

multi method get-node(Str $string) {
    self.get-node: $string.comb
}

method get-single(\key)  { self.get-node(key).single }
method get-all(\key)     { self.get-node(key).all }

method find-char(\char)  { gather { self!find-char(char) } }
method !find-char(\char) {
    #.take with $!children{char}; $!children.values>>!find-char(char)
    for %!decendents{char}.grep: { .DEFINITE } -> %set {
        .take for %set.keys
    }
}

multi method find-substring($string) { self.find-substring: $string.comb }
multi method find-substring([$first, *@rest]) {
    self.find-char($first)>>.get-all(@rest).flat
}

multi method find-fuzzy($string --> Set()) { self.find-fuzzy: $string.comb }
multi method find-fuzzy([$first]) {
    self.find-char($first)>>.all.flat
}
multi method find-fuzzy([$first, *@rest]) {
    self.find-char($first)>>.find-fuzzy(@rest).flat
}
