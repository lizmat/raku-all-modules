#!/usr/bin/env perl6

use v6.c;

use Test;
use Test::Deeply::Relaxed;

use Getopt::Std;

plan 9;

my @a-args = <-h -I foo bar -v quux>;
my %opts;
my @args = @a-args.clone;

lives-ok { %opts = getopts('hI:v', @args) }, 'nonopts base: succeeds';
is-deeply-relaxed @args, [<bar -v quux>], 'nonopts base: args';
is-deeply-relaxed %opts, {:h('h'), :I('foo')}, 'nonopts base: opts';

@args = @a-args.clone;
lives-ok { %opts = getopts('hI:v', @args, :nonopts) }, 'nonopts: succeeds';
is-deeply-relaxed @args, [], 'nonopts: args';
is-deeply-relaxed %opts, {chr(1) => "quux", :h('h'), :I('foo'), :v('v')}, 'nonopts: opts';

@args = @a-args.clone;
lives-ok { %opts = getopts-all('hI:v', @args, :nonopts) }, 'nonopts all: succeeds';
is-deeply-relaxed @args, [], 'nonopts all: args';
is-deeply-relaxed %opts, {chr(1) => ['bar', 'quux'], :h(['h']), :I(['foo']), :v(['v'])}, 'nonopts all: opts';
