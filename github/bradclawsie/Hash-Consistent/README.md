[![Build Status](https://travis-ci.org/bradclawsie/Hash-Consistent.png)](https://travis-ci.org/bradclawsie/Hash-Consistent)

# Hash::Consistent 

A perl6 implementation of a Consistent Hash.

## DESCRIPTION

A "consistent" hash allows the user to create a data structure in which a set of string
flags are entered in the hash at intervals specified by the CRC32 hash of the flag.
Optionally, each flag can have suffixes appended to it in order to create multiple
entries in the hash.

Once flags are entered into the hash, we can find which flag would be associated with
a candidate string of our choice. A typical use-case for this is to enter host
names into the hash the represent destination hosts where values are stored
for particular keys, as determined by the result of searching for the corresponding
flag in the hash. 
                                         
This technique is best explained in these links:

http://en.wikipedia.org/wiki/Consistent_hashing

http://www.tomkleinpeter.com/2008/03/17/programmers-toolbox-part-3-consistent-hashing/
    
## SYNOPSIS

    use v6;
    use Hash::Consistent;
    use String::CRC32;
    use Test;

    my $ch = Hash::Consistent.new(mult=>2);
    $ch.insert('example.org');
    $ch.insert('example.com');
    is $ch.sum_list.elems(), 4, 'correct hash cardinality';
    # > $ch.print();
    # 0: 2725249910 [crc32 of example.org.0 derived from example.org]
    # 1: 3210990709 [crc32 of example.com.1 derived from example.com]
    # 2: 3362055395 [crc32 of example.com.0 derived from example.com]
    # 3: 3581359072 [crc32 of example.org.1 derived from example.org]

    # > String::CRC32::crc32('blah');
    # 3458818396
    # (should find next at 3581359072 -> example.org)
    is $ch.find('blah'), 'example.org', 'found blah -> example.org';

    # > String::CRC32::crc32('whee');
    # 3023755156
    # (should find next at 3210990709 -> example.com)
    is $ch.find('whee'), 'example.com', 'found whee -> example.com';

## AUTHOR 

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org) 

## LICENSE 

This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt

