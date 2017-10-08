=NAME Sum::Digest::MD5 - a workalike to Digest::MD5 that uses Sum::

=begin SYNOPSIS
=begin code

# Assuming you have a recommendation manager that can find this file:
use Digest::MD5:auth<skids>;
# ...otherwise use Sum::Digest::MD5 instead

Digest.MD5.md5_hex("foo");         # acbd18db4cc2f85cedef654fccc4a4d8
Digest.MD5.md5_hex(["foo","bar"]); # 3858f62230ac3c915f300c664312c63f

=end code
=end SYNOPSIS

=begin DESCRIPTION

  This module provides a workalike to the Perl6 Digest::MD5 module.
  It tries to be bug-for-bug compatible with the respective version
  of that module.

  Since the Sum:: modules currently run rather slowly, this module is
  provided mainly as fodder for development efforts on S11 and S22,
  especially as a test case for "recommendation manager"s.

=end DESCRIPTION

=begin pod

=head2 class Digest::MD5

This class contains nothing but one multimethod:

=head3 md5_hex

  This method takes a C<Str> or an C<Array[Str]>.  The latter case is
  equivalant to joining the strings together into one string and using
  the former form.  An MD5 is computed across the ordinal values of the
  characters in the string, discarding all high bytes of wide characters.

=end pod

class Digest::MD5:auth<skids>:ver<0.05> {

  use Sum::MD;
  use Sum::Digest::Marshal;

  my class StrMD5 does Sum::MD5 does Sum::Digest::Marshal { }

  multi method md5_hex (Str $str) {
    StrMD5.new.finalize($str).Int.base(16).lc;
  }

  multi method md5_hex (@str) {
    StrMD5.new.finalize(@str).Int.base(16).lc;
  }

}

=AUTHOR Brian S. Julin

=begin COPYRIGHT
Copyright (c) 2012 Brian S. Julin. All rights reserved.
emulated module by Cosimo Streppone (cosimo@cpan.org)
=end COPYRIGHT

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::MD(pm3)> C<Digest::MD5> C<Sum::Digest::Marshal>
