#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;

my $VERSIONS = "version 0.1.1, create by Loren.";

my $is-win32 = $*DISTRO ~~ /mswin32/;

class RunCompiler {
	has Getopt 		$.getopt;
	has OptionSet $!optset;
	has $.current;
	has @!incode;
	has $!out-file;
	has $!target;
	has $!cmd;

	method run {
		$!optset := $!getopt{$!current};
		@!incode  = DeepClone.deep-clone($!optset<e>);

		show-version() if $!optset<v>;

		help($!getopt) if $!optset<h> || $!optset{'?'};

		self.prepare-code();

		help($!getopt) if +@!incode < 1;

		self.print-code if $!optset<p>;

		self.generate-file;

		self.generate-cmd;

		self.run-compiler;

		if $!target.IO ~~ :e {
			if $!optset<S> || $!optset<E> {
				self.cat-target;
			}
			else {
				self.run-target;
			}
		}

		self.clean;
	}

	method run-compiler {
		self.run-cmd($!cmd);
	}

	method run-target {
		self.run-cmd("chmod +x " ~ $!target) unless $is-win32;
		self.run-cmd(($is-win32 ?? 'start ' !! '') ~ $!target);
	}

	method cat-target {
		say "$!target".IO.slurp;
	}


	method run-cmd($cmd) {
		try {
			my $out = QX($cmd); # change shell to QX

			print $out if $out.chomp.chars >= 1;

			return True;
			CATCH {
				default {
					self.clean;
					...
				}
			}
		}
	}

	method clean {
		unlink $!out-file unless $!optset<t>;
		unlink $!target;
	}

	method generate-cmd {
		$!cmd = self.get-Compiler($!optset<c>, $!current) ~ ' ';

		for $!optset<flags> -> $flag {
			$!cmd ~= '-' ~ $flag ~ ' ';
		}

		if $!optset.has-value("I") {
			for $!optset<I> -> $ipath {
				$!cmd ~= '-I' ~ $ipath ~ ' ';
			}
		}

		for $!optset<D> -> $define {
			$!cmd ~= '-D' ~ $define ~ ' ';
		}

		for $!optset<L> -> $linkpath {
			$!cmd ~= '-L' ~ $linkpath ~ ' ';
		}

		for $!optset<l> -> $link {
			$!cmd ~= '-l' ~ $link ~ ' ';
		}

		#note $!cmd;

		$!cmd ~= self.generate-target;
	}

	method generate-target() {
		if $!optset<S> {
			$!target = "{$!out-file}.S";

			return "-S -o $!target " ~ $!out-file;
		}
		elsif $!optset<E> {
			$!target = "{$!out-file}.i";

			return "-E -o $!target " ~ $!out-file;
		}
		else {
			$!target = "{$!out-file}.elf";

			return "-o $!target " ~ $!out-file;
		}
	}

	method get-Compiler(Str $Compiler, Str $language) {
		given $Compiler {
			when /gcc/ {
				return {c => 'gcc', cpp => 'g++'}{$language};
			}
			when /clang/ {
				return {c => 'clang', cpp => 'clang++'}{$language};
			}
		}
		help($!getopt);
	}

	method generate-file {
		$!out-file = self.get-file-name;

		my $fh = open($!out-file, :w)
			or die "Can not save code to " ~ $!out-file;

		# generate include
		if $!optset.has-value("include") {
			for $!optset<i> -> $include {
				$fh.put: '#include <' ~ $include ~ '>';
			}
		}

		# generate pre-processer command
		if $!optset.get-option("pp").has-value {
			$fh.put: $*OUT.nl-out for ^2;
			for $!optset<pp> -> $pp {
				$fh.put: '#' ~ $pp ~ $*OUT.nl-out;
			}
		}

		# generate using for cpp
		if $!current eq "cpp" {
			$fh.put: $*OUT.nl-out for ^2;
			if $!optset.get-option("using").has-value {
				for $!optset<u> -> $using {
					$fh.put: 'using ' ~ $using ~ ';';
				}
			}
		}

		# generate code
		$fh.put: $_ for @!incode;

		$fh.close();
	}

	method get-file-name {
		my $path = $!optset<o>;

		$path ~ $*PID ~ '-' ~ time ~ '.' ~ $!current;
	}

