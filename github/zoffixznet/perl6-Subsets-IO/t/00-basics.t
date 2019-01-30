use lib <lib>;
use Temp::Path;
use Testo;
use Subsets::IO;

plan 33;

constant \is-windows = BEGIN $*DISTRO.is-win;
my sub skip-on-windows(&code) {
    return skip 'on windows' if is-windows;
    code
}

my $f := make-temp-path :content<foo>;
my $d := make-temp-dir;

is $f,            IO::Path::e, ':e';
is $f.add('bar'), IO::Path::E, ':E';
is $f,            IO::Path::f, ':f';
is $f.add('bar'), IO::Path::F, ':F';
is $d,            IO::Path::F, ':F (dir)';
is $d,            IO::Path::d, ':d';
is $f,            IO::Path::D, ':D';

is $f.add('bar') ~~ IO::Path::e, *.not, ':e (false)';
is $f            ~~ IO::Path::E, *.not, ':E (false)';
is $d            ~~ IO::Path::f, *.not, ':f (false)';
is $f            ~~ IO::Path::F, *.not, ':F (false)';
is $f            ~~ IO::Path::d, *.not, ':d (false)';
is $d            ~~ IO::Path::D, *.not, ':D (false)';

$f.chmod: 0o444;
is $f, IO::Path::fr, ':fr';

$f.chmod: 0o000;
skip-on-windows { is $f !~~ IO::Path::fr, *.so, ':fr (false)'; }

$f.chmod: 0o666;
is $f, IO::Path::frw, ':frw';
$f.chmod: 0o000;
is $f !~~ IO::Path::frw, *.so, ':frw (false)';

$f.chmod: 0o555;
skip-on-windows { is $f, IO::Path::frx, ':frx'; }
$f.chmod: 0o000;
is $f !~~ IO::Path::frx, *.so, ':frx (false)';

$f.chmod: 0o333;
skip-on-windows { is $f, IO::Path::fwx, ':fwx'; }
$f.chmod: 0o000;
is $f !~~ IO::Path::fwx, *.so, ':fwx (false)';

$f.chmod: 0o777;
skip-on-windows { is $f, IO::Path::frwx, ':frwx'; }
$f.chmod: 0o000;
is $f !~~ IO::Path::frwx, *.so, ':frwx (false)';

$d.chmod: 0o444;
is $d, IO::Path::dr, ':dr';

$d.chmod: 0o000; # doesn't work on windows
skip-on-windows { is $d !~~ IO::Path::dr, *.so, ':dr (false)'; }

$d.chmod: 0o666;
is $d, IO::Path::drw, ':drw';
$d.chmod: 0o000;
is $d !~~ IO::Path::drw, *.so, ':drw (false)';

$d.chmod: 0o555;
is $d, IO::Path::drx, ':drx';
$d.chmod: 0o000;
skip-on-windows { is $d !~~ IO::Path::drx, *.so, ':drx (false)'; }

$d.chmod: 0o333;
is $d, IO::Path::dwx, ':dwx';
$d.chmod: 0o000;
is $d !~~ IO::Path::dwx, *.so, ':dwx (false)';

$d.chmod: 0o777;
is $d, IO::Path::drwx, ':drwx';
$d.chmod: 0o000;
is $d !~~ IO::Path::drwx, *.so, ':drwx (false)';
