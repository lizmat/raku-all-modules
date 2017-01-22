#!/usr/bin/env perl6

use v6;
use Getopt::Kinoko;

constant $VERSIONS = "version 0.1.1, create by Loren.";
constant $TEMPFILE = "snippet";
constant $LINUXTMP = '/tmp/';
constant $LANG_C   = "c";
constant $LANG_CXX = "cpp";

state $is-win32;

BEGIN {
    $is-win32 =  $*DISTRO ~~ /mswin32/;
}

class Compiler      { ... }
class ProcessTarget { ... }

my Getopt \getopt = &snippet_initGetopt();

&main(getopt.parse, getopt);

sub snippet_initGetopt() {
    my OptionSet $opts .= new();

    $opts.insert-normal("h|help=b;v|version=b;?=b;");
    $opts.insert-radio("S = b;E = b");
    $opts.set-comment('h', 'print this help message.');
    $opts.set-comment('v', 'print snippet version.');
    $opts.set-comment('S', 'pass -S to compiler.');
    $opts.set-comment('E', 'pass -E to compiler.');
    $opts.push-option("f|flags 	    = a");
    $opts.push-option("i|include 	= a");
    $opts.push-option("l|link 		= a");
    $opts.push-option("p|print 	    = b");
    $opts.push-option(" |pp 		= a");
    $opts.push-option(" |end        = s", '@@CODEEND');
#    $opts.push-option("t|           = b"); # do not delete temporary .c
#   cause new version snippet use stdin pass code to compiler
    $opts.push-option("e|           = a");
    $opts.push-option("I|           = a");
    $opts.push-option("D|           = a");
    $opts.push-option("L|           = a");
    $opts.push-option("r|           = b");
    $opts.push-option(" |debug      = b");
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
    $opts.set-comment('f', 'pass -<flags> such as -std=c++11 to compiler.');
    $opts.set-comment('i', 'add include file.');
    $opts.set-comment('l', 'link library when genrate executable binary.');
    $opts.set-comment('p', 'print code which genrated by this script.');
    $opts.set-comment('pp', 'add macro define under header include pre-process.');
    $opts.set-comment('end', 'specify code end flag when used for end user input.');
    $opts.set-comment('e', 'add code to generator.');
    $opts.set-comment('I', 'add directory to INCLUDE-PATH.');
    $opts.set-comment('L', 'add directory to LIRBRARY-PATH.');
    $opts.set-comment('r', 'ignore -e, use user input code.');
    $opts.set-comment('debug', 'open debug mode.');
    $opts.set-comment('o', 'output temporary to specify directory.');
    $opts.set-comment('m', 'change main function header.');
    $opts.set-comment('c', 'specify compiler used, current support [clang, gcc].');
    #= set default value common
    $opts{'flags'} = <Wall Wextra Werror>;

    #= deep clone for cpp
    my $opts-c		= $opts;
    my $opts-cpp 	= $opts.deep-clone;

    #= set default value for c
    $opts-c{'include'} = <stdio.h>;
    $opts-c.insert-front( -> $arg {
        if $arg.value ne $LANG_C || $arg.index != 0 {
            X::Kinoko::Fail.new().throw;
        }
    });
    #= add using option
    $opts-cpp.push-option("u|using 	= a", comment => 'add using declare.');
    #= set default value for cpp
    $opts-cpp{'include'} = <iostream>;
    $opts-cpp.insert-front( -> $arg {
        if $arg.value ne $LANG_CXX || $arg.index != 0 {
            X::Kinoko::Fail.new().throw;
        }
    });

    Getopt.new().push($LANG_C, $opts-c).push($LANG_CXX, $opts-cpp);
}

sub main(@args, Getopt \getopt) {
    my ($language, $opts) = (getopt.current, getopt{getopt.current});

    if $language eq "" || $language !(elem) ( $LANG_C, $LANG_CXX ) {
        &printHelpMessage(getopt);
        exit 1;
    }
    if $opts{'version'} {
        &printVersion();
        exit(0) unless $opts{'help'} || $opts{'?'};
    }
    if $opts{'help'} || $opts{'?'} {
        &printHelpMessage(getopt);
        exit(0);
    }

    @args.shift;

    &printHelpMessage(getopt)
        unless &runCompiler($language, $opts, @args);
}

sub runCompiler(Str $language where $language ~~ /"{$LANG_C}"|"{$LANG_CXX}"/, OptionSet \opts, @args) {
    ProcessTarget.new(
        optset => opts,
        target => Compiler.new(
            optset      => opts,
            language    => $language,
            args        => @args
        ).compile()
    ).process();
}

sub promptUser(Str \str) {
    $*OUT.say(str);
}

sub warningUser(Str \str) {
    $*ERR.say(str);
}

