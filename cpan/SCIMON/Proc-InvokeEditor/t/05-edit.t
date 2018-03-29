use v6.c;
use Test;
use Proc::InvokeEditor;

my $path = $*PROGRAM.dirname;

ok my $invoker = Proc::InvokeEditor.new( :editors( [ $path ~ "/t05bin/doubler.pl6" ] ) ), "Can create an invoker object"; 

is $invoker.edit("This is one line"), "This is one lineThis is one line", "Doubler does it's thing";

%*ENV<VISUAL> =  $path ~ "/t05bin/doubler.pl6";

is Proc::InvokeEditor.edit("This is also a line"), "This is also a lineThis is also a line", "Class method works too";

done-testing
