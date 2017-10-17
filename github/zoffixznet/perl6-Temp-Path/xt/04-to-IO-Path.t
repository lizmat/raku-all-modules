use lib <lib>;
use Testo;
use Temp::Path;
plan 4;

is make-temp-path.WHAT === IO::Path, *.not, 'made path is not === IO::Path';
is make-temp-dir.WHAT  === IO::Path, *.not, 'made dir  is not === IO::Path';
is make-temp-path.to-IO-Path.WHAT === IO::Path,
  *.so, 'made path with .to-IO-PATH is now === IO::Path';
is make-temp-dir.to-IO-Path.WHAT  === IO::Path,
  *.so, 'made path with .to-IO-PATH is now === IO::Path';
