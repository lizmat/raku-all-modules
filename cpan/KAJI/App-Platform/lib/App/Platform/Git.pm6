use v6;
use Terminal::ANSIColor;
use App::Platform::Output;
use App::Platform::Git::Command;

class App::Platform::Git {

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
            put " {App::Platform::Output.after-prefix}" ~ BOLD, "notice: git clone $uri", RESET;
            mkdir $target-path.IO.parent;
            App::Platform::Git::Command.new(<git>, <clone>, $uri, $target-path).run;
        } else {
            put " {App::Platform::Output.after-prefix}" ~ BOLD, "notice: skipping git clone. {$target-path.IO.relative} already exists", RESET;
        }
    }

}
