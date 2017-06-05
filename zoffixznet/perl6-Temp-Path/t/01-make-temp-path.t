use lib <lib>;
use Testo;
use Temp::Path;
plan 31;

is make-temp-path, IO::Path;
is make-temp-path :chmod<0o666>, IO::Path;
is make-temp-path :chmod<0o666> :content<foos>, IO::Path;

with make-temp-path { is $_, IO::Path, 'no gobbling of blocks' }

with run :err, :out, $*EXECUTABLE, '-Ilib', '-MTemp::Path', '-e', ｢
    with make-temp-path :content<bars> {
        .slurp(:close) eq 'bars' or die;
        print .absolute
    }
  ｣
{
    my $file = .out.slurp: :close;
    is $file, *.so, 'we received a filename from proc';
    is ($file and $file.IO.e), *.not, "temp file got deleted ($file)";
    is .err.slurp(:close), '', 'nothing on STDERR';
}

is make-temp-path :content($_) .slurp,
    $_, 'content matches'
with join '', "foo\nb\x[0]ar♥\nmeows" xx ^10 .pick;

is make-temp-path :content($_) :chmod<0o666> .slurp,
    $_, 'content matches when we also use :chmod'
with join '', "foo\nb\x[0]ar♥\nmeows" xx ^10 .pick;

is make-temp-path :chmod<0o666> .slurp, '',
    'content defaults to empty when we use :chmod';

for 0o620, 0o723, 0o621, 0o700, 0o633, 0o777, 0o672 -> $m {
    is make-temp-path :chmod($m) .mode, $m, ":chmod(0o{$m.fmt("%o")}) works";
    with make-temp-path :content("foos$m") :chmod($m) {
        my $m-str = ":chmod(0o{$m.fmt("%o")})";
        is .mode,   $m,      "$m-str works with explicit :content";
        is .slurp, "foos$m", "$m-str file has right :content";
    }
}
