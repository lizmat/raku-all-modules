unit module IO::Notification::Recursive;

use File::Find;

sub watch-recursive(Str $path, Bool :$update) is export {
    my @dirs := find(:dir($path), :type<dir>);      # Get all subdirectories so we can watch them too.
    my @paths := [ $path,  flat @dirs.map({ ~$_ }) ];
    supply {
        my sub watch-it($p) {
            whenever IO::Notification.watch-path($p) -> $e {
                if $update && $e.event ~~ FileRenamed && $e.path.IO ~~ :d {
                    watch-it($e.path);
                }
                supply-emit($e);
            }
        }
        watch-it($_) for @paths;
    }
}

