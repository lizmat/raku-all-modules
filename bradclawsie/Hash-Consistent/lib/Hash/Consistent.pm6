use v6;

=begin pod

=head1 NAME

Hash::Consistent - a perl6 implementation of a Consistent Hash.

=head1 DESCRIPTION

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
    
=head1 SYNOPSIS

    use v6;
    use Hash::Consistent;
    use Subsets::Common;
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

=head1 AUTHOR

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org)

=head1 LICENSE

This module is licensed under the BSD license, see:

https://b7j0c.org/stuff/license.txt

=end pod

unit module Hash::Consistent:auth<bradclawsie>:ver<0.0.1>;

use String::CRC32;
use Subsets::Common;

class X::Hash::Consistent::Collision is Exception is export {
    has $.input;
    has $.hashed;
    method message() { "With $.input, collision on $.hashed in consistent hash" }
}

class X::Hash::Consistent::Corrupt is Exception is export {
    has $.input;
    method message() { "With token $.input, consistent hash is corrupt" }
}

class X::Hash::Consistent::InsertFailure is Exception is export {}
class X::Hash::Consistent::RemoveFailure is Exception is export {}
class X::Hash::Consistent::IsEmpty is Exception is export {}

class Hash::Consistent is export {
    
    has PosInt $.mult is required;  # The number of times to multiply each entry in the consistent hash.
    has PosInt @.sum_list;          # The list of crc32 hashes, maintained in sorted order.
    has NonEmptyStr %!mult_source;  # The mapping of crc32 hash values to the corresponding "mult" string.
    has NonEmptyStr %!source;       # The mapping of the mult_source string to the original input string.
    has Lock $!lock;                # Lock operations that examine or change the state of the consistent hash.
    has PosInt %!hashed;            # A cache of previously computed crc32 hashes.

    submethod BUILD(PosInt:D :$mult) {
        $!mult := $mult;
        $!lock = Lock.new;
    }

    multi method print() returns Bool:D {
        $!lock.protect(
            {
                my $j = 0;
                for self!sorted_hashes() -> $i {
                    say "$j: $i [crc32 of %!mult_source{$i} derived from %!source{%!mult_source{$i}}]";
                    $j++;
                }
            }
        );            
    }

    my sub mult_elt(NonEmptyStr:D $s,Cool:D $i) {
        return $s ~ '.' ~ Str($i);
    }

    method !sorted_hashes() {
        return %!mult_source.keys.map( { Int($_) } ).sort;    
    }

    # Cache CRC32 hashes.
    method !getCRC32(NonEmptyStr:D $s) {
        return %!hashed{$s} if %!hashed{$s}:exists;
        my PosInt $crc32 = String::CRC32::crc32($s);
        %!hashed{$s} = $crc32;
        return $crc32;
    }
    
    method find(NonEmptyStr:D $s) returns NonEmptyStr:D {
        $!lock.protect(
            {
                my Int $mult_source_crc32 = 0; 
                my $n = %!mult_source.keys.elems;
                if (@!sum_list.elems != $n) {
                    X::Hash::Consistent::Corrupt.new(input => $s).throw;
                }
                if $n == 0 {
                    X::Hash::Consistent::IsEmpty.new(payload => 'Cannot find in empty consistent hash').throw;
                }
                my PosInt $crc32 = self!getCRC32($s);
                if ($n == 1) || ($crc32 >= @!sum_list[$n-1]) {
                    # If there is only one element in sum_list, or, if given crc32 is greater than the last
                    # element in the list, then return the 0th element. 
                    $mult_source_crc32 = @!sum_list[0];
                } else {
                    for @!sum_list -> $i {
                        if $i > $crc32 {
                            $mult_source_crc32 = $i;
                            last;
                        }
                    }
                }

                unless %!source{%!mult_source{$mult_source_crc32}}:exists {  
                    X::Hash::Consistent::Corrupt.new(input => $mult_source_crc32).throw;
                }
                return %!source{%!mult_source{$mult_source_crc32}};
            }
        );
    }

   method !remove_one(NonEmptyStr:D $s) {
       my PosInt $crc32 = self!getCRC32($s);
       my $in_list = ($crc32 == @!sum_list.any);
       my $in_mult_source = %!mult_source{$crc32}:exists;
       return if (!$in_list && !$in_mult_source); # Not in the consistent hash.
       if ($in_list && $in_mult_source) {
           %!mult_source{$crc32}:delete;
           @!sum_list = self!sorted_hashes();
           return;
       } else {
           # The instance is corrupt, the string is in only one of the structures.
           X::Hash::Consistent::Corrupt.new(input => $s).throw;
       }
   }
   
   method remove(NonEmptyStr:D $s) {
       $!lock.protect(
           {
               for ^$!mult -> $i {
                   try {
                       self!remove_one(mult_elt($s,$i));
                       CATCH {
                           default {
                               X::Hash::Consistent::RemoveFailure.new(payload => $!.message()).throw;
                           }
                       }
                   }
               }
           }
       );
    }

    method !insert_one(NonEmptyStr:D $mult_s,$s) {
        my PosInt $crc32 = self!getCRC32($mult_s);
        if $crc32 == @!sum_list.any {
            if %!mult_source{$crc32}:exists {
                # Just return, the string is already in the consistent hash.
                return; 
            } else {
                # The string is not in the consistent hash yet produces a crc32
                # that collides with an existing entry.
                X::Hash::Consistent::Collision.new(input => $mult_s,hashed => $crc32).throw;
            }
        }
        %!mult_source{$crc32} = $mult_s;
        @!sum_list = self!sorted_hashes();
        %!source{$mult_s} = $s;
        return;
    }
    
    method insert(NonEmptyStr:D $s) {
       $!lock.protect(
           {
               for ^$!mult -> $i {
                   try {
                       self!insert_one(mult_elt($s,$i),$s);
                       CATCH {
                           default {
                               # If any insert failed, we must remove any insertions made for $s.
                               self.remove($s);
                               X::Hash::Consistent::InsertFailure.new(payload => $!.message()).throw;
                           }
                       }
                   }
               }
           }
       );
    }
}

