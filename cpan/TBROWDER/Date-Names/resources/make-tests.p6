#!/usr/bin/env perl6

use lib <../lib>;
use Date::Names;

my @langs = @Date::Names::langs;

if !@*ARGS {
    say qq:to/HERE/;
    Usage: $*PROGRAM go | -lang=L | debug [force]

    Writes test files for languages:
    HERE
    print " ";
    print " $_" for @langs;
    say "";
    exit;
}

my $debug = 0;
my $force = 0;
for @*ARGS {
    when / '-'? 'lang=' (\S+) $/ {
        @langs = ~$0;
    }
    when /^d/ {
        $debug = 1;
    }
    when /^f/ {
        $force = 1;
    }
}


my @ofils;
# number prefix for the test series (00N):
my $N = 7;
for @langs -> $L {

    my %parts;
    read-test-template %parts;

    # collect data sets and other info for each language
    my %data;
    get-raw-lang-data :lang($L), :data(%data);

    # output file is hard-wired
    my ($f, $fh);
    if $debug {
        $f  = sprintf "%03d-{$L}-lang-class.t", $N;
        $fh = open $f, :w;
        @ofils.append: $f;
    }
    else {
        # use the module's test directory
        $f  = sprintf "../t/%03d-{$L}-lang-class.t", $N;
        $fh = get-file-handle $f, :$force;
        @ofils.append: $f;
    }

    if 0 && $debug {
        say "DEBUG: dumping parts for lang $L:";
        for 1..3 -> $p {
            say "== part $p ============";
            for @(%parts{$p}) -> $line {
                say "  $line";
            }
            say "======================";
        }
    }

    # now write the pieces
    write-test-file $fh, :%data, :%parts, :$debug, :lang($L);
    $fh.close;

    if $debug {
        say "DEBUG: early exit, file '{$?FILE.IO.basename}', line {$?LINE}";
        last;
    }
}

say "Normal end.";
if @ofils {
    my $n = +@ofils;
    my $s = $n > 1 ?? 's' !! '';
    say "Output file$s:";
    say "  $_" for @ofils;
}
else {
    say "No files were created.";
}

##### SUBROUTINES #####
sub write-test-file($fh, :%data!, :%parts!, :$debug, :$lang!) {

    # part 1
    write-test-file-part $fh, :%parts, :part(1), :$debug, :$lang;

    # data part 1
    write-test-file-data $fh, :%data, :data-part(1), :$debug,
                         :$lang;

    # part 2
    write-test-file-part $fh, :%parts, :part(2), :$debug, :$lang;

    # data part 2
    write-test-file-data $fh, :%data, :data-part(2), :$debug,
                         :$lang;

    # part 3 (FINAL)
    write-test-file-part $fh, :%parts, :part(3), :$debug, :$lang;


}

sub read-test-template(%parts) {
    # input file is hard-wired
    my $f = './lang-class.t';
    die "FATAL: input file '$f' not found'" if !$f.IO.f;

    my $part = 0;
    for $f.IO.lines -> $line {
        # three kinds of directive lines separating the input file
        if $line ~~ / \s+ begin \s+ part \s+ (\d) \s+ / {
            $part = +$0;
            # start adding lines to part $part
            # %parts{$part} SHOULD be empty
            die "FATAL: unexpected non-empty \%parts{$part}" if %parts{$part};
            next;
        }
        elsif $line ~~ / \s+ end \s+ part \s+ (\d) \s+ / {
            my $p = +$0;
            # stop adding lines to part $part
            # make sure we're in g here
            die "FATAL: unexpected part mismatch" if $p != $part;

            # make sure lines are ignored between parts
            $part = 0;
            next;
        }
        elsif $line ~~ / \s+ part \s+ (\d) \s+ data \s+ / {
            my $p = +$0;
            # add the data for part $part
            # %parts{$part}; %parts{$part};
            die "FATAL: unexpected non-empty \%parts{$part}" if %parts{$part};
            if %parts{$part} {
                if $debug {
                    say "DEBUG: dumping \%parts{$part}:";
                    say "  $_" for %parts{$part};
                    say "DEBUG: early exit"; exit;
                }
                die "FATAL: part $part, unexpected non-empty \%parts{$part}" if %parts{$part};
            }

            # so we can skip lines between parts
            $part = 0;
            # do whatever here

            next;
        }
        elsif !$part {
            # ignore line reads beteen parts
            next;
        }
        %parts{$part}.append: $line;
    }

}

