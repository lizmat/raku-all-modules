perl6sum
========

Sum:: Perl 6 modules implementing checksums, hashes, etc.

## 5to6

There are a few key differences between the way one uses
objects from Sum:: versus the Perl 5 Digest:: interface.

1) Use .push, not ->add to add elements to the Sum.
   There is an .add method but its exact behavior changes
   with the algorithm and the backend.  Only use .add
   directly when optimizing for site-specific use cases.

2) Use .finalize, not ->digest.  This change makes it clearer
   that the calculation is complete and (in most algorithms)
   more addends cannot be pushed to the digest.  This also
   brings Perl 6 in line with the prevalent vernacular.

3) While it is possible to build a Sum class that will
   take strings as arguments to .push, it is more advisable
   to keep decisions about encoding visible at the point
   of use.  Consider this behavior of Perl 5 Digest:: when
   you encounter characters with ordinal values between
   129 and 255:

      use Digest::SHA sha1_base64;
      use Encode qw(encode_utf8);
      say sha1_base64(encode_utf8('here is a french brace »'));
      # S+YAQNtj1tluLgYewYgoWvdrSgQ
      say sha1_base64(            'here is a french brace »')";
      # 5hoNlI0QihTToOzKPc8pdMwEhWM

   However, you MUST use encode_utf8 if you handle any characters
   with ordinals above 255.  There is too much opportunity for
   problems where parts of a message are pushed at different
   locations in the code.

   By not accepting plain strings, users must consciously
   choose an encoding and helps them avoid accidentally mixing
   encodings.

   Fortunately, encoding is a built-in capability of Perl 6:

      $sha.push('here is a french brace »'.encode('utf8'));

4) Note that the return value of .finalize is the finalized
   Sum object.  This can be coerced to common types you might
   want using and formatted using many built-in Perl 6
   methods.  Also, .finalize takes arguments, which are just
   passed to .push.  Together this gives the following idiom
   for one-shot purposes:

       say mysha.new.finalize($buffer).Int.fmt("%20x");

   There are some shortcuts built in, which also have the
   benefit of including leading zeros.

       say mysha.new.finalize($buffer).fmt(); # lowercase hex (e.g. sha1_hex)
       say mysha.new.finalize($buffer).fmt("%2.2x",":"); # colon octets
       say mysha.new.finalize($buffer).base(16); # uppercase hex
       say mysha.new.finalize($buffer).base(2);  # binary text

5) There is no ->reset method, and .new does not re-use
   the Perl 6 object when called on an instance, it just
   creates a new Perl 6 object.  Sum objects are meant
   to be thrown away after use.  Replacing them is easy:

      # assuming $md has a Sum in it, or was constrained when defined.
      $md .= new;

6) There is .clone in Perl 6 on just about everything,
   including Sum objects.  However, not all back-ends
   can clone their instances.  Using a class that does
   Sum::Partial is one way to guarantee that only backends
   that support cloning contexts are used.
