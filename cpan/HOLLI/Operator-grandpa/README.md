[![Build Status](https://travis-ci.org/holli-holzer/Operator-grandpa.svg?branch=master)](https://travis-ci.org/holli-holzer/Operator-grandpa)

NAME
====

Operator::grandpa - An object recursion operator

VERSION
=======

0.01

SYNOPSIS
========

    class Node {
      has $.name;
      has $.parent;
    }

    my $child = Node.new(
      :name("out"),
      :parent( Node.new(
        :name("mid"),
        :parent( Node.new(
          :name("inner"),
          :parent( Node.new( :name("root") ) )
        ))
      ))
    );

    my $root1 = $child :| { .parent }
    my $root2 = $child 𝄇 -> $node { $node.parent }

DESCRIPTION
===========

    multi sub prefix:<:|>(Any --> Callable:D)
    multi sub prefix:<𝄇>(Any --> Callable:D)

The grandpa / object recursion operator *:|* and it's unicode counterpart *𝄇* (U+1D107) invoke the callable on the RHS recursively.

The callable gets initially invoked with the LHS as the argument, and then recursively invoked with its' respective previous return value as the argument.

It does that until the code block evaluates to `Any`, then returns the last good value.

Note, that if you assign to `$_` within the code block, this also changes the LHS of the operator. So, don't do that, unless it's what you want.

    multi sub prefix:<|:>(Any --> Callable:D)
    multi sub prefix:<𝄆>(Any --> Callable:D)

Alternatively you can use this version of the operator, which does the same as above but operates on a copy of the LHS, thus allowing assigning to `$_` safely.

AUTHOR
======

    holli.holzer@gmail.com

COPYRIGHT AND LICENSE
=====================

Copyright © holli.holzer@gmail.com

License: Artistic-2.0

This is free software: you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law.
