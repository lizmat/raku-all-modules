unit class Grammar::Highlighter::Terminal;

use Terminal::ANSIColor;

my @colors = < bold underline inverse black red green yellow blue magenta cyan white default on_black on_red on_green on_yellow on_blue on_magenta on_cyan on_white on_default >;

method colored(Str $pre, Str $children, Str $post, Int $color) {
    my $code = ($pre, $children, $post).map({$_ // ''}).join('');
    return colored($code, @colors[$color % *]);
}

# vim: ft=perl6
