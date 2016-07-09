# Shorten and obfuscate IDs

[![Build Status](https://travis-ci.org/bbkr/TinyID.svg?branch=master)](https://travis-ci.org/bbkr/TinyID)

## SYNOPSIS

```perl
    use TinyID;
    
    my $key = ( 'a'..'z', 'A'..'Z', 0..9 ).flat.pick( * ).join;
    # example key is '2BjLhRduC6Tb8Q5cEk9oxnFaWUDpOlGAgwYzNre7tI4yqPvXm0KSV1fJs3ZiHM'
    
    my $tinyid = TinyID.new( key => $key );
    
    say $tinyid.encode( 48888851145 );  # will print '1FN7Ab'
    say $tinyid.decode( '1FN7Ab' );     # will print 48888851145
```

## DESCRIPTION

Using real IDs in various places - such as GET links or API payload - is generally a bad idea:

* It may reveal some sensitive informations about your business, such as growth rate or amount of customers.
* If someone finds unprotected resource link, where you forgot to check if passed resource ID really belongs to currently logged-in user, he will be able to steal all of your data really fast just by incrementing ID in links.
* Big numbers may cause overflows in places where length is limited, such as SMS messages.

With the help of this module you can shorten and obfuscate your IDs at the same time.

## METHODS

### new( key => 'qwerty' )

Key must consist of at least two ***unique*** unicode characters.

The longer the key - the shorter encoded ID.

Encoded ID will be made exclusively out of characters from the key.
This very useful property allows to adapt your encoding to the environment.
For example in SMS messages you may restrict key to US ASCII to avoid available length reduction caused by conversion to GSM 03.38 charset.
Or if you want to use such ID as file/directory name in case insensitive filesystem you may want to use only lowercase letters in the key.

### encode( 123 )

Encode positive integer into a string.

Note that leading `0`s are not preserved, `encode( 123 )` is the same as `encode( 00123 )`.

Used algorithm is a base to the length of the key conversion that maps to distinct permutation of characters.
Do not consider it a strong encryption, but if you have secret and long and well shuffled key it is almost impossible to reverse-engineer real ID.

### decode( 'rer' )

Decode string back into a positive integer.

## TRICKS

If you provide sequential characters in key you can convert your numbers to some weird numeric systems, for example base18:

```perl
    TinyID.new( key => '0123456789ABCDEFGH' ).encode( 48888851145 ).say;    # '47F709HFF'
```

Or you can go wild just for the fun of it.

```perl
    my $key = ( '😀'..'😿' ).flat.join; # emoji subset
    TinyID.new( key => $key ).encode( 48888851145 ).say;    # '😭😢😀😊😫😉'
```

If you want to use such IDs in a communication between Perl 5 and Perl 6
[compatible module is also available](http://search.cpan.org/~bbkr/Integer-Tiny-0.3/lib/Integer/Tiny.pm).

## LICENSE

Released under [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

## CONTACT

You can find me (and many awesome people who helped me to develop this module)
on irc.freenode.net #perl6 channel as **bbkr**.
