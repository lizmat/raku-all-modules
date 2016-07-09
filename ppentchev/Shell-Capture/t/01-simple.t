#!/usr/bin/env perl6

use v6.c;

use Test;

plan 13;

use lib 'lib';

use Shell::Capture;

my Shell::Capture $c .= capture($*EXECUTABLE, '-v');
is $c.exitcode, 0, 'perl6 -v succeeded';
isnt $c.lines.elems, 0, 'perl6 -v output something';

$c .= capture($*EXECUTABLE, '-e', 'say "Perl ahoy!"; exit 3');
is $c.exitcode, 3, 'perl6 -e exit 3 exited with 3';
is-deeply $c.lines, Array[Str].new('Perl ahoy!'),
    'perl6 -e "say" said the right thing';

my List:D $accept = (0, 7,);
my Int:D $failed-count = 0;

sub fail(Shell::Capture:D $r, @cmd)
{
	$failed-count++;
}

$c .= capture-check(:&fail, :$accept, $*EXECUTABLE, '-e', 'say ~$*EXECUTABLE');
is $failed-count, 0, 'failed count properly kept';
is $c.exitcode, 0, 'perl6 succeeded';
is-deeply $c.lines, Array[Str].new(~$*EXECUTABLE),
    'perl6 knows what its executable is';

$c .= capture-check(:&fail, :$accept, $*EXECUTABLE, '-e', 'exit 7');
is $failed-count, 0, 'failed count properly kept';
is $c.exitcode, 7, 'perl6 exited with 7';
is $c.lines.elems, 0, 'perl6 did not say anything';

$c .= capture-check(:&fail, :$accept,
    $*EXECUTABLE, '-e', 'say "a"; say "b"; exit 5');
is $failed-count, 1, 'failed count properly kept';
is $c.exitcode, 5, 'perl6 exited with 5';
is-deeply $c.lines, Array[Str].new(<a b>),
    'perl6 -e "say" said the right thing';
