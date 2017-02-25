Tests of 2 * 16 types of insertions and repeated 50 times

Timing 50 iterations of 32 inserts... (* is current BSON::Document use) 

 D1     With use of Promises on encoding as well as decoding
 D2     Removed Promises on decoding -> dustbin
 D3     After some cleanup of D1
 D4     Replaced Hash $!data with @!values in D1
 D5     Replaced %!promises with @!promises -> dustbin
 D6     Optional use of autovivify and hashes, restorage of buf parts.
 D7     A few methods modified into subs
 D8     Removing Positional role -> dustbin
 D9     Bugfixes and improvements
 D10    Native encoding/decoding for doubles
 D11    version 2016.06-178-gf7c6e60 built on MoarVM version 2016.06-9-g8fc21d5
 D12    2016-11-08, 2016.10-204-g824b29f built on MoarVM version 2016.10-37-gf769569
 D13    2017-02-25. 017.02-56-g9f10434 built on MoarVM version 2017.02-7-g3d85900

 H      Original BSON methods with hashes


 D1     8.0726 wallclock secs @ 6.1938/s (n=50)
 D2     9.5953 wallclock secs @ 5.2109/s (n=50) Slower without Promise
 D3     7.0094 wallclock secs @ 7.1333/s (n=50) Cleanup improved speed
 D4     6.9710 wallclock secs @ 7.1726/s (n=50)
 D5     7.2508 wallclock secs @ 6.8958/s (n=50) Slower with @!promises
 D6    11.3167 wallclock secs @ 4.4182/s (n=50) Terrible slow
 D7     9.4807 wallclock secs @ 5.2739/s (n=50) Small changes
 D8    10.0837 wallclock secs @ 4.9585/s (n=50) Doen't help much
 D9     7.8202 wallclock secs @ 6.3937/s (n=50) Perl 2015 12 24
 D10    6.4880 wallclock secs @ 7.7066/s (n=50) again a bit better
 D11    2.7751 wallclock secs @ 18.0171/s (n=50) big improvement
 D12    2.5247 wallclock secs @ 19.8041/s (n=50)
 D13*   2.3827 wallclock secs @ 20.9844/s (n=50)


 H      3.1644 wallclock secs @ 15.8006/s (n=50)



Worries;
D5 and D6 sometimes crashes with coredumps. Is it Bench or BSON::Document??
Segmentation fault (core dumped)


benchmarks/double.pm6

1) 2016 04 20
   Rakudo version 2016.02-136-g412d9a4
   MoarVM version 2016.02-25-gada3752 implementing Perl 6.c.

  emulated encode
    1) 3000 runs total time = 7.565150 s, 0.002522 s per run, 396.555238 runs per s

  native encode
    1) 3000 runs total time = 2.048168 s, 0.000683 s per run, 1464.723704 runs per s

  emulated decode
    1) 3000 runs total time = 1.223361 s, 0.000408 s per run, 2452.261307 runs per s

  native decode
    1) 3000 runs total time = 0.926162 s, 0.000309 s per run, 3239.173228 runs per s


benchmarks/int64.pm6

1) 2016 04 20
   Rakudo version 2016.02-136-g412d9a4
   MoarVM version 2016.02-25-gada3752 implementing Perl 6.c.

  emulated encode
    1) 3000 runs total time = 0.856549 s, 0.000286 s per run, 3502.425992 runs per s

  native encode
    1) 3000 runs total time = 1.764482 s, 0.000588 s per run, 1700.215580 runs per s

  emulated decode
    1) 3000 runs total time = 0.703039 s, 0.000234 s per run, 4267.190570 runs per s

  native decode
    1) 3000 runs total time = 1.040393 s, 0.000347 s per run, 2883.526640 runs per s

Conclusion: not worth it to do native encode/decode for any type of integer.