sub get-file-handle($f, :$force) {
    my $f-exists = $f.IO.f ?? 1 !! 0;
    note "NOTE: file '$f' exists" if $f-exists;
    if $f-exists && !$force {
        note "      NOT overwriting'...";
        return 0;
    }
    note "      overwriting'..." if $f-exists;
    return open($f, :w);
}

sub get-raw-lang-data(:$lang, :%data) {
    my $base  = "Date::Names";
    my $baseL = "Date::Names::{$lang}";

    # If we know numbers of non-empty data sets of each
    # type we can count numbers of tests for the plan.
    my $ndsets = 0;
    my $nmsets = 0;

    my $ds    = "{$base}::dsets";
    my @dsets = @::($ds);
    %data<dsets> = @dsets;
    for @dsets -> $n {
        my $set = "{$baseL}::{$n}";
        next if !@($::($set)).elems;
        %data{$n} = @($::($set));
        ++$ndsets;
    }

    my $ms    = "{$base}::msets";
    my @msets = @::($ms);
    %data<msets> = @msets;
    for @msets -> $n {
        my $set = "{$baseL}::{$n}";
        next if !@($::($set)).elems;
        %data{$n} = @($::($set));
        ++$nmsets;
    }
    %data<ndsets> = $ndsets;
    %data<nmsets> = $nmsets;
}

sub write-test-file-part($fh, :%parts, :$part!, :$lang, :$debug) {
    for @(%parts{$part}) -> $line {
        $fh.say: $line;
    }
}

sub write-test-file-data($fh, :%data, :$data-part!, :$debug,
                        :$lang) {

    if $data-part == 1 {
        # calculate num tests
        my $nd = %data<ndsets>; # isa-ok
        my $nm = %data<nmsets>; # isa-ok

        my $nt = $nd + $nm;
        $nt += $nd *  7; # dow
        $nt += $nm * 12; # mon

        # add number of other method tests (can-ok) of the class instances
        # (see the language test template file for the current number)
        my $ut = 7;
        $nt += $ut * ($nd + $nm);

        $fh.say: "# Language '{$lang}' class";
        $fh.say: "plan {$nt};";
        $fh.say: "";
        $fh.say: "my \$lang = '{$lang}';";
        $fh.say: "";
        return;
    }

    die "FATAL: date is NOT part 2 (it's part $data-part)" if $data-part != 2;

    # need a master array of non-valid data sets
    my @n;

    for %data.keys.sort -> $n {
        note "DEBUG: \$n = '$n'" if 0;
        # skip aux data
        next if $n ~~ /^ [d|m] sets/;
        next if $n ~~ /^ [nd|nm] sets/;

        my @arr = @(%data{$n});
        # skip empty data sets
        next if !@arr;

        note "DEBUG: appending \$n = '$n'" if 0;
        @n.append: $n;

        # $n now has the name of non-empty arrays, so
        # we print them in <> form
        $fh.printf: "my \@%-4s = <", $n;
        my $ne = $n.comb[0] eq 'd' ?? 7 !! 12;

        for @arr.kv -> $idx, $s {
            $fh.print(" ") if $idx;
            $fh.print: "$s";
        }
        $fh.say: ">;";
    }

    # finally, print all the set names
    $fh.print: "my \@sets = <";
    for @n.kv -> $idx, $s {
        $fh.print(" ") if $idx;
        $fh.print: "$s";
    }
    $fh.say: ">;";

}
