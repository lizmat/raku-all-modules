# Name Linux::Proc::Statm

# Usage

```perl
 use Linux::Proc::Statm;
 my %meminfo = get-statm(42); #get info for the pid 42
 say %meminfo<data>; # data + stack size
 say get-statm.perl; #use $*PID
 say get-statm-human<data>; # 54.552 kB
```

Values are given in Kb by default. You can change this behavior by passing a `:unit` named parameter with etheir b, k or m according to the unit you want.

```perl
say get-statm-human(:unit<m>)<data>; # 53 mB
```

# Author

Sylvain "Skarsnik" Colinet <scolinet@gmail.com>

