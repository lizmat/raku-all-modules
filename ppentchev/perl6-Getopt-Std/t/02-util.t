#!/usr/bin/env perl6

use v6.c;

use Test;

use Getopt::Std :util;

class ParseTestCase
{
	has Str:D $.name is required;
	has Str:D $.optstring is required;
	has Bool:D $.dies = False;
	has Bool:D %.defs is required;
}

my ParseTestCase:D @parse-tests = (
	ParseTestCase.new(
		:name('flags only'),
		:optstring('hV'),
		:defs({:!h, :!V}),
	),
	ParseTestCase.new(
		:name('a flag and an argument'),
		:optstring('I:v'),
		:defs({:I, :!v}),
	),
	ParseTestCase.new(
		:name('two colons in a row'),
		:optstring('I::'),
		:dies,
		:defs({}),
	),
	ParseTestCase.new(
		:name('duplicate option'),
		:optstring('hh'),
		:dies,
		:defs({}),
	),
);

sub test-parse(ParseTestCase:D $t)
{
	my $test = "parse: $t.name()";
	my $defs = try getopts-parse-optstring($t.optstring);

	my Bool:D $died = $!.defined;
	is $died, $t.dies,
	    "$test: " ~ ($t.dies?? 'dies'!! "doesn't die");

	my Bool:D %defs = $died?? ()!! $defs;
	is-deeply %defs, $t.defs,
	    "$test: " ~ ($t.defs?? ''!! 'no ') ~ "options returned";
}

class CollapseTestCase
{
	has Str:D $.name is required;
	has %.defs is required;
	has %.opts is required;
	has %.res is required;
}

my CollapseTestCase:D @collapse-tests = (
	CollapseTestCase.new(
		:name('empty'),
		:defs({:!h, :!V}),
		:opts({}),
		:res({}),
	),
	CollapseTestCase.new(
		:name('single flag'),
		:defs({:!h, :!V}),
		:opts({:h(['h'])}),
		:res({:h('h')}),
	),
	CollapseTestCase.new(
		:name('single arg'),
		:defs({:I, :!V}),
		:opts({:I(['how'])}),
		:res({:I('how')}),
	),
	CollapseTestCase.new(
		:name('repeated flag'),
		:defs({:!h, :!V}),
		:opts({:h(['h', 'o', 'w'])}),
		:res({:h('how')}),
	),
	CollapseTestCase.new(
		:name('repeated arg'),
		:defs({:I, :!V}),
		:opts({:I([<how does this work>])}),
		:res({:I('work')}),
	),
	CollapseTestCase.new(
		:name('a mixture'),
		:defs({:!h, :i, :o, :!v}),
		:opts({:h(['h']), :i([<file1.txt file2.txt>]), :o(['output']), :v([<v v v>])}),
		:res({:h('h'), :i('file2.txt'), :o('output'), :v('vvv')}),
	),
	CollapseTestCase.new(
		:name('chr(1)'),
		:defs({:!h, :!V}),
		:opts({:h(['h']), :v(['v', 'v']), chr(1) => <a b c>}),
		:res({:h('h'), :v('vv'), chr(1) => 'c'}),
	),
);

sub test-collapse(CollapseTestCase:D $t)
{
	my %opts = $t.opts;
	getopts-collapse-array(Hash[Bool:D].new($t.defs), %opts);
	is-deeply %opts, $t.res, "collapse: $t.name()";
}

plan 2 * @parse-tests.elems + @collapse-tests.elems;
test-parse($_) for @parse-tests;
test-collapse($_) for @collapse-tests;
