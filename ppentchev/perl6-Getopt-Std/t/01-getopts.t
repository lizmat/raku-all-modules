#!/usr/bin/env perl6

use v6.c;

use Test;
use Test::Deeply::Relaxed;

use Getopt::Std :DEFAULT;

my Str:D %base-opts = :foo('bar'), :baz('quux'), :h(''), :something('15'), :O('-3.5');
my Str:D @base-args = <-v -I tina -vOverbose something -o something -- else -h>;
my $base-optstr = 'I:O:o:v';
my Str:D %empty_hash;

class TestCase
{
	has Str:D $.name is required;
	has Str:D $.optstring = $base-optstr;
	has @.args = @base-args;
	has Str:D %.opts = %base-opts;
	has Bool:D $.res = True;
	has @.res-args is required;
	has %.res-opts is required;
	has Bool $.permute-res = $!res,
	has @.permute-args = @!res-args;
	has %.permute-opts = %!res-opts;
	has @.unknown-args;
	has %.unknown-opts;
}

sub test-getopts(TestCase:D $t)
{
	sub run-test(Bool:D $res, %res-opts, @res-args, Bool:D :$all,
	    Bool:D :$permute, Bool:D :$unknown)
	{
		my Str:D $test = "$t.name() [all: $all permute: $permute unknown: $unknown]";
		my Str:D @test-args = $t.args;
		my %test-opts = $t.opts;
		try getopts($t.optstring, %test-opts, @test-args,
		    :$all, :$permute, :$unknown);
		my Bool:D $result = !$!;
		my Bool:D $exp-res = $res || $unknown;
		is $result, $exp-res, "$test: " ~ ($exp-res?? 'succeeds'!! 'fails');
		if !$result {
			skip "$test failed, not testing options or arguments", 2;
			return;
		}

		my %exp-opts = $all?? %res-opts!!
			$t.optstring.comb(/ . ':'? /).flatmap(-> $opt {
				my Bool:D $arg = $opt.chars > 1;
				my Str:D $char = $arg?? $opt.substr(0, 1)!! $opt;
				my $exp = %res-opts{$char};
				$exp.defined??
					($char => $arg?? $exp[* - 1]!! $exp.join(''),)!!
					()
			});
		is-deeply-relaxed %test-opts, %exp-opts, "$test: stores the expected options";
		is-deeply-relaxed @test-args, @res-args, "$test: leaves the expected arguments";
	}

	for (False, True) -> $all {
		run-test $t.res, $t.res-opts, $t.res-args,
		    :$all, :!permute, :!unknown;
		run-test $t.permute-res, $t.permute-opts, $t.permute-args,
		    :$all, :permute, :!unknown;

		run-test $t.res, $t.unknown-opts, $t.unknown-args,
		    :$all, :!permute, :unknown if $t.unknown-opts && $all;
	}
}

my @tests = (
	TestCase.new(
		:name('empty string'),
		:optstring(''),
		:!res,
		:res-args(@base-args),
		:res-opts(%base-opts),
	),
	TestCase.new(
		:name('no command-line arguments'),
		:args(()),
		:res-args(()),
		:res-opts({}),
	),
	TestCase.new(
		:name('no options specified'),
		:args(<no options specified>),
		:res-args(<no options specified>),
		:res-opts({}),
	),
	TestCase.new(
		:name('early --'),
		:args(<-- -v -I -i -O -o>),
		:res-args(<-v -I -i -O -o>),
		:res-opts({}),
	),
	TestCase.new(
		:name('single flag'),
		:args(<-v out>),
		:res-args([<out>]),
		:res-opts({:v(['v'])}),
	),
	TestCase.new(
		:name('repeated flag'),
		:args(<-vv out>),
		:res-args([<out>]),
		:res-opts({:v([<v v>])}),
	),
	TestCase.new(
		:name('another repeated flag'),
		:args(<-v -v out>),
		:res-args([<out>]),
		:res-opts({:v([<v v>])}),
	),
	TestCase.new(
		:name('glued argument'),
		:args(<-Ifoo bar>),
		:res-args([<bar>]),
		:res-opts({:I(['foo'])}),
	),
	TestCase.new(
		:name('separate argument'),
		:args(<-I foo bar>),
		:res-args([<bar>]),
		:res-opts({:I(['foo'])}),
	),
	TestCase.new(
		:name('glued argument and an option'),
		:args(<-vIfoo bar>),
		:res-args([<bar>]),
		:res-opts({:I(['foo']), :v(['v'])}),
	),
	TestCase.new(
		:name('separate argument and an option'),
		:args(<-vI foo bar>),
		:res-args([<bar>]),
		:res-opts({:I(['foo']), :v(['v'])}),
	),
	TestCase.new(
		:name('repeated argument 1'),
		:args(<-Ifoo -Ibar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	),
	TestCase.new(
		:name('repeated argument 2'),
		:args(<-Ifoo -I bar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	),
	TestCase.new(
		:name('repeated argument 3'),
		:args(<-I foo -Ibar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	),
	TestCase.new(
		:name('repeated argument 4'),
		:args(<-I foo -I bar baz>),
		:res-args([<baz>]),
		:res-opts({:I[<foo bar>]}),
	),
	TestCase.new(
		:name('complicated example'),
		:res-args(<something -o something -- else -h>),
		:res-opts({:I(['tina']), :O(['verbose']), :v([<v v>])}),
		:permute-args(<something else -h>),
		:permute-opts({:I(['tina']), :O(['verbose']), :o(['something']), :v([<v v>])}),
	),
	TestCase.new(
		:name('unrecognized option'),
		:args([<-X>]),
		:!res,
		:res-args(()),
		:res-opts({}),
		:unknown-args(()),
		:unknown-opts({':' => ['X']}),
	),
	TestCase.new(
		:name('unrecognized option glued to a good one'),
		:args([<-vX>]),
		:!res,
		:res-args(()),
		:res-opts({:v(['v'])}),
		:unknown-args(()),
		:unknown-opts({':' => ['X'], :v(['v'])}),
	),
	TestCase.new(
		:name('unrecognized option after a good one'),
		:args([<-v -X and more>]),
		:!res,
		:res-args(<and more>),
		:res-opts({:v(['v'])}),
		:unknown-args(<and more>),
		:unknown-opts({':' => ['X'], :v(['v'])}),
	),
	TestCase.new(
		:name('-X as an option argument'),
		:args([<-I -X>]),
		:res-args(()),
		:res-opts({:I(['-X'])}),
	),
	TestCase.new(
		:name('-X after --'),
		:args(<-v -- -X>),
		:res-opts({:v(['v'])}),
		:res-args([<-X>]),
	),
	TestCase.new(
		:name('-X after a non-option argument'),
		:args(<-v nah -X>),
		:res-opts({:v(['v'])}),
		:res-args(<nah -X>),
		:!permute-res,
		:permute-args([<nah>]),
	),
	TestCase.new(
		:name('a dash after the options'),
		:args(<-v - foo>),
		:res-args(<- foo>),
		:res-opts({:v(['v'])}),
	),
	TestCase.new(
		:name('permute'),
		:args(<-v -Ifoo something -o nothing - and -v -Iso on>),
		:res-opts({:I(['foo']), :v(['v'])}),
		:res-args(<something -o nothing - and -v -Iso on>),
		:permute-opts({:I([<foo so>]), :o(['nothing']), :v([<v v>])}),
		:permute-args(<something - and on>),
	),
);

plan 3 * (4 * @tests.elems + @tests.grep(*.unknown-opts).elems);
test-getopts($_) for @tests;