sub printHelpMessage(Getopt \getopt) {
    my $help = "Usage:\n";
    for getopt.keys -> $key {
        if getopt.current eq $key || getopt.current eq "" {
            $help ~= $*PROGRAM-NAME ~ " $key " ~ getopt{$key}.usage ~ " *\@args\n";

            for getopt{$key}.comment(4) -> $line {
                $help ~= (" " x 4) ~ @$line.join('') ~ "\n\n"
                    if $line.[1].chars > 1;
            }
        }
    }
    print $help;
    exit(0);
}

sub printVersion() {
    say $VERSIONS;
}

#`(
    C & CXX Compiler
)
class Compiler {
    has OptionSet   $.optset;
    has             @!incode;
    has             $.target;
    has             @!compile-args;
    has             $.language;

    method compile {
        @!incode = DeepClone.deep-clone($!optset<e>);
        self.genCode();
        self.printCode() if $!optset<p>;
        self.genArgs();
        self.doCompile();
        $!target;
    }

    method doCompile {
        my $compiler = self.getCompiler($!optset<c>, $!language);

        self.installSignal;
        try {
            my $proc = run $compiler, @!compile-args, :in;        # run方法执行shell命令
            note("exec cmd info -> $compiler" ~ @!compile-args.perl)
                if $!optset<debug>;
            for @!incode {
                note("write gcc stdin -> [{$_}]") if $!optset<debug>;
                $proc.in.say($_);
            }
            $proc.in.close();
            CATCH {
                default {
                    note "Catch exception when run $compiler, {@!compile-args}";
                    ...
                }
            }
        }
    }

    method argsFromOV(Str $option, @value) {
        @!compile-args.push($option ~ .Str) for @value;
    }

    method genArgs {
        self.argsFromOV('-',  $!optset<f>)   if $!optset.has-value('flags');
        self.argsFromOV('-I', $!optset<I>)   if $!optset.has-value('I');
        self.argsFromOV('-D', $!optset<D>)   if $!optset.has-value('D');
        self.argsFromOV('-L', $!optset<L>)   if $!optset.has-value('L');
        self.argsFromOV('-l', $!optset<l>)   if $!optset.has-value('l');
        self.genTarget();
    }

    method genTarget() {
        $!target ~= "{$is-win32 ?? '' !! $LINUXTMP }{$TEMPFILE}-{time}";
		if $!optset<S> {
			$!target ~= ".S";
            @!compile-args.push('-S', '-o', $!target);
		}
		elsif $!optset<E> {
			$!target ~= ".i";
			@!compile-args.push('-E', '-o', $!target);
		}
		else {
			@!compile-args.push('-o', $!target);
		}
        @!compile-args.push(
            "-x{%{ $LANG_C => 'c', $LANG_CXX => 'c++' }{$!language}}",
            '-'
        );
	}

    method getCompiler(Str $Compiler, Str $language) {
        given $Compiler {
            when /gcc/ {
                return {$LANG_C => 'gcc', $LANG_CXX => 'g++'}{$language};
            }
            when /clang/ {
                return {$LANG_C => 'clang', $LANG_CXX => 'clang++'}{$language};
            }
        }
    }

    method printCode {
        promptUser('-' x 50);
        promptUser(.Str) for @!incode;
        promptUser('-' x 50);
    }

    method readFromUser {
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

    method incodeFromOV(Str $prefix, Str $postfix, @value) {
        @!incode.unshift($prefix ~ $_ ~ $postfix)
            for @value.reverse;
    }

    method insertMain {
        @!incode.unshift('{');
        @!incode.unshift($!optset<main>);
        @!incode.push: 'return 0;';
        @!incode.push: '}';
    }

    method genCode {
        self.readFromUser() if $!optset<r>;
        self.insertMain()   unless $!optset<r>;
        self.incodeFromOV('using ', '', $!optset<u>)
            if $!optset.has-value('u');
        self.incodeFromOV('#', '', $!optset<pp>)
            if $!optset.has-value('pp');
        self.incodeFromOV('#include <', '>', $!optset<i>)
            if $!optset.has-value('i');
    }

    method installSignal {
        signal(SIGINT).tap(
            {
                note "Received a SIGINT signal, Quit" if $!optset<debug>;
                unlink $!target if $!target.IO ~~ :e or "Can not unlink {$!target}: $!";
            }
        );
    }
}

class ProcessTarget {
    has OptionSet   $.optset;
    has             $.target;
    has             @.args;

    method process {
        self.chmod;
        note "run target -> " ~ $!target if $!optset<debug>;
        try {
            if $!optset<S> || $!optset<E> {
                self.catTarget();
            }
            else {
                self.runTarget();
            }
            CATCH {
                default {
                    self.clean;
                    ...
                }
            }
        }
        self.clean;
    }

    method chmod {
        QX("chmod +x {$!target}") unless $is-win32;
    }

    method runTarget {
        #| change it to run
        run(( $is-win32 ?? 'start ' !! '' ) ~ $!target, @!args);
    }

    method catTarget {
        promptUser("{$!target}".IO.slurp);
    }

    method clean {
        note "unlink {$!target}" if $!optset<debug>;
        unlink $!target;
    }
}
