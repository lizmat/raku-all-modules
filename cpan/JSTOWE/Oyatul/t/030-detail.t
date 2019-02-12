#!perl6

use v6;

use Test;


use Oyatul;

use lib $*PROGRAM.parent.add('lib').absolute;

my $layout;

lives-ok { $layout = Oyatul::Layout.from-json(path => 't/data/couchapp.layout', root => 't/test-root'); }, "create from file";

my $id;
is $layout.root, 't/test-root', "got the root";
ok $id = $layout.nodes-for-purpose('id').first, 'nodes-for-purpose';
isa-ok $id, Oyatul::File, "and it is a file";
my $role = (require ::('IDRole') );
does-ok $id, $role, "and it does the role we specified";
is $id.name, '_id', "and the one we expected";

my $view-template;


lives-ok { $view-template = $layout.template-for-purpose('view') } , "template-for-purpose";
does-ok $view-template, Oyatul::Template, "and it is a template";


my $real-view;

lives-ok { $real-view = $view-template.make-real('by-name') }, "make-real";
nok $real-view ~~ Oyatul::Template, "and that isn't a Template";
ok $real-view.parent.child-by-name('by-name'), "and it's there with child-by-name";
is $real-view.path, "t/test-root/views/by-name", 'and that has the right path';
lives-ok { $layout.create }, "create with realised template";

for $layout.all-children(:real) -> $child {
    nok $child ~~ Oyatul::Template, "not a Template with :real on all-children";
    ok $child.IO.e, "path got by all-children '{ $child.path }' exists";
}

lives-ok { $layout = Oyatul::Layout.from-json(path => 't/data/couchapp.layout', root => 't/test-root', :real);  }, "create from file with real";
for $layout.all-children(:real) -> $child {
    ok $child.IO.e, "path got by all-children '{ $child.path }' exists (with template instances)";
}

ok $real-view = $layout.nodes-for-purpose('view', :real).first, "get the real one that should have been created";
is $real-view.name, 'by-name', "and it is the one that we expected";
is $real-view.path, "t/test-root/views/by-name", 'and that has the right path';
ok $real-view.IO.e, "and it does actually exist";


lives-ok { ok $layout.delete, "delete" }, "delete (with templates)";

for $layout.all-children(:real) -> $child {
    nok $child.IO.e, "path got by all-children '{ $child.path }' no longer exists";
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
