[toc]

# Benchmark tests

The benchmark tests are setup to follow the improvement in speed while encoding and decoding a document. While promises are used to speedup the tests a little, some other tests are devised to look into the difference per BSON type. I imagine that some of the types are so simple to encode/decode that setting up a thread for the calculations would take more overhead than that it would speed up.

## Document encoding/decoding

Tests of encoding two series of 16 types, inserted into a newly created document. Then the result is decoded again. This is repeated 50 times.

### Test notes and measurements

| Date | What | Wallclock sec | n per sec |
|------|------|---------------|-----------|
|| With use of Promises on encoding as well as decoding| 8.0726 | 6.1938
|| Removed Promises on decoding (dropped) | 9.5953 | 5.2109
|| After some cleanup of D1 | 7.0094 | 7.1333
|| Replaced Hash $!data with @!values in D1 | 6.9710 | 7.1726
|| Replaced %!promises with @!promises (dropped) | 7.2508 | 6.8958
|| Optional use of autovivify and hashes, restorage of buf parts | 11.3167 | 4.4182
|| A few methods modified into subs | 9.4807 | 5.2739
|| Removing Positional role (dropped) | 10.0837 | 4.9585
|| Bugfixes and improvements. Perl 2015 12 24 | 7.8202 | 6.3937
|| Native encoding/decoding for doubles | 6.4880 | 7.7066
| 20160610 | 2016.06-178-gf7c6e60, MoarVM 2016.06-9-g8fc21d5 | 2.7751 | 18.0171
| 20161108 | 2016.10-204-g824b29f, MoarVM 2016.10-37-gf769569 | 2.5247 | 19.8041
| 20170225 | 017.02-56-g9f10434, MoarVM 2017.02-7-g3d85900 | 2.3827 | 20.9844
| 20170225 | Dropped positional role from BSON::Document | 2.3011 | 21.7285
| 20170718 | 2017.07-19-g1818ad2, bugfix hangup decoding | 3.3968 | 14.7199

###  Original BSON methods with hashes.
* I think this was about 2015 06 or so. In the mean time Hashing should be faster too!
  3.1644 wallclock secs @ 15.8006/s (n=50)


### Worries
- Tests sometimes crashes with coredumps. Is it Bench or BSON::Document??
Segmentation fault (core dumped)


## Benchmarks double.pm6

Timing 3000 iterations ....

| Date | What | Wallclock sec | n per sec |
|------|------|---------------|-----------|
| 20160420 | rakudo 2016.02-136-g412d9a4, MoarVM 2016.02-25-gada3752
|| double emulated encode | 7.565150 | 396.5552
|| double emulated decode | 1.223361 | 2452.2613
|| double native encode | 2.048168 | 1464.7237
|| double native decode | 0.926162 | 3239.1732
| 20170812 | rakudo 2017.07-91-g7e08f74 built on MoarVM 2017.07-15-g0729f84
|| double emulated encode | 4.8237 | 621.9242
|| double emulated decode | 0.2486 | 12066.0512
|| double native encode | 0.3425 | 8758.5662
|| double native decode | 0.2707 | 11083.7616

Conclusion: it is not worth to keep the emulated encode/decode for double (Num). The emulated code was the original implementation before NativeCall was explored.

## Benchmarks int.pl6

### 2017 08 12
#### Rakudo version 2017.07-91-g7e08f74 built on MoarVM version 2017.07-15-g0729f84**

Timing 3000 iterations ....

| Date | What | Wallclock sec | n per sec|
|------|------|---------------|----------|
| 20170812 | rakudo 2017.07-91-g7e08f74, MoarVM 2017.07-15-g0729f84||
||32 bit integer decode | 0.0321 | 62385.0167
||32 bit integer encode | 0.0615 | 32494.3486
||32 bit native integer decode | 0.0870 | 22999.6250
||64 bit integer decode | 0.0397 | 50397.2193
||64 bit integer encode | 0.0756 | 26438.7454
||64 bit native integer decode | 0.0942 | 21226.7633

Conclusion: it is not worth to do native decode for any type of integer.
