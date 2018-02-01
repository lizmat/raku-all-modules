use lib <lib>;
use Subsets::IO :e;

say $?FILE.IO ~~ IO::Path::e;
-> IO::Path::e {}($?FILE.IO.add: "meow");
