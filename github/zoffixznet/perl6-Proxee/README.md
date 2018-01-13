[![Build Status](https://travis-ci.org/zoffixznet/perl6-Proxee.svg)](https://travis-ci.org/zoffixznet/perl6-Proxee)

# NAME

`Proxee` — A more usable [`Proxy`](https://docs.perl6.org/type/Proxy) with bells

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [METHODS](#methods)
    - [`new`](#new)
        - [A Coercer](#a-coercer)
        - [An Improved Proxy](#an-improved-proxy)
        - [A Callable](#a-callable)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# SYNOPSIS

```perl-6
    use Proxee;
```

Coercers:

```perl-6
    # Coercer types on variables:
    my $integral := Proxee.new: Int();
    $integral = ' 42.1e0 ';
    say $integral; # OUTPUT: «42␤»

    # Coercer types on attributes:
    class Foo {
        has $.foo is rw;
        submethod TWEAK (:$foo) { ($!foo := Proxee.new: Int()) = $foo }
    }
    my $o = Foo.new: :foo('42.1e0');
    say $o.foo;       # OUTPUT: «42␤»
    $o.foo = 12.42;
    say $o.foo;       # OUTPUT: «12␤»
```

General use:

```perl-6
    # No `self` as first arg; simply use a regular block in both code blocks:
    my @stuff;
    my $stuff := Proxee.new: :STORE{ @stuff.push: $_ }, :FETCH{ @stuff.join: ' | ' }
    $stuff = 42;
    $stuff = 'meow';
    say $stuff; # OUTPUT: «42 | meow␤»

    # Single block as arg; keep all related bits in one place
    my $stuff2 := Proxee.new: {
        my @stuff;
        :STORE{ @stuff.push: $_    },
        :FETCH{ @stuff.join: ' | ' }
    }
    $stuff2 = 42;
    $stuff2 = 'meow';
    say $stuff2; # OUTPUT: «42 | meow␤»
```

Special shared dynvar:

```perl-6
    # Or just use the special shared variable:
    my $stuff2 := Proxee.new: :STORE{ $*PROXEE.push: $_ }, :FETCH{ $*PROXEE.join: ' | ' }
    $stuff2 = 42;
    $stuff2 = 'meow';
    say $stuff2; # OUTPUT: «42 | meow␤»

    # Default STORErer
    my $cuber := Proxee.new: :FETCH{ $*PROXEE³ };
    $cuber = 11;
    say $cuber; # OUTPUT: «1331␤»

    # Default FETCHer
    my $squarer := Proxee.new: :STORE{ $*PROXEE = $_² };
    $squarer = 11;
    say $squarer; # OUTPUT: «121␤»

    # Shortcut to assign to $*PROXEE
    my $squarer := Proxee.new: :PROXEE{ $_² };
    $squarer = 11;
    say $squarer; # OUTPUT: «121␤»
```

# DESCRIPTION

The core [`Proxy`](https://docs.perl6.org/type/Proxy) type is a bit clunky to use. This module
provides an alternative, improved interface, with a few extra features.

# METHODS

## `new`

```perl-6
multi method new (\coercer where {.HOW ~~ Metamodel::CoercionHOW})
multi method new (:&PROXEE, :&STORE, :&FETCH)
multi method new (&block)
```

Creates and returns a new [`Proxy`](https://docs.perl6.org/type/Proxy) object
whose `:STORE` and `:FETCH` `Callable`s have been set to behave like
functionality offered by `Proxee`. Possible arguments are:

### A Coercer

Simply pass a coercer as a positional argument to create a coercing proxy that
coerces stored values to specified type:

```perl-6
my  $Cool-to-Int := Proxee.new: Int(Cool);
    $Cool-to-Int = ' 42.70 ';
say $Cool-to-Int; # OUTPUT: «42␤»
    $Cool-to-Int = Date.today
    # OUTPUT: «Type check failed in Proxee; expected Cool but got Date (Date)␤»
```

**Note:** none of `:&PROXEE`, `:&STORE`, `:&FETCH` can be used together
with the coercer argument.

### An Improved Proxy

The regular functionality of a [`Proxy`](https://docs.perl6.org/type/Proxy)
remains, except the `Proxy` object is no longer passed to neither `:FETCH`
nor `:STORE` callables. `:FETCH` gets no args; `:STORE` gets 1 arg, the value
being stored:

```perl-6
    my @stuff;
    my $stuff := Proxee.new: :STORE{ @stuff.push: $_ }, :FETCH{ @stuff.join: ' | ' }
    $stuff = 42;
    $stuff = 'meow';
    say $stuff; # OUTPUT: «42 | meow␤»
```

In addition, automated storage is available. Simply **assign** (do not bind, or
you'll break it) to `$*PROXEE` variable to store the value in the automated
storage and read from it to retrieve that value:

```
    my $stuff2 := Proxee.new: :STORE{ $*PROXEE.push: $_ }, :FETCH{ $*PROXEE.join: ' | ' }
    $stuff2 = 42;
    $stuff2 = 'meow';
    say $stuff2; # OUTPUT: «42 | meow␤»
```

The `:STORE` argument is optional and **defaults to** `{ $*PROXEE = $_ }`.
The `:FETCH` argument is optional and **defaults to** `{ $*PROXEE }`.
The `:PROXEE` argument is like `:STORE`, except it also assigns its return
value to `$*PROXEE`:

```perl-6
    my $squarer := Proxee.new: :PROXEE{ $_² };
    $squarer = 11;
    say $squarer; # OUTPUT: «121␤»
```

Attempting to use both `:PROXEE` and `:STORE` arguments at the same time
will throw `Proxee::X::CannotProxeeStore` exception.

### A Callable

You can also pass a single codeblock as an argument. It will be evaluated
and its return value will be used as arguments to `Proxee.new` (after slight
massaging to make `Pair`s in a `List` be passed as named args).

This feature exists to make it slightly simpler to use closures with a Proxy:

```perl-6
    my $stuff2 := Proxee.new: {
        my @stuff;
        :STORE{ @stuff.push: $_    },
        :FETCH{ @stuff.join: ' | ' }
    }
    $stuff2 = 42;
    $stuff2 = 'meow';
    say $stuff2; # OUTPUT: «42 | meow␤»
```

The above is equivalent to:

```perl-6
    my $stuff2 := do {
        my @stuff;
        Proxee.new: :STORE{ @stuff.push: $_    },
                    :FETCH{ @stuff.join: ' | ' }
    }
    $stuff2 = 42;
    $stuff2 = 'meow';
    say $stuff2; # OUTPUT: «42 | meow␤»
```

Watch out you don't accidentally pass a block that would be interpreted
as a `Hash`:

```perl-6
    Proxy.new:    { :STORE{;}, :FETCH{;} } # WRONG; It's a Hash
    Proxy.new: -> { :STORE{;}, :FETCH{;} } # RIGHT; It's a Block
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Proxee

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Proxee/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

Syntax highlighting CSS code is based on GitHub Light v0.4.1,
Copyright (c) 2012 - 2017 GitHub, Inc. Licensed under MIT
https://github.com/primer/github-syntax-theme-generator/blob/master/LICENSE

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
