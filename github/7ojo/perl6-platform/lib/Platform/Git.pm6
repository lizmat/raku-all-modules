use v6;
use Terminal::ANSIColor;
use Platform::Output;
use Platform::Git::Command;

class Platform::Git {

    has $.data;
    has $.target;

    my $uri;
    my $target-path;

    submethod TWEAK {
        $uri = $!data if $!data.isa("Str");
        $target-path = $!target.IO.absolute;
    }

    method clone {
        if not $target-path.IO.e { 
            put " {Platform::Output.after-prefix}" ~ BOLD, "notice: git clone $uri", RESET;
            mkdir $target-path.IO.parent;
            Platform::Git::Command.new(<git>, <clone>, $uri, $target-path).run;
        } else {
            put " {Platform::Output.after-prefix}" ~ BOLD, "notice: skipping git clone, path already exists", RESET;
        }
    }

}
