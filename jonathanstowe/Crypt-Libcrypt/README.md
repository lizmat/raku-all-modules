# Crypt::Libcrypt

Provide a simple Perl 6 binding to POSIX crypt(3) function

## Description

This is a binding to the crypt() function that is typically defined in
libcrypt on most Unix-like systems or those providing a POSIX API.

There is a single exported subroutine crypt() that perform a one-way
encryption of the supplied plain text, with the provided "salt".  Depending
on the implementation on your system, the structure of the salt may influence
the algorithm that is used to perform the encryption.  The default will
probably be the DES algorithm that was traditionally used to encrypt 
passwords on a Unix system.

Because this is intended primarily for the encryption of passwords and is
"one way" (i.e. there is no mechanism to "decrypt" the crypt text,) it is
not suitable for general purpose encryption. 

In order to check whether a password entered by a user is correct it should
be encrypted using the stored encrypted password as the "salt" - the result
will be the same as the stored crypt text if the password is the same.

## Installation

Currently there is no dedicated test to determine whether your platform is
supported, the unit tests may simply fail horribly.

Assuming you have a working perl6 installation you should be able to
install this with *ufo* :

    ufo
    make test
    make install

*ufo* can be installed with *panda* for rakudo:

    panda install ufo

Or you can install directly with "panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install Crypt::Libcrypt

Other install mechanisms may be become available in the future.

## Support

This should be considered experimental software until such time that
Perl 6 reaches an official release.  However suggestions/patches are
welcomed via github at

   https://github.com/jonathanstowe/Crypt-Libcrypt

I'm not able to test on a wide variety of platforms so any help there would be 
appreciated. Also help with the documentation of which platforms support
which encryption algorithms is probably required.

## Licence

Please see the LICENCE file in the distribution

(C) Jonathan Stowe 2015
