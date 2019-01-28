use v6.c;
use Test;
use P5getpriority;

plan 8;

ok getppid() > 0, "got parent process ID &getppid()";
ok getpgrp() > 0, "got group process ID &getpgrp()";

ok -20 <= getpriority(0, getppid) <= 20,
  "got process priority &getpriority(0,getppid)";

ok -20 <= getpriority(0, $*PID) <= 20,
  "got process priority is &getpriority(0, $*PID)";

ok -20 <= getpriority(1, getpgrp) <= 20,
  "got process group priority &getpriority(1, getpgrp)";

ok -20 <= getpriority(2, $*USER) <= 20,
  "got user priority is &getpriority(2, $*USER)";

lives-ok { setpgrp(0, 0) },              'can we setpgrp without dying';
lives-ok { setpriority(0, $*PID, -20) }, 'can we setpriority without dying';

# vim: ft=perl6 expandtab sw=4
