use v6;

class Powerline::Prompt::Segment {

    has Str $.text is rw = '';
    has Int $.foreground is rw;
    has Int $.background is rw;
    has Str $.separator is rw = '';

    method draw($next?) {
        my Str $out = sprintf(
            '\[\e[38;5;' ~ $.foreground ~ 'm\]\[\e[48;5;' ~ $.background ~ 'm\]' ~
            $.text ~
            ( $next
                ?? '\[\e[38;5;' ~ $.background ~ 'm\]\[\e[48;5;' ~ $next.background ~ 'm\]'
                !! '\[\e[0m\]' ~ '\[\e[38;5;' ~ $.background ~ 'm\]'
            ) ~ $.separator ~ '\[\e[0m\]');
        $out;
    }

}
