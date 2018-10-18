#!/usr/bin/env perl6

my $script := 'lib/CoreHackers/Q/Parser/Actions.pm6'.IO;
my $css-re := /'<!-- CSS INSERT START -->' <( .+? )> '<!-- CSS INSERT END -->'/;
my $js-re  := /'<!-- JS INSERT START -->'  <( .+? )> '<!-- JS INSERT END -->' /;

multi MAIN('inject') {
    $script.spurt: $script.slurp.subst(
        $css-re, "<style>\n" ~ 'main.css'.IO.slurp.indent(6)
        ~ "\n</style>".indent(6)
    ).subst: $js-re, "<script>\n" ~ 'main.js'.IO.slurp.indent(6)
        ~ "\n</script>".indent(6)
}
multi MAIN('uninject') {
    $script.spurt: $script.slurp.subst(
        $css-re, ("\n" ~ *.indent(6)
        ~ "\n      ")(｢<link rel="stylesheet" href="main.css">｣)
    ).subst: $js-re, ("\n" ~ *.indent(6)
        ~ "\n      ")(｢<script src="main.js"></script>｣)
}
