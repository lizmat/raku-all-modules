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
is @dir[2].next,   @dir[3],  "next correct";
is @dir[0].previous,   Nil,  "previous from first path is Nil";
is @dir[*-1].next,     Any,  "next from last path is Nil";
is "\x01".IO.previous,       Nil,  'previous from low sorting path ("\x01") is Nil';
is "\x01".IO.next,       @dir[0],  "next from low sorting path (\"\x01\") is \@dir[0]";
is "~".IO.previous, @dir[*-1],  "previous from high sorting path ('~') is \@dir[*-1]";
is "~".IO.next,           Nil,  "next from high sorting path ('~') is Nil";
         
ok ".".IO.find(:name<t>), "find basic";
ok ".".IO.find(:recursive, :name(/00\-more/)), "find with :recursive";

say "# IO tests";
ok path(~$*CWD).e,		"cwd exists, inheritance ok";

if 'foo'.IO.e { skip "test path exists", 4; }
else {
    todo "mkpath doesn't return result", 1;
	ok "foo/bar/baz".IO.mkpath, 'mkpath ok';
	ok "foo/bar/baz".IO.e, 'path made';
	todo "rmtree doesn't return result", 1;
    ok "foo".IO.rmtree, "rmtree ok";
	nok "foo".IO.e, "dir tree removed";
}


if $*DISTRO.name ne any( <MSWin32 dos VMS MacOS> ) {
	ok path(~$*CWD).inode,		"inode works";
	ok path(~$*CWD).device,		"device works";
}
else { skip "all unix tests for now", 2; }

done-testing;

