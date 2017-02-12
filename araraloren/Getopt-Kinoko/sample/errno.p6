#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;
use Getopt::Kinoko::OptionSet;

state $VERSION = "0.0.1";

# Errno
class Errno {
	has $.errno;
	has $.number;
	has $.comment;
}

# ErrnoFinder
class ErrnoFinder {
	has %!filter;
	has $.path;
	has @!errnos;

	my regex include {
		<.ws> '#' <.ws> 'include' <.ws>
		\< <.ws> $<header> = (.*) <.ws> \> <.ws>
	}

	my regex edefine {
		<.ws> '#' <.ws> 'define' <.ws>
		$<errno> = ('E'\w*) <.ws>
		$<number> = (\d+) <.ws>
		'/*' <.ws> $<comment> = (.*) <.ws> '*/'
	}

	method !filepath($include) {
		if $include ~~ /^\// {
			return $include;
		}
		return $!path ~ '/' ~ $include;
	}

	method find(Str $file, $top = True) {
        return if %!filter{$file}:exists;

        %!filter{$file} = 1;

		my \fio = $file.IO;

		$!path = fio.abspath().IO.dirname if $top && !$!path.defined;

		if fio ~~ :e && fio ~~ :f {
			for fio.lines -> $line {
				if $line ~~ /<include>/ {
					self.find(self!filepath(~$<include><header>), False);
				}
				elsif $line ~~ /<edefine>/ {
					@!errnos.push: Errno.new(
							errno 	=> ~$<edefine><errno>,
							number 	=> +$<edefine><number>,
							comment	=> ~$<edefine><comment>.trim
						);
				}
			}
		}
	}

	method count() {
		+@!errnos;
	}

	method result() {
		@!errnos;
	}

	method sorted-result() {
		# NYI
	}

	#| need format ?
	multi method list(@column where +@column == 0) {
		for @!errnos -> $errno {
			say ($errno.errno, $errno.number, $errno.comment).join("\t");
		}
	}

	multi method list(@column where +@column > 0) {
		for @!errnos -> $errno {
			my @print;

			@print.push: $errno."{$_}"() for @column;

			say @print.join('\t');
		}
	}

	sub remove(@conds, $str) {
		for ^+@conds -> \i {
			if @conds[i] eq $str {
				@conds[i]:delete;
				return True;
			}
		}
		False;
	}

	method query-and-list($str, @conds is copy) {
		for @!errnos -> $errno {
			if remove(@conds, $errno."$str"()) {
				say ($errno.errno, $errno.number, $errno.comment).join("\t");
			}
		}
	}

	sub remove-regex(@conds, $str) {
		for ^+@conds -> \i {
			if $str ~~ /"{@conds[i]}"/ {
				return True;
			}
		}
		False;
	}

	method match-and-list($str, @conds is copy) {
		for @!errnos -> $errno {
			if remove-regex(@conds, $errno."$str"()) {
				say ($errno.errno, $errno.number, $errno.comment).join("\t");
			}
		}
	}
}


# create optionset
my $opts = OptionSet.new();

$opts.insert-normal("l|list=b;r|regex=b");
$opts.insert-multi("h|help=b;v|version=b;?=b;");
$opts.insert-radio("e|errno=b;c|comment=b;n|number=b");
#$opts.push("f|format=s");
$opts.push-option(
	"p|path=s",
	"/usr/include",
	callback => -> $path {
		my \io = $path.IO;

		if io !~~ :e || io !~~ :d {
			die "$path is not a valid path";
		}
	}
);
$opts.push-option(
	"i|errno-include=s",
	"/usr/include/errno.h",
	callback => -> $path {
		my \io = $path.IO;

		if io !~~ :e || io !~~ :f {
			die "$path is not a valid file";
		}
	}
);

# MAIN
# errno [*option] [errno | regex]
my @conds = getopt($opts, :gnu-style);

# help and version
usage(0) 			if $opts<h> || $opts<help>;
version(0) 			if $opts<v> || $opts<version>;
usage(), version()  if $opts<?>;

# find errno
my $finder = ErrnoFinder.new(path => $opts<path>);

$finder.find($opts<errno-include>);

"Found nothing!".say unless $finder.count > 0;

# generate type
my @types = [];

@types.push: "errno"	if $opts<errno>;
@types.push: "number"	if $opts<number>;
@types.push: "comment"	if $opts<comment>;

# query && list
if $opts<list> {
	$finder.list(@types);
}
elsif $opts<regex> {
	$finder.match-and-list(+@types > 0 ?? @types[0] !! "errno", @conds);
}
else {
	$finder.query-and-list(+@types > 0 ?? @types[0] !! "errno", @conds);
}

#| function
sub usage($exit?) {
	say $*PROGRAM-NAME ~ " " ~ $opts.usage;
	exit($exit) if $exit.defined;
}

sub version($exit?) {
	say "version " ~ $VERSION ~ ", create by araraloren.";
	exit($exit) if $exit.defined;
}
