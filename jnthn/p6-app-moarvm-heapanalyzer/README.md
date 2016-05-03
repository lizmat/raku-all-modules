# MoarVM Heap Snapshot Analyzer

This is a command line application for analyzing MoarVM heap snapshots. First,
obtain a heap snapshot file from something running on MoarVM. For example:

    $ perl6 --profile=heap something.p6

Then run this application on the heap snapshot file it produces (the filename
will be at the end of the program output). Type `help` inside the shell to
learn about the set of supported commands.

You may also find [these](https://6guts.wordpress.com/2016/03/27/happy-heapster/)
[two](https://6guts.wordpress.com/2016/04/15/heap-heap-hooray/) posts on the
6guts blog about using the heap analyzer to hunt leaks interesting also.
