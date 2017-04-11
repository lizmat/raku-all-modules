use Test;

plan 8;

sub test-run($expected, *@args) {
    my $proc = run('./bin/uni', |@args, :out);
    my $out = $proc.out.lines.join("\n") ~ "\n";
    is $out, $expected, @args.join(' ');
}

# DWIM

test-run(q:to/EOUT/, '∞');
    ∞ - U+00221E - INFINITY [Sm]
    EOUT

test-run(q:to/EOUT/, 'heart', 'shaped');
    😍 - U+01F60D - SMILING FACE WITH HEART-SHAPED EYES [So]
    😻 - U+01F63B - SMILING CAT FACE WITH HEART-SHAPED EYES [So]
    EOUT

# -s
test-run(q:to/EOUT/, '-s', '•');
    • - U+002022 - BULLET [Po]
    EOUT

# -n
test-run(q:to/EOUT/, '-n', 'modeﬆy');
    ䷎ - U+004DCE - HEXAGRAM FOR MODESTY [So]
    EOUT

test-run(q:to/EOUT/, '-n', 'stroke', 'dotl', 'modifier');
    ᶡ - U+001DA1 - MODIFIER LETTER SMALL DOTLESS J WITH STROKE [Lm]
    EOUT

# too slow yet
#test-run(q:to/EOUT/, '-n', '/"rev".*"pilcr"/');
    #⁋ - U+00204B - REVERSED PILCROW SIGN [Po]
    #EOUT
#

# -w
test-run(q:to/EOUT/, '-w', 'cat', 'eyes');
    😸 - U+01F638 - GRINNING CAT FACE WITH SMILING EYES [So]
    😻 - U+01F63B - SMILING CAT FACE WITH HEART-SHAPED EYES [So]
    😽 - U+01F63D - KISSING CAT FACE WITH CLOSED EYES [So]
    EOUT

# -c
test-run(q:to/EOUT/, '-c', 'as', '£¢…');
    a - U+000061 - LATIN SMALL LETTER A [Ll]
    s - U+000073 - LATIN SMALL LETTER S [Ll]

    £ - U+0000A3 - POUND SIGN [Sc]
    ¢ - U+0000A2 - CENT SIGN [Sc]
    … - U+002026 - HORIZONTAL ELLIPSIS [Po]
    EOUT

# -u
test-run(q:to/EOUT/, '-u', '221E', '00A7');
    ∞ - U+00221E - INFINITY [Sm]
    § - U+0000A7 - SECTION SIGN [Po]
    EOUT
