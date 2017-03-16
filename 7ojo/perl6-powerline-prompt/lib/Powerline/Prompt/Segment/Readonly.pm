use v6.c;
use Powerline::Prompt::Segment;

class Powerline::Prompt::Segment::Readonly is Powerline::Prompt::Segment {

    has Str $.cwd;
    has Int $.foreground = 254;
    has Int $.background = 124;

    method TWEAK {
        $.text = '  ' if not $.cwd.IO.w;
    }

}

