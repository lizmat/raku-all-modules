#!/usr/bin/env perl6
use v6.c;
use Test;
use Terminal::Spinners;

plan 2;

my $classic = Spinner.new;
my $hash-bar = Bar.new;

my class OutputCapture {
    # credit M. Lenz, Perl 6 Fundamentals
    has @!lines;
    method print(\s) {
        @!lines.push(s);
    }
    method captured() {
    @!lines.join;
    }
}

my $spinner-output = do {
    my $*OUT = OutputCapture.new;
    $classic.next;
    $classic.next;
    $*OUT.captured;
}

my $bar-output = do {
    my $*OUT = OutputCapture.new;
    $hash-bar.show: 0e0;
    $hash-bar.show: 100e0;
    $*OUT.captured;
}

my $bar0-string = '[' ~
                  '#' x 0 ~
                  '.' x 71 ~
                  ']' ~
                  '0.00%';

my $bar100-string = '[' ~
                    '#' x 71 ~
                    '.' x 0 ~
                    ']' ~
                    '100.00%';

is $spinner-output, "\b|\b/", 'Spinner next works';
is $bar-output, "\b" x 80 ~
                $bar0-string ~
                "\b" x 80 ~
                $bar100-string,
    'Bar show works';
