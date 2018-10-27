NAME
====

Pod::TreeWalker

Walk a Pod tree and generate an event for each node.

SYNOPSIS
========



    my $to-html = Pod::To::HTML.new(...);
    Pod::TreeWalker.new( :listener($to-html) ).walk-pod($=pod);

DESCRIPTION
===========



This class provides an API for walking a pod tree (as provided by `$=pod`). Each node in the tree will trigger one or more events. These events cause methods to be called on a listener object that your provide. This lets you do something without a Pod document without having to know much about the underlying tree structure of Pod.

METHOD
======

Pod::TreeWalker.new( :listener( Pod::TreeWalker::Listener $object ) )

The constructor expects a single argument named `listener`. This object must implement the [Pod::TreeWalker::Listener](Pod::TreeWalker::Listener) API.

METHOD
======

$walker.walk-pod($pod)

This method walks through a pod tree starting with the top node in `$pod`. You can provide either an array of pod nodes (as stored in `$=pod`) or a single top-level node (such as `$=pod[0]`).

AUTHOR
======

Dave Rolsky <autarch@urth.org>

COPYRIGHT
=========



This software is copyright (c) 2015 by Dave Rolsky.

LICENSE
=======



This is free software; you can redistribute it and/or modify it under the terms of The Artistic License 2.0.
