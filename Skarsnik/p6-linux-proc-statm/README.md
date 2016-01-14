#Name Linux::Proc::Statm

#Usage

```perl
 use Linux::Proc:Statm;
 my %meminfo = get-statm(42); #get info for the pid 42
 say %meminfo<data>; # data + stack size
 say get-statm.perl; #use $*PID
```

Values are given in Kb.

#Author

Sylvain "Skarsnik" Colinet <scolinet@gmail.com>

