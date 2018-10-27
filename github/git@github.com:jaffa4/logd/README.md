# Log::D

The module provides support for logging. There are different type of logging: error, warning, debug, verbose, info and plain.

You create a log object, then you call methods e,w,d,v,i or p. Methods accept one argument, the logging message or two , section and message.
Sections can be allowed or banned. Logging types can be enebled or disabled.
The prefix of the log message can be given by a prefix function. Default output is $*ERR.


## Usage

    use Log::D;

    my $f = Log::D.new(:w,:i); # create a new object , enable warning and infos

    $f.prefix = sub { callframe(2).file~" "~callframe(2).line~" "~$*THREAD.id~" "~DateTime.now~" ";   }; #show line number of logging

    $f.i("reached destructor");

    $f.enable(:v); # let us enable verbose error messages too

    $f.allow("engine func"); # if no allow is given, everything is allowed
    $f.i("engine func", "engine starting");

    $f.remove_allow("engine func"); # it is not longer allowed, if no allow left, all is turned on
    $f.ban("low level func"); # or use ban, then it is not displayed for sure
    $f.i("low level func", "print invoice");

    $f.remove_ban("low level func"); # need to be able to remove it

    $f.o = $*OUT; # change output of the log

    use Log::Empty;
    my $f = Log::Empty.new(:w,:i);   # all logging is off.. useful to replace Log::D with Log::Empty 

    $f.notify = True;  # show bans, allows..etc in the log as well to track their usages



