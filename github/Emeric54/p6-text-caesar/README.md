# Text::Caesar

## Synopsis

```Perl6
use Text::Caesar;

my $message = Message.new(
    key => 3,
    text => "I am a secret message"
);
my $secret = Secret.new(
    key => 3,
    text => $message.encrypt();
);
say $message.encrypt;
say $secret.decrypt;
```

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda install Text::Caesar
```
Or with Zef:
```
$ zef install Text::Caesar
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

You can also use objects :
```Perl6
my $message = Message.new(
    key => 3,
    text => "I am a secret message"
);
say $message.encrypt;
```
```Perl6
my $secret = Secret.new(
    key => 3,
    text => $message.encrypt();
);
say $secret.decrypt;
```

## Author

Emeric Fischer <fischer.emeric@gmail.com>, emeric on freenode.
