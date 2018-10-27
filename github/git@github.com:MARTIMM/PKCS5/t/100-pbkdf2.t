#!/usr/bin/env perl6

use v6.c;
use Test;

use PKCS5::PBKDF2;
use OpenSSL::Digest;

#-------------------------------------------------------------------------------
# Test vectors from https://tools.ietf.org/html/rfc6070
subtest {
  my PKCS5::PBKDF2 $p .= new;
  isa-ok $p, PKCS5::PBKDF2;

  my Str $spw = $p.derive-hex(
    Buf.new('password'.encode),
    Buf.new('salt'.encode),
    1,
  );

  is $spw, '0c60c80f961f0e71f3a9b524af6012062fe037a6', "Test 'password' and 1 iteration";

  $spw = $p.derive-hex(
    Buf.new('password'.encode),
    Buf.new('salt'.encode),
    2,
  );

  is $spw, 'ea6c014dc72d6f8ccd1ed92ace1d41f0d8de8957', "Test 'password' and 2 iterations";

  $spw = $p.derive-hex(
    Buf.new('password'.encode),
    Buf.new('salt'.encode),
    4096,
  );

  is $spw, '4b007901b765489abead49d926f721d065a429c1', "Test 'password' and 4096 iterations";

  # Only test once. Takes too much time
  if 0 {
    $spw = $p.derive-hex(
      Buf.new('password'.encode),
      Buf.new('salt'.encode),
      16777216,
    );

    is $spw, 'eefe3d61cd4da4e4e9945b3d6ba2158c2634e984', "Test 'password' and 16777216 iterations";
  }
  else {
    diag "Test with 16777216 iterations is skipped due to the time it needs";
  }

  $p .= new(:dklen(25));
  $spw = $p.derive-hex(
    Buf.new('passwordPASSWORDpassword'.encode),
    Buf.new('saltSALTsaltSALTsaltSALTsaltSALTsalt'.encode),
    4096,
  );

  is $spw, '3d2eec4fe41c849b80c8d83662c0e44a8b291a964cf2f07038', "Test with dklen = 25 and 4096 iterations";

  $p .= new(:dklen(16));
  $spw = $p.derive-hex(
    Buf.new("pass\0word".encode),
    Buf.new("sa\0lt".encode),
    4096,
  );

  is $spw, '56fa6aa75548099dcc37d7f03425e0c3', "Test with dklen = 16 and 4096 iterations";

}, 'Tests from rfc6070';

#-------------------------------------------------------------------------------
# Tests using external programs and modules
subtest {
  my PKCS5::PBKDF2 $p .= new(:CGH(&md5));

  my Str $spw = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    1,
  );

  is $spw, '12edf6c31d1b70cf001b8007de508ba4', '1 iteration hex md5';

  $spw = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    4096,
  );

  is $spw, '58c208a6087ea3f1671bb86da22045b8', '4096 iteration hex md5';

}, 'md5 prf';

#-------------------------------------------------------------------------------
subtest {
  my PKCS5::PBKDF2 $p .= new(:CGH(&sha256));

  my Str $spw = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    4096,
  );

  is $spw,
     'a97517ae572f9dac71586d340dd460562a11da09d4a6e5f9afedc4675add8556',
     '4096 iteration hex sha256';

}, 'sha256 prf';

#-------------------------------------------------------------------------------
subtest {
  my PKCS5::PBKDF2 $p .= new;

  my Buf $spw1 = $p.derive(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    1,
  );

  is $spw1.>>.fmt('%02x').join,
     'f305212412b600a373561fc27b941c350ba9d399',
     '1 iteration buf';

  my Str $spw2 = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    1,
  );

  is $spw2, 'f305212412b600a373561fc27b941c350ba9d399', '1 iteration hex';

  $spw2 = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    4096,
  );

  is $spw2, '1d96ee3a529b5a5f9e47c01f229a2cb8a6e15f7d', '4096 iteration hex';

}, 'sha1 prf';

#-------------------------------------------------------------------------------
subtest {
  my PKCS5::PBKDF2 $p .= new(:dklen(30));

  my Str $spw2 = $p.derive-hex(
    Buf.new('pencil'.encode),
    Buf.new( 65, 37, 194, 71, 228, 58, 177, 233, 60, 109, 255, 118),
    4096,
  );

  is $spw2,
     '1d96ee3a529b5a5f9e47c01f229a2cb8a6e15f7dd4329078905280f7e1a3',
     '4096 iteration hex with dklen=30';

}, 'sha1 prf with different dklen';

#-------------------------------------------------------------------------------
done-testing;
