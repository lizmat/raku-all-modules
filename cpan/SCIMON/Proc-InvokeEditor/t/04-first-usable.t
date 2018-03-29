use v6.c;
use Test;

INIT {
    my $path = $*PROGRAM.dirname;
    %*ENV<EDITOR> =  $path ~ "/t04bin/exec.pl6 --flag";
}

use Proc::InvokeEditor;

my $path = $*PROGRAM.dirname;

my Str @expected = [$path  ~ "/t04bin/exec.pl6" ];

ok my $invoker = Proc::InvokeEditor.new( :editors( ( $path ~ "/t04bin/not-exec", $path ~ "/t04bin/exec.pl6" ) ) ), "Can create an invoker object"; 
is-deeply $invoker.first_usable(), @expected, "Got the expected result for first useable";

ok $invoker.editors( $path ~ "/t04bin/exec.pl6", $path ~ "/t04bin/not-exec" ), "Updating the order";
is-deeply $invoker.first_usable(), @expected, "Got the expected result for first useable";

@expected = [ $path  ~ "/t04bin/exec.pl6", "--flag"];

ok $invoker.editors( $path ~ "/t04bin/exec.pl6 --flag", $path ~ "/t04bin/not-exec" ), "Updating the order";
is-deeply $invoker.first_usable(), @expected, "Got the expected result for first useable";

ok $invoker.editors( $path ~ "/t04bin/not-exec", $path ~ "/t04bin/exec.pl6 --flag"), "Updating the order";
is-deeply $invoker.first_usable(), @expected, "Got the expected result for first useable";

ok my @class-result = Proc::InvokeEditor.first_usable(), "First usable as a class method returns a result";
ok @class-result.elems > 0, "We have some kind of result";

ok $invoker.editors( $path ~ "/t04bin/not-exec" ), "Nothing to find";
isa-ok $invoker.first_usable(), Failure, "Got a failure if there's no script to run";


is-deeply Proc::InvokeEditor.first_usable(), @expected, "Got the expected result for first useable";

done-testing;
