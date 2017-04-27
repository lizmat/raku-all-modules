# Crypt::Bcrypt #
[![Build Status](https://travis-ci.org/skinkade/p6-Crypt-Bcrypt.svg?branch=master)](https://travis-ci.org/skinkade/p6-Crypt-Bcrypt)

Easy `bcrypt` password hashing in Perl6.



## Synopsis ##
Password hashing and verification are one function each, and utilize a
crypt()-style output string:
```
> use Crypt::Bcrypt;

> my $hash = bcrypt-hash("password")
$2b$12$EFUDTFQAf/6YwmnN/FKyX.kH0BsE/YNExuIQcI1WZXO/rwkmD8G2S

> bcrypt-match("password", $hash)
True

> bcrypt-match("wrong", $hash)
False

> bcrypt-hash("password", :rounds(15))
$2b$15$BcxIqbIcb1bDt3SHkEjO/ePcdeNV8f2xeFSQTyoiidYGUA03lptrm
```



## Credit ##

This module uses the Openwall crypt\_blowfish library by Solar Designer. See http://www.openwall.com/crypt/ and the header of
[crypt\_blowfish.c](ext/crypt_blowfish-1.3/crypt_blowfish.c) for details.

## License ##

The Openwall library is licensed and redistributed under the terms outlined in the header of [crypt\_blowfish.c](ext/crypt_blowfish-1.3/crypt_blowfish.c). Any modifications are released under the same terms.

This module is released under the terms of the ISC License.
See the [LICENSE](LICENSE) file for details.
