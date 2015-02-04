use v6;
use IO::Path::More;
use Test;

plan 31;

ok(IO::Path.^can($_), "$_ method available") for
	<append inode device next previous mkpath rmtree remove touch stat find>;

is path("foo/bar"),			"foo/bar",	"path() works";

is path("/").append('foo'),		"/foo",			"append to root";
is path(".").append('foo', 'bar'),	"foo/bar",		"append multiple";

my @dir = dir('.');
is @dir[2].previous,    @dir[1],  "previous correct";
is @dir[2].path.next,   @dir[3],  "next correct";
is @dir[0].path.previous,   Nil,  "previous from first path is Nil";
is @dir[*-1].path.next,     Nil,  "next from last path is Nil";
is " ".path.previous,       Nil,  "previous from ' ' path is Nil";
is " ".path.next,       @dir[0],  "next from ' ' path is \@dir[0]";
is "~".path.previous, @dir[*-1],  "previous from '~' path is \@dir[*-1]";
is "~".path.next,           Nil,  "next from '~' path is Nil";

ok ".".path.find(:name<t>), "find basic";
ok ".".path.find(:recursive, :name(/00\-more/)), "find with :recursive";

say "# IO tests";
ok path(~$*CWD).e,		"cwd exists, inheritance ok";

if 'foo'.path.e { skip "test path exists", 4; }
else {
    todo "mkpath doesn't return result", 1;
	ok "foo/bar/baz".path.mkpath, 'mkpath ok';
	ok "foo/bar/baz".path.e, 'path made';
	todo "rmtree doesn't return result", 1;
    ok "foo".path.rmtree, "rmtree ok";
	nok "foo".path.e, "dir tree removed";
}


if $*OS ne any( <MSWin32 dos VMS MacOS> ) {
	ok path(~$*CWD).inode,		"inode works";
	ok path(~$*CWD).device,		"device works";
}
else { skip "all unix tests for now", 2; }

done;

