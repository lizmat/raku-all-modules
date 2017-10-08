use lib <lib>;
use Testo;

plan 10;

use IO::Dir;

given IO::Dir.new.open: '.' {
    is $_, IO::Dir;
    my $res = .dir;
    is $res, Seq;
    is $res.grep({.basename eq 't'}), True;
    is .close, IO::Dir;
}

given IO::Dir.new.open: 't/test-dir' {
    is $_, IO::Dir;
    my $res = .dir;
    is $res, Seq;
    is $res.map({.WHAT}).unique, (IO::Path,);
    is $res.map({.absolute}).sort.List,
      <one two three>.map({'t/test-dir'.IO.add($_).IO.absolute}).sort.List;
    is $res[3].defined, *.not;
    is .close, IO::Dir;
}
