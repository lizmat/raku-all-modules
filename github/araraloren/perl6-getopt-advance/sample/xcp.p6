#!/usr/bin/env perl6

use nqp;
use Getopt::Advance;

my $verbose = False;
my $proc = wrap-command(
    OptionSet.new,
    "stdbuf", # since cp will using block buffer, so tweak it using stdbuf
    tweak => sub ($os, $ret) {
        for @($ret.noa) -> $noa {
            if $noa ~~ /^ "-" <-[\-]>+ /  {
                if $noa.contains("v") {
                    $verbose = True;
                }
            }
        }
        $ret.noa.push("-v") if not $verbose;
        $ret.noa.unshift("cp");
        $ret.noa.unshift("-o0");
    },
    :async
);

react {
    whenever $proc.stdout.lines {
        if /^ "'" (.*) "'" \s+ '->' \s+ "'" (.*) "'"  $/ {
            my ($src, $dst) = (~$0, ~$1);
            my ($ss, $ds, $bds) = (0, 1, 0);

            while $ss != $ds {
                $ss = getFileSize($src);
                $ds = getFileSize($dst);
                if $bds != $ds {
                    my $p = floor(($ds / $ss) * 100);
                    printf "[%-100s] %d%% => %s\r", '=' x $p, $p, $dst;
                    $bds = $ds;
                }
            }
            print "\n";
        }
    }
    whenever $proc.start { }
}

sub getFileSize($path) { nqp::stat($path, nqp::const::STAT_FILESIZE); }
