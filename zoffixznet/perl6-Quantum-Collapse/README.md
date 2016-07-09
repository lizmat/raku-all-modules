[![Build Status](https://travis-ci.org/zoffixznet/perl6-Quantum-Collapse.svg)](https://travis-ci.org/zoffixznet/perl6-Quantum-Collapse)

# NAME

Quantum::Collapse - Collapse allomophic types into their components

# SYNOPSIS

```perl6
    use Quantum::Collapse;

    say  2  ∈     <2 a>; # False
    say '2' ∈     <2 a>; # False
    say  2  ∈ n<- <2 a>; # True
    say  2  ∈ s<- <2 a>; # False
    say '2' ∈ s<- <2 a>; # True

    say (2, 3) eqv     <2 3>; # False
    say (2, 3) eqv n<- <2 3>; # True
```

# DESCRIPTION

Allomorphics are things like `IntStr` and kin that can behave like either
`Int` or `Str` and you get them from things like `sub MAIN` or quote words
(`< ... >`).

They're great until they aren't. When using sets or `eqv` or `===`,
allomorphics do not match their components. This is where Quantum::Collapse
comes in and collapses allomorphics into one specific constituent.

# EXPORTED OPERATORS

# `n<-`

```perl6
    say  2  ∈ n<- <2 a>; # True
```

Collapses allomorphics into their **numerical** parts
(e.g. `IntStr` becomes `Int`). Prefix operator with
same precedence as prefix `|`

# `s<-`

```perl6
    say  '2'  ∈ s<- <2 a>; # True
```

Collapses allomorphics into their **stringy** parts
(e.g. `IntStr` becomes `Str`). Prefix operator with
same precedence as prefix `|`

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Quantum-Collapse

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Quantum-Collapse/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
