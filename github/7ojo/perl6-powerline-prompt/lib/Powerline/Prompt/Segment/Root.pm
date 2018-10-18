use v6;
use Powerline::Prompt::Segment;

class Powerline::Prompt::Segment::Root is Powerline::Prompt::Segment {

    has Int $.exitcode;         # exit code of previous command
    has Int $.foreground is rw = 15;
    has Int $.background is rw = 236;

    submethod TWEAK {
        if $!exitcode != 0 {
            self.foreground = 15;
            self.background = 161;
        }
    }

}
