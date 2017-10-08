use lib <lib>;
use Testo;
use Temp::Path;
plan 13;

is make-temp-dir,               IO::Path;
is make-temp-dir :chmod<0o666>, IO::Path;

with make-temp-dir { is $_, IO::Path, 'no gobbling of blocks' }

with run :err, :out, $*EXECUTABLE, '-Ilib',
    ('-I' «~« $*REPO.repo-chain.map: *.path-spec), '-MTemp::Path', '-e', ｢
    with make-temp-dir { .e or die; print .absolute }
  ｣
{
    my $dir = .out.slurp: :close;
    is $dir, *.so, 'we received a dir name from proc';
    is ($dir and $dir.IO.e), *.not, "temp dir got deleted ($dir)";
    is .err.slurp(:close), '', 'nothing on STDERR';
}

for 0o620, 0o723, 0o621, 0o700, 0o633, 0o777, 0o672 -> $m {
    is make-temp-dir :chmod($m) .mode, $m, ":chmod(0o{$m.fmt("%o")}) works";
}
