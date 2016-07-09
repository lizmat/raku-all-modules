#!/usr/bin/env perl6

use v6;

my $file-name = "src/scintilla/include/Scintilla.iface";
for $file-name.IO.lines -> $line {
    #say $line;
    
    if $line ~~ m{ ^ 'enu' \s+ (\w+) '=' (\w+) $ } {
        my ($enum, $enum-prefix) = ($/[0], $/[1]);
        #printf("enum '%s' has prefix '%s'\n", $enum, $enum-prefix);
    } elsif $line ~~ m { ^ 'val' \s+ (\w+) '=' (\d+) $ } {
        my ($c-name, $c-value) = ($/[0], $/[1]);
        #printf("constant %s = %d\n", $c-name, $c-value);
    } elsif $line ~~ m { ^ 'fun' \s+ (\w+) \s+ (\w+) '=' (\d+) (.+?) $ } {
        # fun void SetSavePoint=2014(,)
        my ($func-ret-type, $func-name, $func-num, $func-args) = ($/[0], $/[1], $/[2], $/[3]);
        printf("function %s%s is %d returns %s\n", $func-name, $func-args, $func-num, $func-ret-type);
    } elsif $line ~~ m { ^ '#' \s (.+?) $ } {
        # # Set the code page used to interpret the bytes of the document as characters.
        my $doc = $/[0];
        printf("# %s\n", $doc);
    }
}