	method print-code {
		note '-' x 50;
		.note for @!incode;
		note '-' x 50;
	}

	method read-from-user {
		@!incode = [];

		my $end := $!optset<end>;

		say "Please input your code, make sure your code correct.";
		say "Enter " ,  $end ~ " end input.";

		my \stdin = $*IN;

		loop {
			my $code = stdin.get().chomp;

			last if $code ~~ /^ $end $/;

			@!incode.push: $code;
		}
	}

	method prepare-code {
		self.read-from-user if $!optset<r>;

		# note @!incode;

		unless ($!optset<r> || +@!incode < 1) {
			@!incode.unshift('{');
			@!incode.unshift($!optset<main>);
			@!incode.push: 'return 0;';
			@!incode.push: '}';
		}
	}
}

# MAIN
my OptionSet $opts .= new();

$opts.insert-normal("h|help=b;v|version=b;?=b;");
$opts.insert-radio("S = b;E = b");
$opts.push-option("f|flags 	= a");
$opts.push-option("i|include 	= a");
$opts.push-option("l|link 		= a");
$opts.push-option("p|print 	= b");
$opts.push-option(" |pp 		= a");
$opts.push-option("end = s", '@@CODEEND');
$opts.push-option("t = b"); # do not delete temporary .c
$opts.push-option("e = a");
$opts.push-option("I = a");
$opts.push-option("D = a");
$opts.push-option("L = a");
$opts.push-option("r = b");
$opts.push-option(
	"o|output = s",
	$is-win32 ?? './' !! '/tmp/', # save . for win32
	callback => -> $output is rw {
		die "Invalid directory"
			if $output.IO !~~ :d;
		$output = $output.IO.abspath;
	}
);
$opts.push-option(
	"m|main = s",
	'int main(void)',
	callback => -> $main is rw {
		die "$main: Invalid main function header"
			if $main !~~ /
				^ <.ws> int \s+ main <.ws>
				\( <.ws> [
					void
					|
					<.ws>
					|
					int \s+ \w+\, <.ws> char <.ws> [
							\* <.ws> \* <.ws> \w+
							|
							\* <.ws> \w+ <.ws> \[ <.ws> \]
						]
				] <.ws> \) <.ws>
			/;
		$main = $main.trim;
	},
);
$opts.push-option(
	"c|compiler = s",
	'gcc',
	callback => -> $Compiler {
		die "$Compiler: Not support this Compiler"
			if $Compiler !(elem) < gcc clang >;
	}
);

#= set default value common
$opts{'flags'} = <Wall Wextra Werror>;

#= deep clone for cpp
my $opts-c		= $opts;
my $opts-cpp 	= $opts.deep-clone;
my $current		= "";

#= set default value for c
$opts-c{'include'} = <stdio.h>;
$opts-c.insert-front( -> $arg {
	if $arg.value ne "c" || $arg.index != 0 {
		X::Kinoko::Fail.new().throw;
	}
	else {
		$current = $arg.value;
	}
});

#= add using option
$opts-cpp.push-option("u|using 	= a");
#= set default value for cpp
$opts-cpp{'include'} = <iostream>;
$opts-cpp.insert-front( -> $arg {
	if $arg.value ne "cpp" || $arg.index != 0 {
		X::Kinoko::Fail.new().throw;
	}
	else {
		$current = $arg.value;
	}
});

#= parser command line
my $getopt = Getopt.new().push('c', $opts-c).push('cpp', $opts-cpp);

$getopt.parse;

#note ' ~~ >' ~ $current;

run-snippet($current, $getopt);

#| helper function
multi sub run-snippet(Str $current where $current ~~ /c|cpp/, $getopt) {
	RunCompiler.new(:$current, getopt => $getopt).run;
}

multi sub run-snippet($str, $getopt) {
	note " ~~ なにそれ !!";
	help($getopt);
}

sub show-version() {
	say $VERSIONS;
}

sub help($getopt) {
	my $help = "Usage:\n";

	for $getopt.keys -> $key {
		if $current eq $key || $current eq "" {
			$help ~= $*PROGRAM-NAME ~ " $key " ~ $getopt{$key}.usage ~ "\n";
		}
	}

	print $help;

	exit(0);
}
