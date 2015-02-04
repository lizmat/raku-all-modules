use Test;

plan 6;

use Digest::HMAC;
use Digest;
use Digest::SHA;

# tests taken from wikipedia

is hmac-hex("", "", &md5),
   '74e6f7298a9c2d168935f58c001bad88', "Empty md5 HMAC";
is hmac-hex("", "", &sha1),
   'fbdb1d1b18aa6c08324b7d64b71fb76370690e1d', "Empty SHA1 HMAC";
is hmac-hex("", "", &sha256),
   'b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad', "Empty SHA256 HMAC";

is hmac-hex("key", "The quick brown fox jumps over the lazy dog", &md5),
   '80070713463e7749b90c2dc24911e275', "md5 HMAC";
is hmac-hex("key", "The quick brown fox jumps over the lazy dog", &sha1),
   'de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9', "SHA1 HMAC";
is hmac-hex("key", "The quick brown fox jumps over the lazy dog", &sha256),
   'f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8', "SHA256 HMAC";
