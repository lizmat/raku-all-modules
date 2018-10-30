use v6;
unit module Sort::Naturally:ver<0.2.2>:auth<github:thundergnat>;

# Routines to do the transformation for sorting

sub naturally ($a) is export {
    $a.lc.subst(/(\d+)/, ->$/ { "0{$0.chars.chr}$0" }, :g) ~ "\x0$a"
}

sub p5naturally ($a) is export {
    $a.lc.subst(/^(\d+)/, -> $/ { "0{$0.gist.chars.chr}$0" } )\
       .subst(/<?after \D>(\d+)/, -> $/ { 'z{' ~"{$0.chars.chr}$0" }, :g) ~ "\x0$a"
}
