use v6;

unit module Texas::To::Uni;

# Special cases TODO:
# "\"",      "\“",
# '\"',      '\”',
# "\"",      "\„",
# "｢",       "Q//",
# "Q//",     "｣",

my $default = Map.new(
    "<<",      "\«",
    ">>",      "»",
    "\ *\ ",   "×",
    "\ /\ ",   "÷",
    "\ -\ ",   "−",
    "\ o\ ",   "∘",
    "=~=",     "≅",
    "\ pi\ ",  "π",
    "\ tau\ ", "τ",
    "\ e\ ",   "𝑒",
    "Inf ",    "∞",
    "...",     "…",
    "\ +\ ",   "⁺",
    "**0",     "⁰",
    "**1",     "¹",
    "**2",     "²",
    "**3",     "³",
    "**4",     "⁴",
    "**5",     "⁵",
    "**6",     "⁶",
    "**7",     "⁷",
    "**8",     "⁸",
    "**9",     "⁹",
    "set()",   "∅",
    "(elem)",  "∈",
    "!(elem)", "∉",
    "(cont)",  "∋",
    "!(cont)", "∌",
    "(<=)",    "⊆",
    "!(<=)",   "⊈",
    "(<)",     "⊂",
    "!(<)",    "⊄",
    "(>=)",    "⊇",
    "!(>=)",   "⊉",
    "(>)",     "⊃",
    "!(>)",    "⊅",
    "(<+)",    "≼",
    "(>+)",    "≽",
    "(|)",     "∪",
    "(&)",     "∩",
    "(-)",     "∖",
    "(^)",     "⊖",
    "(.)",     "⊍",
    "(+)",     "⊎"
);

my sub convert-string(Str $source is rw, :$table = $default) is export {
    for $table.keys -> $texas {
        $source.subst-mutate($texas, $table{$texas}, :g);
    }
}

my sub convert-file(Str $filename, Bool :$rewrite = False, Str :$new-path = "") is export {
    my Str $content = slurp $filename;
    convert-string($content);
    if $rewrite {
        spurt $filename, $content;
        say "$filename was converted.\n";
    } else {
        if $new-path {
            spurt $new-path, $content;
            say "$filename was converted and written to $new-path";
        } else {
            my @pieces = $filename.split('.'); # Splitting by extension, can be better.
            @pieces.splice(*-1, 0, "uni");
            my $path = @pieces.join('.');
            say $path;
            spurt $path, $content;
            say "$filename was converted and written to $path";
        }
    }
}
