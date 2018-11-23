
my multi sub trait_mod:<is>(Method:D \m, :$aka!) { m.package.^add_method(~$_, m) for @$aka }  # see Method::Also

role Duo::Role[::KeyType, ::ValueType] {
    has KeyType   $.key   is rw = Any;
    has ValueType $.value is rw = Any;

    method   key-of { KeyType   }  # (--> KeyType), dies with X::TypeCheck::Return
    method value-of { ValueType }  # (--> ValueType)

    # KeyType =:= ValueType doesn't work, returns false for types [Any, Any]
    method is-symmetric(--> Bool) is aka<is-reflexive> { self.key-of =:= self.value-of }

    multi method new(::?CLASS:U: KeyType $key, ValueType $value --> ::?ROLE:D) { self.new(:$key, :$value) }

    method set(KeyType \k, ValueType \v --> ::?ROLE:D) is aka<update> { ($!key, $!value) = (k, v); self }
}

class Duo does Duo::Role[Any, Any] {
    method elems(--> Int) is aka<Numeric Int> { 2 }

    submethod CALL-ME(::?CLASS:U: |c) { self.new(|c) }

    proto method expand(::?CLASS:U: Any, Any) {*}
    multi method expand(List \k, List \v --> Seq) { (k X v).map: { self.new(|$_) } }
    multi method expand(List \k, \v --> Seq) { k.map: { self.new(:key($_), :value(v))  } }
    multi method expand(\k, List \v --> Seq) { v.map: { self.new(:key(k),  :value($_)) } }
    multi method expand(|c --> List) { (self.new(|c),) }

    method copy  (--> ::?CLASS) is aka<clone dup>         { self.new(:$!key, :$!value) }
    method invert(--> ::?CLASS) is aka<reverse flip anti> { self.new(:key($!value), :value($!key)) }  # antipair

    method clear     (--> ::?CLASS) is aka<reset>            { ($!key, $!value) = (Nil, Nil);       self }
    method inverted  (--> ::?CLASS) is aka<reversed flipped> { ($!key, $!value) = ($!value, $!key); self }

    multi method new(::?CLASS:U: \obj) { self.new.replace(obj) }

    proto method replace(Any) {*}
    multi method replace(Duo      \d --> ::?CLASS:D) { ($!key, $!value) = (d.key, d.value); self }
    multi method replace(Pair     \p --> ::?CLASS:D) { ($!key, $!value) = (p.key, p.value); self }
    multi method replace(Range    \r --> ::?CLASS:D) { ($!key, $!value) = (r.min, r.max);   self }
    multi method replace(Complex  \c --> ::?CLASS:D) { ($!key, $!value) = (c.re,  c.im);    self }
    multi method replace(Rational \r --> ::?CLASS:D) { ($!key, $!value) = r.nude; self }
    multi method replace(List     \l --> ::?CLASS:D) { ($!key, $!value) = l; self }
    multi method replace(IntStr     \a --> ::?CLASS:D) { ($!key, $!value) = (a.Int,     a.Str); self }
    multi method replace(NumStr     \a --> ::?CLASS:D) { ($!key, $!value) = (a.Num,     a.Str); self }
    multi method replace(RatStr     \a --> ::?CLASS:D) { ($!key, $!value) = (a.Rat,     a.Str); self }
    multi method replace(ComplexStr \a --> ::?CLASS:D) { ($!key, $!value) = (a.Complex, a.Str); self }

    method Duo  (--> Duo) { self }
    method Pair (--> Pair)  is aka<pair>  { self ??  ($!key=>$!value) !! Pair  }
    method List (--> List)                { self ??  ($!key, $!value) !! List  }
    method Array(--> Array) is aka<array> { self ??  [$!key, $!value] !! Array }
    method Range(--> Range) is aka<range> { self ??  ($!key..$!value) !! Range }
    method Slip (--> Slip)  is aka<slip>  { self ?? |($!key, $!value) !! Slip  }

    method Rat    (--> Rat)     { self ??     Rat.new($!key, $!value) !! Rat     }
    method FatRat (--> FatRat)  { self ??  FatRat.new($!key, $!value) !! FatRat  }
    method Complex(--> Complex) { self ?? Complex.new($!key, $!value) !! Complex }

    method IntStr    (--> IntStr)     { self ??     IntStr.new($!key, $!value) !! IntStr }
    method NumStr    (--> NumStr)     { self ??     NumStr.new($!key, $!value) !! NumStr }
    method RatStr    (--> RatStr)     { self ??     RatStr.new($!key, $!value) !! RatStr }
    method ComplexStr(--> ComplexStr) { self ?? ComplexStr.new($!key, $!value) !! ComplexStr }

    proto method Hash(|) is aka<hash> {*}
    multi method Hash(::?CLASS:U: --> Hash) { Hash }
    multi method Hash(::?CLASS:D: :$object, *%_ () --> Hash) {
        $object ?? :{$!key=>$!value}
                !!  {$!key=>$!value};
    }
    multi method Hash(::?CLASS:D: :$key='key', :$value='value', :$named!, :$object --> Hash) {
        $object ?? :{$key=>$!key, $value=>$!value}
                !!  {$key=>$!key, $value=>$!value};
    }
    multi method Hash(::?CLASS:D: :$key!, :$value!, |c --> Hash) { self.Hash(:$key, :$value, :named, |c) }
    multi method Hash(::?CLASS:D:  $key,   $value,  |c --> Hash) { self.Hash(:$key, :$value, :named, |c) }

    multi method Str (::?CLASS:D: --> Str) { "$!key.Str() => $!value.Str()" }
    multi method gist(::?CLASS:D: --> Str) { "$!key.gist() => $!value.gist()" }
    multi method perl(::?CLASS:D: --> Str) { "duo($!key.perl(), $!value.perl())" }

    method fmt(Str $fmt='(%s, %s)', Bool $reverse?, :$gist, :$perl --> Str) {
        sprintf $fmt, $reverse ?? self.List.reverse !! self.List;
    }
}

multi sub infix:<eqv>(Duo:D \a, Duo:D \b --> Bool)  { a.key eqv b.key and a.value eqv b.value }
multi sub infix:<cmp>(Duo:D \a, Duo:D \b --> Order) { a.key cmp b.key or  a.value cmp b.value }

# vim: ft=perl6
