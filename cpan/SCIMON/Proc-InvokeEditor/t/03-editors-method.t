use v6.c;
use Test;
use Proc::InvokeEditor;

ok my $invoker = Proc::InvokeEditor.new(), "Can create an invoker object"; 
is-deeply Proc::InvokeEditor.editors(), $invoker.editors, "Default object method and class method match";

# object method can be set
my Str @editors = ["/tmp/test-editor"];
is $invoker.editors(@editors), @editors, "Can update the editors list";
is $invoker.editors(), @editors, "Update stays";
@editors.push("/tmp/editor2");
is $invoker.editors("/tmp/test-editor", "/tmp/editor2" ), @editors, "Allow a slurpy list call too";
is $invoker.editors(), @editors, "Update stays";

# Can't edit the editors array in the class method
isa-ok Proc::InvokeEditor.editors("/bin/bad"), Failure, "Can't set the class level editor list";

done-testing
