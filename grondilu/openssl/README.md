Perl6 interface to OpenSSL.  So far only digests (SSL::Digest).

Digests supported include md2, md4, md5, sha0, sha1, sha2 variants (as sha224,
sha256, sha384, sha512), whirlpool, and ripemd160 (as rmd160). These are all
exported by default.
- Whirlpool support was added to openssl in 1.0.0, released in 2010. If your
  openssl lacks this support, two tests will fail.
- Note that many of these digests are considered completely insecure (md2, md4,
  md5, sha0).
