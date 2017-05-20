NAME
====

Pluggable - dynamically find modules or classes under a given namespace

This is a modified version orginally based on https://github.com/tony-o/perl6-pluggable.

SYNOPSIS
========

Given a set of plugins in your library search path:

    a::Plugins::Plugin1
    a::Plugins::Plugin2
    a::Plugins::PluginClass1::PluginClass2::Plugin3

And an invocation of Pluggable like this:

    use Pluggable; 

    class a does Pluggable {
        method listplugins () {
            @($.plugins).map({.perl}).join("\n").say;
        }
    }

    a.new.listplugins;

The following output would be produced:

    a::Plugins::Plugin1
    a::Plugins::Plugin2
    a::Plugins::PluginClass1::PluginClass2::Plugin3

FEATURES
========

  * Role as well as procedural interface

  * Custom module name matching

  * Finding plugins outside of the current modules namespace 

DESCRIPTION
===========

Object-Oriented Interface
-------------------------

When "doing" the Pluggable role, a class can use the "plugins" method:

    $.plugins(:$base = Nil, :$plugins-namespace = 'Plugins', :$name-matcher = Nil)

### :$base (optional)

The base namespace to look for plugins under, if not provided then the namespace from which  pluggable is invoked is used.

### :$plugins-namespace (default: 'Plugins')

The name of the namespace within *$base* that contains plugins.

### :$name-matcher (optional)

If present, the name of any module found will be compared with this and only returned if they match.

Procedural Interface
--------------------

In a similar fashion, the module can be used in a non-OO environment, it exports a single sub:

    plugins($base, :$plugins-namespace = 'Plugins', :$name-matcher = Nil)

### $base (required)

The base namespace to look for plugins under. Unlike in the OO case, this is required in the procedural interface.

### :$plugins-namespace (default: 'Plugins')

The name of the namespace within *$base* that contains plugins.

### :$name-matcher (optional)

If present, the name of any module found will be compared with this and only returned if they match.

LICENSE
=======

Released under the Artistic License 2.0 [http://www.perlfoundation.org/artistic_license_2_0](http://www.perlfoundation.org/artistic_license_2_0)

AUTHORS
=======

  * Robert Lemmen [robertle@semistable.com](robertle@semistable.com)

  * tony-o [https://www.github.com/tony-o/](https://www.github.com/tony-o/)
