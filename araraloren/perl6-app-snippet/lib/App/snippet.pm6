
use Readline;
use File::Which;

enum TargetAction (
	:RUN(1),
	:SAY(2),
);

enum Language(
	:C("c"),
	:CXX("c++"),
);

enum CompileMode (
	:COMPILE("-c"),
	:PREPROCESS("-E"),
	:ASSEMBLE("-S"),
	:LINK(""),
);

#####################################################
## role Target and Compiler
#####################################################
role Target {
	has TargetAction $.action is rw;
	has $.target;
	has @.args = [];
	has $.want-clean;

	method setArgs(@args) {
		@!args = @args;
	}

	method chmod() {
		chmod 0o755, $!target;
	}

	method run() {
		my $proc;
		given $*KERNEL {
			when /win32/ {
				$proc = run('start', $!target, @!args);
			}

			default {
				$proc = run($!target, @!args);
			}
		}
		$proc;
	}

	method say() {
		print($!target.IO.slurp);
	}

	method cleanLater() {
		$!want-clean = True;
	}

	method clean() {
		unlink $!target if $!want-clean;
	}
}

class Result {
	has $.target;
	has $.stdout;
	has $.stderr;
}

class Support {
	has $.lang;
	has $.bin;
}

role Compiler {
    has $.compiler;
    has @.args;
    has $.lang;
	has @.library;
	has $.mode = CompileMode::LINK;

	method name() { ... }

	method supports() { ... }

	method setLanguage($lang) {
		if self.supports().grep({.lang eq $lang}) {
			$!lang = $lang;
		}
		fail "\{{self.supports()}\} Not support this language: $lang";
	}

	method setMode(CompileMode $mode) {
		$!mode = $mode;
	}

	method autoDetecte() {
		without $!compiler {
			$!compiler = which(self.supports().first({ .lang eq $!lang }).bin);
		}
		return defined($!compiler);
	}

	method setCompiler($compiler) {
		$!compiler = $compiler;
	}

    method compileCode(@codes, $output, :$out, :$err) {
        my @realargs = @!args;

		{ @realargs.push("-l{$_}") for @!library  } if $!mode eq CompileMode::LINK;
		@realargs.push($!mode.Str) if $!mode.Str ne "";
        @realargs.append("-o", $output, "-x{$!lang}", "-");
        try {
            my $proc = run $!compiler, @realargs, :in, :$out, :$err;

            $proc.in.say($_) for @codes;
            $proc.in.close();
            return &fetchMessage($proc, $output, :$out, :$err);
            CATCH {
                default {
					.resume;
                }
            }
        }
    }

    method compileFile($file, $output, :$out, :$err) {
        my @realargs = @!args;

		@realargs.push($!mode.Str) if $!mode.Str ne "";
        @realargs.append("-o", $output, $file);
        try {
            my $proc = run $!compiler, @realargs, :$out, :$err;

            return &fetchMessage($proc, $output, :$out, :$err);
            CATCH {
                default {
                    .resume;
                }
            }
        }
    }

	method linkObject(@objects, $output, :$out, :$err) {
		my @realargs = [];

		@realargs.push("-l{$_}") for @!library;
		@realargs.push($!mode.Str) if $!mode.Str ne "";
		@realargs.append(@objects);
		@realargs.append("-o", $output);
        try {
            my $proc = run $!compiler, @realargs, :$out, :$err;

            return &fetchMessage($proc, $output, :$out, :$err);
            CATCH {
                default {
                    .resume;
                }
            }
        }
	}

    method setOptimizeLevel(int $level) {
        self.addArg("-O{$level}");
    }

    method setStandard(Str $std) {
        self.addArg("-std={$std}");
    }

	multi method addMacro($macro) {
        self.addArg("-D{$macro}");
    }

	multi method addMacro(@macro) {
        self.addMacro($_) for @macro;
    }

    multi method addMacro($macro, $value) {
        self.addArg("-D{$macro}={$value}");
    }

	multi method addMacro(*%args) {
		self.addMacro(.key, .value) for %args;
	}

	multi method addIncludePath($path) {
        self.addArg("-I{$path}");
    }

	multi method addIncludePath(@path) {
		self.addIncludePath($_) for @path;
	}

	multi method addLibraryPath($path) {
        self.addArg("-L{$path}");
    }

	multi method addLibraryPath(@path) {
		self.addLibraryPath($_) for @path;
	}

	multi method linkLibrary($libname) {
        @!library.push($libname);
    }

	multi method linkLibrary(@libname) {
		self.linkLibrary($_) for @libname;
	}

    multi method addArg(Str $option) {
        @!args.push($option);
    }

	multi method addArg(@option) {
		self.addArg($_) for @option;
	}

    multi method addArg(Str $option, Str $arg) {
        @!args.append($option, $arg);
    }

	multi method addArg(*%args) {
	 	self.addArg(.key, .value) for %args;
	}
}

