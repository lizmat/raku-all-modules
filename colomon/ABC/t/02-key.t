use v6;
use Test;
use ABC::Grammar;
use ABC::Utils;
use ABC::KeyInfo;

{
    my $key = ABC::KeyInfo.new("D");
    is $key.key.elems, 2, "D has two sharps";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<C>, "^", "C is sharp";
    nok $key.clef.defined, "no clef defined";
}

{
    my $key = ABC::KeyInfo.new("D bass");
    is $key.key.elems, 2, "D has two sharps";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<C>, "^", "C is sharp";
    is $key.clef, "bass", "Recognized bass clef";
}

{
    my $key = ABC::KeyInfo.new("Dmix");
    is $key.key.elems, 1, "Dmix has one sharp";
    is $key.key<F>, "^", "F is sharp";
}

{
    my $key = ABC::KeyInfo.new("Am");
    is $key.key.elems, 0, "Am has no sharps or flats";
}

{
    my $key = ABC::KeyInfo.new("Ddor");
    is $key.key.elems, 0, "Ddor has no sharps or flats";
}

{
    my $key = ABC::KeyInfo.new("Ador");
    is $key.key.elems, 1, "Ador has one sharp";
    is $key.key<F>, "^", "F is sharp";
}

{
    my $key = ABC::KeyInfo.new("Amix");
    is $key.key.elems, 2, "Amix has two sharps";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<C>, "^", "C is sharp";
}

{
    my $key = ABC::KeyInfo.new("C#m");
    is $key.key.elems, 4, "C#m has four sharps";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<C>, "^", "C is sharp";
    is $key.key<G>, "^", "G is sharp";
    is $key.key<D>, "^", "D is sharp";
}

{
    my $key = ABC::KeyInfo.new("C#");
    is $key.key.elems, 7, "C# has seven sharps";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<C>, "^", "C is sharp";
    is $key.key<G>, "^", "G is sharp";
    is $key.key<D>, "^", "D is sharp";
    is $key.key<A>, "^", "A is sharp";
    is $key.key<E>, "^", "E is sharp";
    is $key.key<B>, "^", "B is sharp";
}

{
    my $key = ABC::KeyInfo.new("C ^f _b");
    is $key.key.elems, 2, "C ^f _b has two thingees";
    is $key.key<F>, "^", "F is sharp";
    is $key.key<B>, "_", "B is flat";
}

{
    my $key = ABC::KeyInfo.new("C#m");
    is apply_key_signature($key.key, ABC::Grammar.parse("f", :rule<pitch>)), "^f", "f => ^f";
    is apply_key_signature($key.key, ABC::Grammar.parse("C", :rule<pitch>)), "^C", "C => ^C";
    is apply_key_signature($key.key, ABC::Grammar.parse("G", :rule<pitch>)), "^G", "G => ^G";
    is apply_key_signature($key.key, ABC::Grammar.parse("d", :rule<pitch>)), "^d", "d => ^d";
    is apply_key_signature($key.key, ABC::Grammar.parse("_f", :rule<pitch>)), "_f", "_f => _f";
    is apply_key_signature($key.key, ABC::Grammar.parse("=C", :rule<pitch>)), "=C", "=C => =C";
    is apply_key_signature($key.key, ABC::Grammar.parse("^G", :rule<pitch>)), "^G", "^G => ^G";
    is apply_key_signature($key.key, ABC::Grammar.parse("^^d", :rule<pitch>)), "^^d", "^^d => ^^d";
    is apply_key_signature($key.key, ABC::Grammar.parse("b'", :rule<pitch>)), "b'", "b' => b'";
}

done;
