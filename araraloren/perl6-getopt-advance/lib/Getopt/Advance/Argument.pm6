
unit class Argument;

has $.index;
has $.value;

method pairup() of Pair {
    return Pair.new($!index, $!value);
}

method Str() {
    return $!value.Str;
}

method Int() {
    return $!value.Int;
}

method clone(*%_) {
    nextwith(
        index => %_<index> // $!index.clone,
        value => %_<value> // $!value.clone,
        |%_
    );
}
