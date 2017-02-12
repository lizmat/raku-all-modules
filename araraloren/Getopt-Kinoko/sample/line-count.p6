#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;
use Getopt::Kinoko::OptionSet;

class LineInfo {
    has $.path is rw;     # path
    has $.line is rw;     # non-white-line count
    has $.white is rw;    # white-line count
}

class OutputInfo {
    has $.path is rw;
    has $.count is rw;
}

my OptionSet $optset .= new();

# insert *normal* group and *all*
$optset.insert-normal("w|ignore-white-line=b;print-sum=b;s|sort=b;desc=b;h|help=b;|abspath=b");
$optset.insert-all(&main);

getopt($optset);

usage() if $optset<h>;

# MAIN
sub main(@arguments) {
    usage() if +@arguments == 0;

    my &output-convert = -> $info {
        OutputInfo.new(
            path => $info.path,
            count => $optset<w> ?? $info.line !! ($info.line + $info.white)
        );
    };

    my @infos = [];

    for @arguments -> $arg {
        my \info := get-line-info(~$arg.value, :abspath($optset{'abspath'}));

        @infos.push: &output-convert(info);
    }

    if $optset{'print-sum'} {
        say [+] @infos.map: { .count };
    }
    else {
        if (+@infos > 1) && $optset.get-option("sort", :long).value {
            @infos = @infos.sort: {
                $$optset<desc> ??
                    ($^a.count < $^b.count) !! ($^a.count > $^b.count);
            };
        }

        for @infos {
            say .path ~ " : " ~ .count;
        }
    }
}

#| help function
multi sub get-line-info(Str $path, :$abspath) {
    get-line-info($path.IO, :$abspath);
}

multi sub get-line-info(IO::Path $filep where $filep ~~ :f && $filep ~~ :r, :$abspath) {
    my LineInfo $li .= new(
        path => $abspath ?? $filep.abspath !! $filep.path,
        line => 0, white => 0
    );

    for $filep.open.lines {
        .chomp.chars == 0 ?? $li.white++ !! $li.line++;
    }

    $li;
}

multi sub get-line-info(IO::Path $dirp where $dirp ~~ :d && $dirp ~~ :x, :$abspath) {
    my LineInfo $li .= new(
        path => $abspath ?? $dirp.path.abspath !! $dirp.path,
        line => 0, white => 0
    );

    for $dirp.dir() -> $iop {
        my \info := get-line-info($iop);

        $li.line += info.line;
        $li.white += info.white;
    }

    $li;
}

multi sub get-line-info(IO::Path $p, :$abspath) {
    say $p.abspath ~ ": Can not read file.";
}

sub usage() {
    say $*PROGRAM-NAME ~ $optset.usage;
    exit(0);
}
