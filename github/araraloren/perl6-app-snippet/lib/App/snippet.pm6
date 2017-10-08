
use Readline;
use File::Which;

unit module App::snippet;

enum TargetAction is export (
	:RUN(1),
	:SAY(2),
);

enum Language is export (
	:C("c"),
	:CXX("c++"),
);

enum CompileMode is export (
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

	method hasTarget() {
		$!target.defined;
	}

	method setArgs(@args) {
		@!args = @args;
	}

	method chmod() {
		chmod 0o755, $!target if self.hasTarget;
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

	multi method compile(@args, @codes, :$out, :$err) {
		my $promise;
		my $proc = Proc::Async.new(:w, $!compiler, @args);
		$proc.stdout.tap(&print) if $out;
		$proc.stderr.tap(&print) if $err;
		$promise = $proc.start;
		$proc.say($_) for @codes;
		$proc.close-stdin;
		$promise;	
	}

	multi method compile(@args, :$out, :$err) {
		my $promise;
		my $proc = Proc::Async.new($!compiler, @args);
		$proc.stdout.tap(&print) if $out;
		$proc.stderr.tap(&print) if $err;
		$promise = $proc.start;
		$promise;
	}

	method compileCode(@codes, $output, :$out, :$err) {
		my @realargs = @!args;

		if $!mode eq CompileMode::LINK {
			@realargs.push("-l{$_}") for @!library
			
		}
		@realargs.push($!mode.Str) if $!mode.Str ne "";
		@realargs.append("-o", $output, "-x{$!lang}", "-");
		try {
			await self.compile(@realargs, @codes, :$out, :$err);
			return Target.new(target => $output);
			CATCH {
				default {
					return Target.new;	
				}	
			}
		}
	}

	method compileFile($file, $output, :$out, :$err) {
		my @realargs = @!args;

		@realargs.push($!mode.Str) if $!mode.Str ne "";
		@realargs.append("-o", $output, $file);
		try {
			await self.compile(@realargs, :$out, :$err);
			return Target.new(target => $output);
			CATCH {
				default {
					return Target.new;	
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
			await self.compile(@realargs, :$out, :$err);
			return Target.new(target => $output);
			CATCH {
				default {
					return Target.new;	
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
sub promptInputCode(Str $prompt, Str $end, Str $readline-prompt = "") of Array is export {
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

sub simpleFormater(Str $command, Str $style) is export {
	my $bin = which($command);
	my $proc = Proc::Async.new(:w, $bin, $style.trim eq "" ?? [] !! $style.split(/\s+/, :skip-empty));
	return sub (@code) {
		my $code = "";
		$proc.stdout.tap({ $code ~= $^a; });
		$proc.stderr.tap(&print);
		my $promise = $proc.start;
		$proc.say($_) for @code;
		$proc.close-stdin;
		await $promise;
		return $code.chomp;
	};
}
