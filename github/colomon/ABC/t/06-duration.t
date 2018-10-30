use v6;
use Test;
use ABC::Duration;

is duration-from-parse("2", "3").ticks.perl, (2/3).perl, "2/3 works properly";
ok duration-from-parse("2", "3") ~~ ABC::Duration, "2/3 generates an object which does Duration";
is duration-from-parse(Any, Any).ticks.perl, (1/2).perl, "/ works properly";
ok duration-from-parse(Any, Any) ~~ ABC::Duration, "/ generates an object which does Duration";

is duration-from-parse("1", Any).ticks.perl, (1/2).perl, "1/ works properly";
is duration-from-parse(Any, "2").ticks.perl, (1/2).perl, "/2 works properly";

is duration-from-parse("1").ticks.perl, (1).perl, "1 works properly";
is duration-from-parse(Any).ticks.perl, (1).perl, "'' works properly";

done-testing;
