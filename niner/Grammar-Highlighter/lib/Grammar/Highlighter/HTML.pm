unit class Grammar::Highlighter::HTML;

use Terminal::ANSIColor;

my @colors = < aqua blue fuchsia gray green lime maroon navy olive purple red silver teal yellow >;

sub escape(Str $code) {
    my $escaped = $code;
    $escaped ~~ s/\</&lt;/;
    return $escaped;
}

method colored(Str $pre, Str $children, Str $post, Int $color) {
    return qq!<span style="color: {@colors[$color % *]};">{escape $pre}{$children // ''}{escape $post // ''}</span>!;
}

# vim: ft=perl6

