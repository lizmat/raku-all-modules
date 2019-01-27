[![Build Status](https://travis-ci.org/lizmat/Memoize.svg?branch=master)](https://travis-ci.org/lizmat/Memoize)

NAME
====

Memoize - Port of Perl 5's Memoize 1.03

SYNOPSIS
========

    use Memoize;
    memoize(&slow_function);
    slow_function(arguments);    # Is faster than it was before

This is normally all you need to know. However, many options are available:

    memoize(&function, options...);

Options include:

    :NORMALIZER(&function)  # default: join with \x[1C] (aka chr(28)
    :CACHE<MEMORY>          # in memory, single threaded, default
    :CACHE<MULTI>           # in memory, multi-threaded, slower
    :CACHE(%cache_hash)     # any Associative object

PORTING CAVEATS
===============

Because pads / stashes are immutable at runtime and the way code can be wrapped in Perl 6, it is **not** possible to install a memoized version of a function **and** not wrap the original code. Therefore it seemed more sensible to remove the INSTALL feature altogether, at least at this point in time.

The CACHE\<MULTI> is a special version of CACHE\<MEMORY> that installs a thread-safe in memory storage, which is slower because of the required locking.

Since Perl 6 does not have the concept of `scalar` versus `list` context, only one type of cache is used internally, as opposed to two different ones as in Perl 5. Many functions / modules of the CPAN Butterfly Plan accept a `:scalar` parameter to indicate the scalar context version of the called function is requested. Since this is a parameter like any other, it will be used to distinguish scalar vs list meaning by the default normalizer.

Therefore there are no separate `:SCALAR_CACHE` and `:LIST_CACHE` named parameters necessary anymore: instead a single `:CACHE` parameter is recognized, that only accepts either `'MEMORY'`, `'MULTI'` or an object that does the `Associative` role as a parameter (as there is no need for the `'FAULT'` and `'MERGE'` values anymore).

Since Perl 6 has proper typing, it can recognize that an object that does the `Associative` role is being passed as the parameter with `:CACHE`, so there is no need to specify the word 'HASH' anymore.

The default in-memory backend for memoized values is **not** thread-safe. If you want multiple threads to work with the same memoized function, you will need to specify a CACHE parameter with a backend that **is** threadsafe.

DESCRIPTION
===========

`Memoizing` a function makes it faster by trading space for time. It does this by caching the return values of the function in a table. If you call the function again with the same arguments, `memoize` jumps in and gives you the value out of the table, instead of letting the function compute the value all over again.

Here is an extreme example. Consider the Fibonacci sequence, defined by the following function:

    # Compute Fibonacci numbers
    sub fib($n) {
        return $n if $n < 2;
        fib($n-1) + fib($n-2);
    }

This function is very slow. Why? To compute fib(14), it first wants to compute fib(13) and fib(12), and add the results. But to compute fib(13), it first has to compute fib(12) and fib(11), and then it comes back and computes fib(12) all over again even though the answer is the same. And both of the times that it wants to compute fib(12), it has to compute fib(11) from scratch, and then it has to do it again each time it wants to compute fib(13). This function does so much recomputing of old results that it takes a really long time to run---fib(14) makes 1,200 extra recursive calls to itself, to compute and recompute things that it already computed.

This function is a good candidate for memoization. If you memoize the 'fib' function above, it will compute fib(14) exactly once, the first time it needs to, and then save the result in a table. Then if you ask for fib(14) again, it gives you the result out of the table. While computing fib(14), instead of computing fib(12) twice, it does it once; the second time it needs the value it gets it from the table. It doesn't compute fib(11) four times; it computes it once, getting it from the table the next three times. Instead of making 1,200 recursive calls to 'fib', it makes 15. This makes the function about 150 times faster.

You could do the memoization yourself, by rewriting the function, like this:

    # Compute Fibonacci numbers, memoized version
    {
        my @fib;
        sub fib($n) {
            return $_ with @fib[$n];
            return @fib[$n] = $n if $n < 2;

            @fib[$n] = fib($n-1) + fib($n-2);
        }
    }

Or you could use this module, like this:

    use Memoize;
    memoize('fib');

    # Rest of the fib function just like the original version.

This makes it easy to turn memoizing on and off.

Here's an even simpler example: I wrote a simple ray tracer; the program would look in a certain direction, figure out what it was looking at, and then convert the `color` value (typically a string like `red`) of that object to a red, green, and blue pixel value, like this:

    for ^300 -> $direction {
        # Figure out which object is in direction $direction
        $color = $object{color};
        ($r, $g, $b) = ColorToRGB($color);
        ...
    }

Since there are relatively few objects in a picture, there are only a few colors, which get looked up over and over again. Memoizing `ColorToRGB` sped up the program by several percent.

DETAILS
=======

This module exports exactly one function, `memoize`. The rest of the functions in this package are None of Your Business.

You should say

    memoize(function)

where `function` is the name of the function or the `Routine` object that you want to memoize. `memoize` returns a reference to the new, memoized version of the function, or `Nil` on a non-fatal error. At present, there are no non-fatal errors, but there might be some in the future.

If `function` was the name of a function, then `memoize` hides the old version and installs the new memoized version under the old name, so that `&function(...)` actually invokes the memoized version.

OPTIONS
=======

There are some optional options you can pass to `memoize` to change the way it behaves a little. To supply options, invoke `memoize` like this:

    memoize(function,
      NORMALIZER => function,
      CACHE      => option,
    );

Each of these options is optional; you can include some, all, or none of them.

NORMALIZER
----------

Suppose your function looks like this:

    # Typical call: f('aha!', A => 11, B => 12);
    sub f($a, *%hash {
        %hash{B} ||= 2;  # B defaults to 2
        %hash{C} ||= 7;  # C defaults to 7

        # Do something with $a, %hash
    }

Now, the following calls to your function are all completely equivalent:

    f(OUCH);
    f(OUCH, B => 2);
    f(OUCH, C => 7);
    f(OUCH, B => 2, C => 7);
    f(OUCH, C => 7, B => 2);
    (etc.)

However, unless you tell `Memoize` that these calls are equivalent, it will not know that, and it will compute the values for these invocations of your function separately, and store them separately.

To prevent this, supply a `NORMALIZER` function that turns the program arguments into a string in a way that equivalent arguments turn into the same string. A `NORMALIZER` function for `f` above might look like this:

    sub normalize_f($a,*%hash {
        %hash{B} ||= 2;
        $hash{C} ||= 7;

        join(',', $a, %hash.sort>>.kv);
    }

Each of the argument lists above comes out of the `normalize_f` function looking exactly the same, like this:

    OUCH,B,2,C,7

You would tell `Memoize` to use this normalizer this way:

    memoize('f', NORMALIZER => 'normalize_f');

`memoize` knows that if the normalized version of the arguments is the same for two argument lists, then it can safely look up the value that it computed for one argument list and return it as the result of calling the function with the other argument list, even if the argument lists look different.

The default normalizer just concatenates the stringified arguments with character 28 in between. (In ASCII, this is called FS or control-\.) This always works correctly for functions with only one string argument, and also when the arguments never contain character 28. However, it can confuse certain argument lists:

    normalizer("a\034", "b")
    normalizer("a", "\034b")
    normalizer("a\034\034b")

for example.

Since hash keys are strings, the default normalizer will not distinguish between type objects / Nil and the empty string.

    sub normalize($a, @b) { join ' ', $a, @b }

For the example above, this produces the key "13 1 2 3 4 5 6 7".

Another use for normalizers is when the function depends on data other than those in its arguments. Suppose you have a function which returns a value which depends on the current hour of the day:

    sub on_duty($problem_type) {
        my $hour = DateTime.now.hour;
        my $fh = open("$DIR/$problem_type") or die...;
        $fh.lines.skip(DateTime.now.hour).head;
    }

At 10:23, this function generates the 10th line of a data file; at 3:45 PM it generates the 15th line instead. By default, `Memoize` will only see the $problem_type argument. To fix this, include the current hour in the normalizer:

    sub normalize(*@_) { join ' ', DateTime.now.hour, @_ }

CACHE
-----

Normally, `Memoize` caches your function's return values into an ordinary Perl hash variable. However, you might like to have the values cached on the disk, so that they persist from one run of your program to the next, or you might like to associate some other interesting semantics with the cached values.

The argument to `CACHE` must either the string `MEMORY`, the string `MULTI` or an object that performs the `Associative` role.

    MEMORY
    MULTI
    %hash

### MEMORY

`MEMORY` means that return values from the function will be cached in an ordinary Perl 6 hash. The hash will not persist after the program exits. This is the default.

### MULTI

`MULTI` means that return values from the function will be cached in a Perl 6 hash that has been hardened to function correctly in a multi-threaded program (which is slower due to necessary locking). The hash will not persist after the program exits.

### %hash

Allows you to specify that a particular hash that you supply will be used as the cache. Any object that does the `Associative` role is acceptable.

Such an `Associative` object can have any semantics at all. It is typically tied to an on-disk database, so that cached values are stored in the database and retrieved from it again when needed, and the disk file typically persists after your program has exited.

A typical example is:

    my %cache is MyStore[$filename];
    memoize 'function', CACHE => %cache;

Or if you want to use the "name of named parameter is the same as the variable" feature of Perl 6:

    my %CACHE is MyStore[$filename];
    memoize 'function', :%CACHE;

This has the effect of storing the cache in a `MyStore` database whose name is in `$filename`. The cache will persist after the program has exited. Next time the program runs, it will find the cache already populated from the previous run of the program. Or you can forcibly populate the cache by constructing a batch program that runs in the background and populates the cache file. Then when you come to run your real program the memoized function will be fast because all its results have been precomputed.

Another reason to use `HASH` is to provide your own hash variable. You can then inspect or modify the contents of the hash to gain finer control over the cache management.

OTHER FACILITIES
================

unmemoize
---------

There's an `unmemoize` function that you can import if you want to. Why would you want to? Here's an example: Suppose you have your cache tied to a DBM file, and you want to make sure that the cache is written out to disk if someone interrupts the program. If the program exits normally, this will happen anyway, but if someone types control-C or something then the program will terminate immediately without synchronizing the database. So what you can do instead is

    signal(SIGINT).tap: { unmemoize &function; exit }

`unmemoize` accepts the `Callable` object, or the name of a previously memoized function, and undoes whatever it did to provide the memoized version in the first place, including making the name refer to the unmemoized version if appropriate. It returns a reference to the unmemoized version of the function.

If you ask it to unmemoize a function that was never memoized, it will throw an exception.

flush_cache
-----------

`flush_cache(function)` will flush out the caches, discarding *all* the cached data. The argument may be a function name or a reference to a function. For finer control over when data is discarded or expired, see the documentation for `Memoize::Expire`, included in this package.

Note that if the cache is a tied hash, `flush_cache` will attempt to invoke the `CLEAR` method on the hash. If there is no `CLEAR` method, this will cause a run-time error.

An alternative approach to cache flushing is to use the `HASH` option (see above) to request that `Memoize` use a particular hash variable as its cache. Then you can examine or modify the hash at any time in any way you desire. You may flush the cache by using `%hash = ()`.

CAVEATS
=======

Memoization is not a cure-all:

depending on program state
--------------------------

Do not memoize a function whose behavior depends on program state other than its own arguments, such as global variables, the time of day, or file input. These functions will not produce correct results when memoized. For a particularly easy example:

    sub f {
      time;
    }

This function takes no arguments, and as far as `Memoize` is concerned, it always returns the same result. `Memoize` is wrong, of course, and the memoized version of this function will call `time` once to get the current time, and it will return that same time every time you call it after that.

side effects
------------

Do not memoize a function with side effects.

    sub f($a,$b) {

    my $s = $a + $b;
    say "$a + $b = $s.";

    }

This function accepts two arguments, adds them, and prints their sum. Its return value is the number of characters it printed, but you probably didn't care about that. But `Memoize` doesn't understand that. If you memoize this function, you will get the result you expect the first time you ask it to print the sum of 2 and 3, but subsequent calls will return 1 (the return value of `print`) without actually printing anything.

modified by caller
------------------

Do not memoize a function that returns a data structure that is modified by its caller.

Consider these functions: `getusers` returns a list of users somehow, and then `main` throws away the first user on the list and prints the rest:

    sub main {
        my @userlist = getusers();
        shift @userlist;
        for @userlist -> $u {
            print "User $u\n";
        }
    }

    sub getusers {
        my @users;
        # Do something to get a list of users;
        @users
    }

If you memoize `getusers` here, it will work right exactly once. The reference to the users list will be stored in the memo table. `main` will discard the first element from the referenced list. The next time you invoke `main`, `Memoize` will not call `getusers`; it will just return the same reference to the same list it got last time. But this time the list has already had its head removed; `main` will erroneously remove another element from it. The list will get shorter and shorter every time you call `main`.

Similarly, this:

    $u1 = getusers();
    $u2 = getusers();
    pop @$u1;

will modify $u2 as well as $u1, because both variables are references to the same array. Had `getusers` not been memoized, $u1 and $u2 would have referred to different arrays.

simple function
---------------

Do not memoize a very simple function.

Recently someone mentioned to me that the Memoize module made his program run slower instead of faster. It turned out that he was memoizing the following function:

    sub square($value) {
      $value * $value;
    }

I pointed out that `Memoize` uses a hash, and that looking up a number in the hash is necessarily going to take a lot longer than a single multiplication. There really is no way to speed up the `square` function.

Memoization is not magical.

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Memoize . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

