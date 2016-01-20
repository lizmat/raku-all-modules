# AttrX::InitArg [![Build Status](https://travis-ci.org/LLFourn/p6-AttrX-InitArg.svg?branch=master)](https://travis-ci.org/LLFourn/p6-AttrX-InitArg)

Moose like `init_arg` for Perl 6

``` perl6
use AttrX::InitArg;

class SecretEnvoy {
    has $!message is init-arg is required;
    has $.steed is init-arg(False) = 'Shadowfax';
    has $.rider is init-arg('messenger') = 'Gandalf';

    method get-message($password){
        $password eq 'opensesame' ?? $!message !! Nil;
    }

}

my $msg = SecretEnvoy.new(
    message => 'TOP SECRET',
    messenger => 'BatMan',
    steed => 'Bat-Mobile' # this one won't work
);

say so $msg.can('message'); #-> False
say $msg.get-message('opensesame'); #-> TOP SECRET
say $msg.steed #-> Shadowfax;
say $msg.rider #-> Batman;

```

## Description

Perl 6 is presently quite opinionated about the
concepts of *public* and *private* attributes. It doesn't allow for:

1. Attributes that can be set by `.bless` but do not have accessors
2. Attributes that cannot be set by `.bless` but do have accessors

Perl 6 OO is flexible enough to create attributes that behave in the
above way, it just involves a lot of boilerplate. This module takes
care of that in the same way as Perl 5's
[Moose](https://metacpan.org/pod/Moose). Moose has an attribute trait
called
[init_arg](https://metacpan.org/pod/distribution/Moose/lib/Moose/Manual/Attributes.pod#Constructor-parameters-init_arg)
which this module attempts to emulate.

There are three ways of using init arg.

### With no argument

``` perl6
class Foo {
    has $!attr is init-arg;
    method works { say $!attr }
}
Foo.new( attr => 'win' ).works #-> win
```

This is intended to be used with `$!` attributes. The attribute will
be set by `.bless` as if it were a `$.` attribute but won't have
accessors set up for it as usual.

### With a string argument

``` perl6
class Foo {
    has $.attr is init-arg('other-name');
}
say Foo.new(other-name => "bar").attr #-> bar
say Foo.new(attr => "bar").attr #-> (Any)
```

Sets the attribute's argument name in `.bless` for both `$!` and `$.`
attributes.  name. `$.` attributes will no longer be set with their
usual name in `.bless`, but it won't `die` if you try.

### With a `False` argument

```perl6
class Foo {
    has $.attr is init-arg(False) = "foo";
}

say Foo.new(attr => "bar").attr #-> foo
```

For use with `$.` attributes only. Does not allow the attribute to be
set by `.bless`. It will ignore you if you try. Usually used when you
want an attribute with accessors but always want the attribute to
start as its default value.

## Usage Notes

### roles

~~doesn't work in roles yet. Sorry!~~
It works inside roles too!

### .gist and .perl

This module modfiies .gist and .perl (in a fairly ugly way) so that
`.perl`'s EVALablilty is preserved. However, `.gist` is modified so
that it never prints out the values of `$!` attributes.

### Is this even a good idea?

It depends. If you are using the no-argument form of `init-arg` with `$!`
attributes, make sure you have considered just using `$.`. Is public
read-only not good enough? Does it **have** to have no accessors?

### BUILDALL

~~This trait creates a custom BUILDALL on the role/class containing
the trait. If you write your own one this won't work atm.~~ This
Should be fine now. You can write your own BUILD or BUILDALL and it
won't conflict.
