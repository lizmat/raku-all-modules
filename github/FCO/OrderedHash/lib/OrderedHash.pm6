unit role OrderedHash[::T \Type = Any, :@keys = flat("0".."9", "A".."Z", "a".."z")] does Associative;
has Mu:U    $!of    = Type;
has Str     @!keys  = @keys;
has T       @!values is default(Type);
has UInt    %!map   = @keys.kv.reverse;

method STORE(*@pairs, :$initialize --> OrderedHash:D) {
    for @pairs -> (:$key, :$value) {
        self{$key} = $value
    }
    self
}

method !index(Str() \key where any @!keys --> UInt) { %!map{key} }

method elems { self.keys.elems }

method keys { @!keys.grep: { self{$_}:exists } }

method values { @!values.grep: { .DEFINITE } }

method pairs { self.keys Z[=>] self.values }

method kv { flat self.keys Z[,] self.values }

method Hash(--> Hash()) { self.pairs }

method Array(--> Array()) { self.Hash }

method Str(--> Str()) { self.Hash }

method gist { self.Hash.gist }

method AT-KEY(Str() \key) is rw {
    @!values[self!index(key)]
}

method EXISTS-KEY(Str() \key) {
    @!values[self!index(key)].DEFINITE
}

method DELETE-KEY(Str() \key) {
    @!values[self!index(key)]:delete
}

method ASSIGN-KEY(Str() \key, \value) {
    @!values[self!index(key)] = value
}
