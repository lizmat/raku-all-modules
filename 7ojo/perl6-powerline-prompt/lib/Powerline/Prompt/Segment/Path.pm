use v6.c;
use Powerline::Prompt::Segment;

class Powerline::Prompt::Segment::Path is Powerline::Prompt::Segment {

    has Int $.foreground = 250;
    has Int $.background = 237;
    has Str $.text = ' ';
    has Str $.homedir;
    has Str $.cwd;
    has Powerline::Prompt::Segment @.parts;

    submethod TWEAK {
        if $!cwd.starts-with($!homedir) {
            @!parts.push( Powerline::Prompt::Segment.new(text => '~', foreground => 15, background => 31) );
            $!cwd = $!cwd.substr($!homedir.chars);
            $!background = 31
        }

        $!cwd = $!cwd.subst(/^\//, '');
        $!homedir = $!homedir.subst(/^\//, '');

        my @names = $!cwd.split('/');
        my Int $max_depth = 4;
        if @names.elems > $max_depth {
            my @temp;
            @temp.append: @names.splice(0, 2);
            @temp.append: '…';
            @temp.append: @names.splice(@names.elems - ($max_depth-2));
            @names = @temp;
        }

        for @names -> $name {
            @!parts.push( Powerline::Prompt::Segment.new(text => $name, foreground => 250, background => 237) ) if $name.chars > 0;
        }

        # display root path if not any
        @!parts.push( Powerline::Prompt::Segment.new(text => '/', foreground => 250, background => 237) ) if @!parts.elems == 0;
    }

    method draw($outer?) {
        my Str $out;
        my Str $separator;
        my Int $separator_fg;
        my $next;
        my $i=0;
        my $i_max=@.parts.elems;
        while my $part = @.parts.shift {
            $next = @.parts[0];
            if ($i == 0 && $part.text eq '~') || $i == $i_max-1 {
                $separator = '';
                $separator_fg = 31;
            } else {
                $separator = '';
                $separator_fg = 244;
            }
            $out ~= sprintf(
                '\[\e[38;5;' ~ $part.foreground ~ 'm\]\[\e[48;5;' ~ $part.background ~ 'm\]' ~
                (' ' ~ $part.text ~ ' ') ~
                ( $next
                    ?? '\[\e[38;5;' ~ $separator_fg ~ 'm\]\[\e[48;5;' ~ $next.background ~ 'm\]'
                    !! '\[\e[0m\]' ~ '\[\e[38;5;' ~ $part.background ~ 'm\]' ~ '\[\e[48;5;' ~ $outer.background ~ 'm\]'

                ) ~ $separator ~ '\[\e[0m\]');
            $i++;
        }
        $out;
    }

}
