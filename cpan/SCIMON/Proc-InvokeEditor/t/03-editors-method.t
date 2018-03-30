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

# Setting a non existent ENV var in editors_env does nothing.
my $key = get-env-key();
is $invoker.editors_env($key), @editors, "Passing a non existant key does nothing";

%*ENV{$key} = "/bin/thing";
@editors.unshift("/bin/thing");
is $invoker.editors_env($key), @editors, "ENV key exists prepend to list";
is $invoker.editors(), @editors, "Update stays";

@editors.unshift("/usr/bin/foo","/usr/bin/foo2");
is $invoker.editors_prepend(["/usr/bin/foo","/usr/bin/foo2"]), @editors, "Editor prepend works";
is $invoker.editors(), @editors, "Update stays";

# Can't edit the editors array in the class method
isa-ok Proc::InvokeEditor.editors("/bin/bad"), Failure, "Can't set the class level editor list";
isa-ok Proc::InvokeEditor.editors_env("BAD"), Failure, "Can't call editors ENV as a class method";
isa-ok Proc::InvokeEditor.editors_prepend("/usr/bin/foo"), Failure, "Can't call editors ENV as a class method";

done-testing;

sub get-env-key() {
    my $key = "a";
    while ( defined %*ENV{$key} ) {
        $key ~= "a";
    }
    $key;
}
