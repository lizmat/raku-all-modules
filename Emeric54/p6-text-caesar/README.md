# Text::Caesar

## Synopsis

```Perl6
use v6;

use Text::Caesar;

my Str $secret = "I'm a secret message.";
my Str $message = encrypt(3, $secret);
say $message;
```

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda install Text::Caesar
```

## Description

This module allows you to use 4 functions.

You can encrypt a message :
```Perl6
use v6;

use Text::Caesar;

my Str $secret = "I'm a secret message.";
my Str $message = encrypt(3, $secret);
say $message;
```
You can decrypt a message :
```Perl6
my Str $secret = 'LPDVHFUHWPHVVDJH'
my Str $message = decrypt(3, $secret);
say $message;
```
You can encrypt (or decrypt) a file :
```Perl6
encrypt-from-file($key, $origin, $destination)
```
This code will encrypt `$origin`'s text into the `$destination` file.

## Author

Emeric Fischer <fischer.emeric@gmail.com>
