use v6;
use Test;
use ABC::Header;

isa_ok ABC::Header.new, ABC::Header, "Can create ABC::Header object";

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    is $a.lines.elems, 1, "One line now present in ABC::Header";
    
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    is $a.lines.elems, 3, "Three lines now present in ABC::Header";
    
    is $a.get("T").elems, 2, "Two T lines found";
    is $a.get("T")[0].value, "The Star of Rakudo", "First title correct";
    is $a.get("T")[1].value, "Michaud's Favorite", "Second title correct";
    
    nok $a.is-valid, "Not valid because its missing a bunch of needed fields";
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    nok $a.is-valid, "Not valid because its still missing the key signature";
    $a.add-line("K", "G");
    ok $a.is-valid, "Now valid!";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("K", "G");
    $a.add-line("L", "1/8");
    nok $a.is-valid, "Not valid, all fields present but K is not the last";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too many Ms";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("L", "1/8");
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too few Ms";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too few Ls";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("L", "1/8");
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too many Ls";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("X", 1);
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too many Xs";
}

{
    my $a = ABC::Header.new;
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("X", 1);
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, X not first";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("T", "The Star of Rakudo");
    $a.add-line("T", "Michaud's Favorite");
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("K", "G");
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too many Ks";
}

{
    my $a = ABC::Header.new;
    $a.add-line("X", 1);
    $a.add-line("M", "2/2");
    $a.add-line("L", "1/8");
    $a.add-line("X", 1);
    $a.add-line("K", "G");
    nok $a.is-valid, "Not valid, too few Ts";
}

done;
