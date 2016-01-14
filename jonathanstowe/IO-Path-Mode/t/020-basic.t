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
                permissions => {
                    user    =>  {
                        read    =>  True,
                    }
                },
            },
            {
                mode => 0o500,
                permissions => {
                    user    =>  {
                        read    =>  True,
                        execute =>  True,
                    },
                },
            },
            {
                mode => 0o600,
                permissions => {
                    user    =>  {
                        read    =>  True,
                        write   =>  True,
                    },
                },
            },
            {
                mode => 0o700,
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
                mode => 0o640,
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
                mode => 0o664,
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

        for @who -> $who {
            for @perms -> $perm {
                is $mode."$who"()."$perm"(), so $test<permissions>{$who}{$perm}, " { $test<mode>.base(8) }  - $who / $perm";
            }
        }

        $file.unlink;
    }, "file with " ~ $test<mode>.base(8) ~ " permissions";
}


END {
    $test-dir.rmdir;
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
