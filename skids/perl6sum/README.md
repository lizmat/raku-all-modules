perl6sum
========

Sum:: Perl 6 modules implementing checksums, hashes, etc.

## Status

Very broken at the moment, to the point where API may have to
change.  Changes made right before the 6.c release
have left an important API decision up in the air -- that being
whether a feed tap has .push or .append called on it.  The
API of Sum depends on this -- the only reaon it was using .push
was to match this feed API.  If .append is to continue to be
called, Sum will change API to suit.  Unfortunately it does
not look to be the case that this will be resolved anytime soon.

## Purpose

This suite of modules intends to become a thorough, idiomatic Perl 6
interface to checksum and digest algorithms, for both academic use
and for production applications.  It supports both efficient
external libraries, and pure Perl 6 implementations of algorithms.

Currently, for production use, it is recommended only to use
the modules with external libraries implementing desired algorithms.
At this time, the libraries supported are libcrypto, librhash,
and libmhash.  These libraries are not strictly dependencies,
as runtime fallback code will use pure Perl 6 implementations when the
libraries are not present.  So, projects using these modules
in production should take care to add dependencies appropriate
to the use case.  The default behavior will always be to use
the fastest available option and fall back in the order of
decreasing performance, to the extent that there has been time to
compare the options.

The pure Perl 6 implementations are currently, intentionally,
not optimized.  Some implementations are written in a way that
makes them easy to audit from the formal specification of the
algorithm.  Others have been written to intentionally use,
and sometimes over-use, certain features of Perl 6 or certain
programming styles.  They are kept this way as fodder for
optimization work on the Perl 6 core, until such a time as
having fast pure Perl 6 implementations is both possible and
needed by someone.

For example, the MD5 implementation currently runs 10 times
slower than the more basic, less fully featured, implementation
in the official ecosystem's "Digest::MD5" perl5-workalike module,
even though that module itself has probably not been very extensively
tweaked to avoid rakudo's current slow paths.

The pure Perl 6 implementations also try to implement features
useful for academic/cryptanalysis purposes, by supporting messages
that do not pack into bits, supporting variations of algorithms
that are obselete or have never seen real-world applications,
and supporting tuning of internal parameters or easy modification
of the code through subclassing.

## Idioms

A few useful idioms should be pointed out.  The first is that,
although prefabricated classes will eventually be provided, all
the functionality is available in role form, and as such may
be mixed into classes that might want to provide automatic
checksums:

```perl6
class myStream does Sum::SHA1 does Sum::Marshal::Raw {
    ...
    method rx {
        my $received_data;
        ...
        self.push($received_data);
    }
}
```

Another is that the objects may be used as a "tap" on a feed,
creating a checksum of all the values passed through that
feed without interfering with the feed result:

```perl6
@pbytes <== $mySHA1 <== $myMD5 <== generate_packet();
...
$packet = blob8.new[@pbytes,
                    $mySHA1.finalize.Buf.values,
                    net_endian(+@pbytes)]
```

## 5to6

There are a few key differences between the way one uses
objects from Sum:: versus the Perl 5 Digest:: interface.

1.  Use .push, not ->add to add elements to the Sum.
    There is an .add method but its exact behavior changes
    with the algorithm and the backend.  Only use .add
    directly when optimizing for site-specific use cases.

2.  Use .finalize, not ->digest.  This change makes it clearer
    that the calculation is complete and (in most algorithms)
    more addends cannot be pushed to the digest.  This also
    brings Perl 6 in line with the prevalent vernacular.

3.  While it is possible (and easy) to build a Sum class that will
    take strings as arguments to .push, it is more advisable
    to keep decisions about encoding visible at the point
    of use.  Consider this behavior of Perl 5 Digest:: when
    you encounter characters with ordinal values between
    129 and 255:

```perl
    use Digest::SHA sha1_base64;
    use Encode qw(encode_utf8);
    say sha1_base64(encode_utf8('here is a french brace »'));
    # S+YAQNtj1tluLgYewYgoWvdrSgQ
    say sha1_base64(            'here is a french brace »')";
    # 5hoNlI0QihTToOzKPc8pdMwEhWM
```

    However, in Perl 5 you MUST use encode_utf8 if you handle any
    characters with ordinals above 255.  There is too much opportunity
    for mixed encoding problems to happen when parts of a message are
    pushed at different locations in the code.

    By not accepting plain strings, users must consciously
    choose an encoding and that helps them avoid accidentally mixing
    encodings.

    Fortunately, encoding is a built-in capability of Perl 6:

```perl6
    $sha.push('here is a french brace »'.encode('utf8'));
```

4.  Note that the return value of .finalize is the finalized
    Sum object.  This can be coerced to common types you might
    want and formatted by using many built-in Perl 6
    methods.  Also, .finalize takes arguments, which are just
    passed to .push.  Together this gives the following idiom
    for one-shot purposes:

```perl6
    say mysha.new.finalize($buffer).Int.fmt("%20x");
```

    There are some shortcuts built in, which also have the
    benefit of including leading zeros.

```perl6
    say mysha.new.finalize($buffer).fmt(); # lowercase hex (e.g. sha1_hex)
    say mysha.new.finalize($buffer).fmt("%2.2x",":"); # colon octets
    say mysha.new.finalize($buffer).base(16); # uppercase hex
    say mysha.new.finalize($buffer).base(2);  # binary text
```

    Base32 and Base64 is not yet implemented pending a review of
    which variations of these encodings are used in modern applications.

5.  There is no ->reset method, and .new does not re-use
    the Perl 6 object when called on an instance, it just
    creates a new Perl 6 object.  Sum objects are meant
    to be thrown away after use.  Replacing them is easy:

```perl6
    # assuming $md has a Sum in it, or was constrained when defined.
    $md .= new;
```

    If you are concerned about tying up crypto resources, the
    only thing to worry about is to ensure you finalize the object
    before discarding it.  The backends should be smart enough to
    free up resources promptly upon finalization.

6.  Just about everything in perl 6 has a .clone method,
    including Sum objects.  However, not all back-ends
    can clone their instances.  Using a class that does
    Sum::Partial is one way to guarantee that only backends
    that support cloning contexts are used.
