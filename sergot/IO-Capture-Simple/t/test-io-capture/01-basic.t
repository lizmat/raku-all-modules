use Test::IO::Capture;
use Test;

plan 3;

prints-stdout-ok { say 'zebra!' }, "zebra!\n", 'prints-stdout-ok';

prints-stderr-ok { note 'giraffe!' }, "giraffe!\n", 'prints-stderr-ok';

pass 'if this works, then stdout is back to normal';
