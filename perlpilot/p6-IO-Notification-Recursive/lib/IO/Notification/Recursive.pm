unit module IO::Notification::Recursive;

use File::Find;

sub watch-recursive(Str $path, Bool :$update) is export {
    supply {
        my sub watch-it($p) {
            whenever IO::Notification.watch-path($p) -> $e {
                if $update && $e.event ~~ FileRenamed && $e.path.IO ~~ :d {
                    watch-it($_) for find-dirs $e.path;
                }
                emit($e);
            }
        }
        watch-it(~$_) for find-dirs $path;
    }
}

my sub find-dirs (Str:D $p) {
    return slip $p.IO, slip find :dir($p), :type<dir>;
}
