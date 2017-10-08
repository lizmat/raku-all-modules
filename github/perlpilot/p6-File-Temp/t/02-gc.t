use lib <lib>;
use Test;
use File::Temp;

plan 2;

my ($fn, $fh) = tempfile;
is-deeply $fn.IO.e, True, 'file exists when we start';

$fh.DESTROY;
is-deeply $fn.IO.e, False, 'file not longer exists after .DESTROY';
