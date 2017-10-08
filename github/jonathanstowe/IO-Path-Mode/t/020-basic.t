#!perl6

use v6;

use Test;

use IO::Path::Mode;

can-ok $*PROGRAM, 'mode', "an IO has our method";
isa-ok $*PROGRAM.mode, IO::Path::Mode, "and it's the right sort of thing";

my $test-dir = $*PROGRAM.parent.child('test-files');

$test-dir.mkdir;

my @who = <user group other>;
my @perms = <read write execute>;

my @tests = {
                mode => 0o400,
                string => '-r--------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    }
                },
            },
            {
                mode => 0o4400,
                string  => '-r-S------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    },
                },
            },
            {
                mode => 0o4500,
                string  => '-r-s------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o500,
                string  => '-r-x------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o600,
                string  => '-rw-------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                },
            },
            {
                mode => 0o700,
                string => '-rwx------',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o440,
                string => '-r--r-----',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    },
                    group   =>  {
                        read    => True,
                    }
                },
            },
            {
                mode => 0o2440,
                string => '-r--r-S---',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    },
                    group   =>  {
                        read    => True,
                    }
                },
            },
            {
                mode => 0o2450,
                string => '-r--r-s---',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    },
                    group   =>  {
                        read    => True,
                        execute => True,
                    }
                },
            },
            {
                mode => 0o640,
                string => '-rw-r-----',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group   =>  {
                        read    => True,
                    }
                },
            },
            {
                mode => 0o660,
                string => '-rw-rw----',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                },
            },
            {
                mode => 0o750,
                string => '-rwxr-x---',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o770,
                string => '-rwxrwx---',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o444,
                string => '-r--r--r--',
                permissions => {
                    user    =>  {
                        read    =>  True,
                    },
                    group   =>  {
                        read    => True,
                    },
                    other   =>  {
                        read    => True,
                    }
                },
            },
            {
                mode => 0o644,
                string => '-rw-r--r--',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group   =>  {
                        read    => True,
                    },
                    other   =>  {
                        read    =>  True,
                    },
                },
            },
            {
                mode => 0o1644,
                string => '-rw-r--r-T',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group   =>  {
                        read    => True,
                    },
                    other   =>  {
                        read    =>  True,
                    },
                },
            },
            {
                mode => 0o1645,
                string => '-rw-r--r-t',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group   =>  {
                        read    => True,
                    },
                    other   =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o664,
                string => '-rw-rw-r--',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    other   =>  {
                        read    => True,
                    }
                },
            },
            {
                mode => 0o666,
                string => '-rw-rw-rw-',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                    other    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                },
            },
            {
                mode => 0o754,
                string => '-rwxr-xr--',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                    other    =>  {
                        read    =>  True,
                    },
                },
            },
            {
                mode => 0o755,
                string => '-rwxr-xr-x',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                    other    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o774,
                string => '-rwxrwxr--',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    other   =>  {
                        read    =>  True,
                    },
                },
            },
            {
                mode => 0o775,
                string => '-rwxrwxr-x',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    other   =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o777,
                string => '-rwxrwxrwx',
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    group    =>  {
                        read    =>  True,
                        write   =>  True,
                        execute =>  True,
                    },
                    other   =>  {
                        read    =>  True,
                        execute =>  True,
                        write   =>  True,
                    },
                },
            };

for @tests -> $test {
    subtest {
        my $file = $test-dir.child(($++).Str);

        $file.open(:w).close;
        $file.chmod($test<mode>);

        my $mode = $file.mode();

        ok $mode.file-type +& IO::Path::Mode::File, "file-type";
        is $mode.Int, $test<mode> +| IO::Path::Mode::File, "mode.Int";
        is +$mode, $test<mode> +| IO::Path::Mode::File, "mode numeric";
        is $mode.Str, $test<string>, "mode string is { $test<string> }";

        for @who -> $who {
            for @perms -> $perm {
                is $mode."$who"()."$perm"(), so $test<permissions>{$who}{$perm}, " { $test<mode>.base(8) }  - $who / $perm";
            }
        }


        $file.unlink;
    }, "file with " ~ $test<mode>.base(8) ~ " permissions";
}

if !$*DISTRO.is-win {
    my $link-file = $test-dir.parent.child('test-link');
    if try $test-dir.symlink($link-file.Str) {

        ok $link-file.mode.file-type ~~ IO::Path::Mode::SymbolicLink, "symbolic link is a SymbolicLink";
    }
    else {
        skip "symlink semantics changed in 2017.04";
    }

    LEAVE {
        $link-file.unlink
    }

}


END {
    $test-dir.rmdir;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
