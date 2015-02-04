use v6;
use NativeCall;

sub fork() returns Int is native { ... }

my $children = 15;
for 1 .. $children -> $child {
    my $pid = fork();
    if $pid {
        print "created child $child process $pid. ";
        sleep 1; print "snore. ";
    }
    else {
        for $child .. $children { sleep 1; print "yawn $child. "; }
        exit 0;
    }
}

# Notes:
# * This code can hang your computer, depending on the number of
#   children versus your real and virtual memory.  For example, a 1GB
#   netbook froze with 19 children.
# * Monitor your processes with a utility such as pstree or top.
