use v6;
use Test;

plan 27;

use-ok 'JsonC';

my $Str = '{ "foo": "mamá", "arr": [ 1, 4, 10 ] }';

my \JSON = ::('JsonC::JSON');

ok JSON !~~ Failure,         'Class JSON ready';

my $json = JSON.new($Str);

ok $json, "Created";
isa-ok $json,	JSON;
does-ok $json,  Associative;
ok Hash ~~ $json,	     "Smart match";  # Please note the order

given $json {
   is .Str, $Str,  "The spected Str";

   is .elems,  2,	     'Two elems';

   isa-ok .get-type, Hash,   "Expected type (Hash)";

   is %$_.keys.sort, <arr foo>, 'The keys';

   ok $_<foo>:exists,	     'Exists';

   is $_<foo>, 'mamá',	     "Expected '$json<foo>'";

   nok $_<bar>:exists,	     'Not exists';

}

ok (my @a := $json<arr>),   'arr exists';

isa-ok @a,                  JSON;

does-ok @a,                 Positional;

isa-ok @a.get-type, Array,  "Expected type (Array)";

nok @a ~~ Array,	    'Beware, no a real Array';

isa-ok @a, 'JsonC::JSON-P', 'In fact a JsonC::JSON-P';

ok Array ~~ @a,		    "Reverse Smart match works";

is @a, '[ 1, 4, 10 ]',	    "Seems good: @a[]";

is @a.elems,  3,	    'size';
is +@a,       3,	    'Numeric';

is @a[1],  4,		    'a four';

ok (my @c := Array(@a)),    'Cast works';
ok @a == @c,		    'Same';

# An speed test.
my sub findProyectsFile(Str $prefix?) {
    my (@repos, $target, $pandadir);
    if defined $prefix {
	@repos.push: CompUnit::RepositoryRegistry.repository-for-spec($prefix);
    }
    @repos.append: <site home>.map({CompUnit::RepositoryRegistry.repository-for-name($_)});
    @repos.=grep(*.defined);
    for @repos {
	$target = $_;
	$pandadir = $target.prefix.child('panda');
	try $pandadir.mkdir;
	last if $pandadir.w;
    }
    if $pandadir.w && $pandadir.child('projects.json') -> $_ {
	$_.f && $_;
    } else { Nil }
}

with findProyectsFile() -> $_ {
    diag "Trying to read $_";
    my $start = now;
    ok (my @pf := JSON.new-from-file($_)),   'Can read file';
    diag "Last module is '{@pf[@pf.elems-1]<description>}";
    diag "Parsed at { now - $start }s. @pf.elems() projects";
} else {
    skip 'No file for test',  1;
}


