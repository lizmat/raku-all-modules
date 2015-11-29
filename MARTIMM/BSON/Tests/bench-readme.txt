Tests of 2 * 16 types of insertions and repeated 50 times



Timing 50 iterations of 32 inserts... (* is current BSON::Document use) 

 D1     With use of Promises on encoding as well as decoding
 D2     Removed Promises on decoding
 D3     After some cleanup of D1
 D4*    Replaced Hash $!data with @!values in D1
 D5     Replaced %!promises with @!promises (destroyed again)
 H      Original BSON methods with hashes


 D1     8.0726 wallclock secs @ 6.1938/s (n=50)
 D2     9.5953 wallclock secs @ 5.2109/s (n=50)         Slower without Promise
 D3     7.0094 wallclock secs @ 7.1333/s (n=50)         Cleanup improved speed
 D4*    6.9710 wallclock secs @ 7.1726/s (n=50)
 D5     7.2508 wallclock secs @ 6.8958/s (n=50)         Slower with @!promises

 H      3.1644 wallclock secs @ 15.8006/s (n=50)

