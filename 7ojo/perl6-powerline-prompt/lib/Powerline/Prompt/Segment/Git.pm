use v6;
use Powerline::Prompt::Segment;
use Git::Simple;

class Powerline::Prompt::Segment::Git is Powerline::Prompt::Segment {

    has Str $.cwd;

    submethod TWEAK {
        my %branch-info = Git::Simple.new(cwd => $!cwd).branch-info;
        if %branch-info.elems > 0 {
            self.text = " {%branch-info<local>.Str} ";
            self.foreground = 0;
            self.background = 148;
        }
    }

}
