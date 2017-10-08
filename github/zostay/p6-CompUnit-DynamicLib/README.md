NAME
====

CompUnit::DynamicLoader - load modules from temporarily included locations

SYNOPSIS
========

    use CompUnit::DynamicLib;

    my @includes = <plugin/lib module/lib other/lib>;

    require-from(@includes, "MyPlugin::Module");

    use-lib-do @includes, {
        require ModuleX;
        require ModuleY <&something>;
    }

DESCRIPTION
===========

**Experimental:** I do not really know if what this module does is a good idea or the best way to do it, but I am trying it out. Please use with caution and let me know if you have any problems.

When searching for compilation units (more commonly referred to as just "modules" or "packages" or "classes") in Perl 6, the VM hunts through all the [CompUnit::Repository](CompUnit::Repository) objects chained in `$*REPO` (this is a more flexible solution to the `@INC` setting using in Perl 5).

Normally, to add a new repository to the list, you would just run:

    use lib "my-other-lib";
    # load your modules here

However, perhaps you don't wnat to normally load from a location in your program. You might want to load from a location just long enough to get files out of it and then never see it again. This is a common scenario if your application allows for the use of custom plugin code.

This library makes it possible to add a directory to the list of repositories, load the modules you want, and then remove them so that no more code will be loaded from there:

    use-lib-do "my-other-lib", {
        # load your modules here
    }

EXPORTED ROUTINES
=================

sub use-lib-do
--------------

    multi sub use-lib-do(@include, &block)
    multi sub use-lib-do($include, &block)

Given a set of repository specs to `@include` (or `$include`) and a `&block` to run, add those repositories (usually directory names) to `$*REPO`, run the `&block`, and then strip the temporary repositories back out again.

sub require-from
----------------

    multi sub require-from(@include, $module-name)
    multi sub require-from($include, $module-name)

In cases where you only need to load a single module, this can be used as a shortcut for:

    use-lib-do @include, { require ::($module-name) };

AUTHOR & COPYRIGHT
==================

Copyright 2016 Sterling Hanenkamp.

This software is made available under the same terms as Perl 6 itself.
