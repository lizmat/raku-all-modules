# TITLE
Hash::MultiValue

[![Build Status](https://travis-ci.org/zostay/p6-Hash-MultiValue.svg?branch=master)](https://travis-ci.org/zostay/p6-Hash-MultiValue)

# SUBTITLE
Store multiple values per key, but act like a regular hash too

# SYNOPSIS

    my %mv := Hash::MultiValue.from-pairs: (a => 1, b => 2, c => 3, a => 4);
    
    say %mv<a>; # 4
    say %mv<b>; # 2
    
    say %mv('a').join(', '); # 1, 4
    say %mv('b').join(', '); # 2
    
    %mv<a>   = 5;
    %mv<d>   = 6;
    %mv('e') = 7, 8, 9;
    
    say %mv.all-pairs».fmt("%s: %s").join("\n");
    # a: 5
    # b: 2
    # c: 3
    # d: 6
    # e: 7
    # e: 8
    # e: 9

# DESCRIPTION

This class is useful in cases where a program needs to have a hash that may or may not have multiple values per key, but frequently assumes only one value per key. This is commonly the case when dealing with URI query strings. This class also generally preserves the order the keys are encountered, which can also be a useful characteristic when working with query strings.

If some code is handed this object where a common Associative object (like a Hash) is expected, it will work as expected. Each value will only have a single value available. However, when one of these objects is used as function or using the various .all-* alternative methods, the full multi-valued contents of the keys can be fetched, modified, and iterated.

# Methods

##  method from-pairs

    multi method from-pairs(@pairs) returns Hash::MultiValue
    multi method from-pairs(*@pairs) returns Hash::MultiValue

This takes a list of pairs and constructs a Hash::MultiValue object from it. Use this method or /method from-mixed-hash instead of /new. Multiple pairs with the same key may be included in this list and all values will be associated with that key. 

Please note, that because of the way Perl 6 handles pairs in slurpy context, you may need to wrap them in a list for this to work:

    # THIS
    my %h := Hash::MultiValue.from-pairs: (a => 1, b => 2);
    # NOT this
    my %h := Hash::MultiValue.from-pairs(a => 1, b => 2);

##  method from-mixed-hash

    multi method from-mixed-hash(%hash)
    multi method from-mixed-hash(*%hash)

This takes a hash and constructs a new Hash::MultiValue from it. If any value in the hash is Positional, it will be interpreted as a multi-valued key. If you need Positional objects preserved as values, then you'll have to use /method from-pairs instead and build your own list of pairs for construction. That method is more precise.

##  method postcircumfix:<{ }>

    method postcircumfix:<{ }> (%key) is rw

Whenever reading or writing keys using the { } operator, the hash will behave as a regular built-in Hash. Any write will overwrite all values that have been set on the multi-value hash with a single value. 

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    %mv<a> = 4;
    say %mv('a').join(', '); # 4

Any read will only read a single value, even if multiple values are stored for that key. 

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv<a>; # 3

Of those values the last value will always be used. This is in keeping with the usual semantics of what happens when you add two pairs with the same key twice in Perl 6.

You may also use the :delete and :exists adverbs with these objects.

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv<a> :delete; # 3 (both 1 and 3 are gone)
    say %mv<b> :exists; # True

One operation that is not supported by Hash::MultiValue is binding. For example,

    my $a = 4;
    %mv<a> := $a;
    $a = 5;
    say %mv<a>; # 4

Binding is not supported at this time, but might be in the future.

##  method postcircumfix:<( )>

    method postcircumfix:<( )> ($key) is rw

The ( ) operator may be used in a fashion very similar to { }, but in that it always works with multiple values. You may use it to read multiple values from the object:

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    say %mv('a').join(', '); # 1, 3

You may also use it to write multiple values, which will replace all values currently set for that key:

    my %mv := Hash::MultiValue.from-pairs(a => 1, b => 2, a => 3);
    %mv('a') = 4, 5;
    %mv('b') = 6, 7;
    %mv('c') = 8;
    say %mv('a').join(', '); # 4, 5
    say %mv('b').join(', '); # 6, 7
    say %mv('c').join(', '); # 8

At this time, this operator does not support slices (i.e., using a Range or List of keys to get values for more than one key at once). This might be supported in the future.

##  method kv

Returns a list alternating between key and value. Each key will only be listed once with a singular value. See /method all-kv for a multi-value version.

##  method pairs

Returns a list of Pair objects. Each key is returned just once pointing to the last (or only) value in the multi-value hash. See /method all-pairs for the multi-value version.

##  method antipairs

This is identical to /method pairs, but with the value and keys swapped.

##  method invert

This is a synonym for /method antipairs.

##  method keys

Returns a list of keys. Each key is returned exactly once. See /method all-keys for the multi-value version.

##  method values

Returns a list of values. Only the last value of a multi-value key is returned. See /method all-values for the multi-value version.

##  method all-kv

Returns a list alternating between key and value. Multi-value key will be listed more than once.

##  method all-pairs

Returns a list of Pair objects. Multi-value keys will be returned multiple times, once for each value associated with the key.

##  method all-antipairs

This is identical to /method all-pairs, but with key and value reversed.

##  method all-invert

This is a synonym for /method all-antipairs.

##  method keys

This returns a list of keys. Multi-valued keys will be returned more than once. If you want the unique key list, you want to see /method keys.

##  method values

This returns a list of all values, including the multiple values on a single key.

##  method push

    method push(*@values)

This adds new pairs to the list. Any pairs given with a key matching an existing key will cause the single value version of that key to be replaced with the new value. This never overwrites existing values.

##  method perl

Returns code as a string that can be evaluated with EVAL to recreate the object.

##  method gist

Like /method perl, but only includes up to the first 100 keys.
