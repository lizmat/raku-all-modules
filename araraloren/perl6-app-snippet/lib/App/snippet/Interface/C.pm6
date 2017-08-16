
use PathTools;
use App::snippet;
use App::snippet::Common;

unit class App::snippet::Interface::C does App::snippet::Interface is export;

submethod TWEAK() {
    sub main($optset, @args) {
        my $CLASS = @!compilers.first({ .name eq $optset<c> });
        my $compiler = $CLASS.new(lang => self.lang());
        my $target;
        my $to-execute = !$optset<E> && !$optset<S>;

        # generate compile arguments
        $compiler.autoDetecte(); # ??user defined compiler!!
        $compiler.addArg(&argsFromOV($optset, '-', 'f'));
        $compiler.addArg(&argsFromOV($optset, '--', 'flag'));
        $compiler.addIncludePath(&argsFromOV($optset, '-I', 'I'));
        $compiler.addMacro(&argsFromOV($optset, '-D', 'D'));
        $compiler.addLibraryPath(&argsFromOV($optset, '-L', 'L'));
        $compiler.linkLibrary(&argsFromOV($optset, '-l', 'l'));
        $compiler.setStandard($optset<std>);
        $compiler.addArg(< -Wall -Wextra -Werror >) if $optset<w>;
        # generate code or file
        if +@args == 1 {
            my @incode = [];

            @incode.append(&incodeFromOV($optset, '#include <', '>', 'i'));
            @incode.append(&incodeFromOV($optset, '#', '', 'pp'));
            if $optset<r> {
                my $prompt = qq:to/EOF/;
Please input your code, make sure your code correct.
Enter $!optset<end> input.
EOF
                @incode.append(&promptInputCode($prompt, $optset<end>));
            } else {
                @incode.push($optset<main>);
                @incode.push('{');
                @incode.push($_.Str) for $optset<e> // [];
                @incode.push('return 0;');
                @incode.push('}');
            }
            my $ext = $to-execute ?? 'o' !!( $optset<E> ?? 'i' !! 's');
            unless $to-execute {
                $compiler.setMode($optset<E> ?? CompileMode::PREPROCESS !! CompileMode::ASSEMBLE);
            }
            $target = $compiler.compileCode(
                @incode,
                $optset<o> // &sourceNameToExecutable(tmppath()),
                :out(!$optset<quite>),
                :err(!$optset<quite>),
            );
            &displayCode( &formatCode($optset, @incode) // @incode) if $optset<p>;
        } else {
            @args.shift;
            $to-execute = True;
            my @objects = [];
            my $tmpdir = mkdirs(tmppath());

            for @args>>.value -> $file {
                my $fh = $file.IO;
                if $fh ~~ :e {
                    $compiler.setMode(CompileMode::COMPILE);
                    my $t = $compiler.compileFile(
                        $file,
                        $tmpdir ~ '/' ~ &sourceNameToObject($fh.basename),
                        :out(!$optset<quite>),
                        :err(!$optset<quite>),
                    );
                    @objects.push($t.target);
                } else {
                    fail "Not a file: $file";
                }
            }
				$compiler.setMode(CompileMode::LINK);
            $target = $compiler.linkObject(
                @objects,
                $optset<o> // &sourceNameToExecutable(tmppath()),
                :out(!$optset<quite>),
                :err(!$optset<quite>)
            );
            END { rm(:r, $tmpdir) if $tmpdir; }
        }
        $target.action = $to-execute ?? TargetAction::RUN !! TargetAction::SAY;
        $target.chmod if $to-execute;
        $target.setArgs($optset<args> // []);
        $target.cleanLater() if $optset<clean>;
        return $target;
    }
    $!optset = &commonOptionSet('c11', @!compilers>>.name, 'gcc');
    $!optset.insert-main(&main);
	$!optset.insert-cmd("c");
    $!optset.set-value('i', 'stdio.h');
	$!optset;
}

method lang() {
	Language::C;
}

method optionset() is rw {
	$!optset;
}