role Interface {
	has $.optset;
	has @.compilers;

	method lang() { ... }

	method optionset() is rw { ... }

	method setCompiler(@compilers) {
		@!compilers = @compilers;
	}
}

#####################################################
## helper sub
#####################################################
sub prompt-input-code(Str $prompt, Str $end, Str $readline-prompt = "") of Array is export {
	my @code = [];
	my $readline = Readline.new;

	print $prompt;
	$readline.using-history;
	loop {
		if $readline.readline($readline-prompt) -> $code {
			$readline.add-history($code);
			last if $code ~~ /^ $end $/;
			@code.push($code);
		}
	}
	@code;
}

sub incodeFromOV($optionset, Str $prefix, Str $postfix, $opt) is export {
	if $optionset.get($opt).has-value {
		my @value := $optionset{$opt};
		@value.reverse.map({ $prefix ~ $_ ~ $postfix });
	} else {
		();
	}
}

sub argsFromOV($optionset, Str $prefix, $opt) is export {
	if $optionset.get($opt).has-value {
		my @value := $optionset{$opt};
		@value.map({ $prefix ~ $_ });
	} else {
		();
	}
}

sub sourceNameToObject($filename, $ext='o') is export {
	if $filename.rindex('.') -> $index {
		return "{$filename.substr(0, $index)}.{$ext}";
	} else {
		return "{$filename}.{$ext}";
	}
}

sub sourceNameToExecutable($filename) is export {
	my $ext = ($*KERNEL ~~ /win32/ ?? '.exe' !! "");
	if $filename.rindex('.') -> $index {
		return "{$filename.substr(0, $index)}{$ext}";
	} else {
		return "{$filename}{$ext}";
	}
}

sub displayCode(@code, $ch = '-', $length = 50) is export {
	say $ch x $length;
	.say for @code;
	say $ch x $length;
}

multi sub do_compile($compile, @args) of IO::Path {
	try {
		run $compile, @args;
		CATCH {
			default {
				note "Compile failed: $compile {@args}";
				...
			}
		}
	}
}

multi sub do_compile($compile, @args, @incode) of IO::Path {
	try {
		my $proc = run $compile, @args, :in;

		$proc.in.say($_) for @incode;
		$proc.in.close();
		CATCH {
			default {
				note "Compile failed: $compile {@args}";
				...
			}
		}
	}
}

sub fetchMessage($proc, $output, :$out, :$err) {
	if $*PERL.version ~~ v6.c {
		my $stdout = $out ?? $proc.out.slurp-rest() !! "";
		my $stderr = $err ?? $proc.err.slurp-rest() !! "";

		$proc.out.close() if $out;
		$proc.err.close() if $err;
		return Result.new(
			target => Target.new(target => $output),
			stdout => $stdout,
			stderr => $stderr,
		);
	} else {
		return Result.new(
			target => Target.new(target => $output),
			stdout => $out ?? $proc.out.slurp(:close) !! "",
			stderr => $err ?? $proc.err.slurp(:close) !! "",
		);
	}
}
