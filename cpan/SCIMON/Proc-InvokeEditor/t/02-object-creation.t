use v6.c;
use Test;
use Proc::InvokeEditor;

ok my $invoker = Proc::InvokeEditor.new(), "Can create an invoker object"; 
isnt $invoker.editors, (), "We have some default editors";
ok my $set-invoker = Proc::InvokeEditor.new(:editors(("vi","emacs","notepad"))), "We can set editors at object creation";
is $set-invoker.editors, ("vi","emacs","notepad" ), "We have the expected editors";

done-testing;
