#!/usr/bin/env perl6

use Getopt::Advance;
use Getopt::Advance::Exception;

my OptionSet $os .= new;

$os.push(
    'c=a',
    'c source file extension list.',
    value => [ "c", ]
);
$os.push(
    'h=a',
    'head file extension list.',
    value => [ "h", ]
);
$os.push(
    'cpp|=a',
    'cpp source file extension list.',
    value => Q :w ! C cpp c++ cxx hpp cc h++ hh hxx!
);
$os.push(
    'cfg|=a',
    'config file extension list.',
    value => Q :w ! ini config conf cfg xml !
);
$os.push(
    'm=a',
    'makefile extension list.',
    value => ["mk", ]
);
$os.push(
    'w=a',
    'match whole filename.',
    value => Q :w ! makefile Makefile !
);
$os.push(
    'a=a',
    'addition extension list.',
);
$os.push(
    'i=b',
    'enable ignore case mode.'
);
$os.push(
    'no|=a',
    'exclude file category.',
);
my $id = $os.insert-pos(
    "directory",
    sub find-and-print-source($os, $dira) {
        my @stack = $dira.value.IO;
        my @ext = [];
        for < c h cpp cfg m a > -> $opt {
            if $opt !(elem) @($os<no>) {
                @ext.append($os{$opt} // []);
            }
        }
        while @stack {
            with @stack.pop {
                when :d {
                    @stack.append(.dir);
                }
                when $_.basename (elem) @($os<w>) {
                    .put;
                }
                when $_.basename ~~ / \. @ext $/ {
                    .put;
                }
            }
        };
    },
    :last
);
&getopt($os);
