Name
====

OO::Plugin::Registry - to register 'em all!

SYNOPSIS
========

    Plugin::Registry.instance.plugin-names;     # list of all registered plugins

DESCRIPTION
===========

This module provides process-wide registration functionality for keeping track of various objects related to `OO::Plugin` framework. Most of the needed functionality is provided via higher-level means by [OO::Plugin](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin.md) and [OO::Plugin::Manager](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Manager.md) modules and described in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Manual.md).

EXPORTS
=======

class Plugin::Registry
----------------------

This class is a singleton and it provides the complete API of this module.

### submethod instance

Returns the instance of this class.

### method register-plugin

Creates a record mapping plugin FQN (fully qualified name) into its type.

### method plugin-names

Returns all FQNs of registered plugins.

### method plugin-types

Returns all types of registered plugins.

### method plugin-type

`plugin-type( Str:D $plugin-FQN )`

Returns type for a given plugin FQN. Fails with `X::OO::Plugin::NotFound` exception if no such plugin found.

### method plugin-meta

Registers or returns plugin's meta.

  * `plugin-meta( %meta, Mu:U \plugin-type )`

    Registers meta for `plugin-type`.

    Note that only new keys from `%meta` will be registerd. I.e. if we do:

        my $r = Plugin::Registry.instance;
        $r.plugin-meta( {key1 => "a"}, Plugin1 );
        $r.plugin-meta( {key1 => "a2", key2 => "b2"}, Plugin1 );

    The final version of meta hash will be:

        key1 => "a", key2 => "b2"

    Another special case is handling of *before*, *around*, *after* keys. While they conform to the above restriction, ther values from the `%meta` parameter will be converted to a list and stored as a `Set`.

  * `plugin-meta( Str:D $plugin )` `plugin-meta( Str:D :$fqn )` `plugin-meta( Plugin:U \plugin-type )`

    These variants return registered plugin meta. Note that the first one attempts to convert short name to FQN whlie two other don't and thus they're a little bit faster.

### method pluggable-classes

Returns all classes registered as pluggable. Consider the [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Manual.md#pluggables) with regard to *strict* or *loose* modes of operation of the plugin manger class.

### method is-pluggable

  * `is-pluggable( Mu:U \class )` `is-pluggable( Str:D $class-fqn )`

    *True* if class is pluggable.

  * `is-pluggable( Str:D $class-fqn, Str:D $method )`

    *True* if method of a class is pluggable.

### method type

`type( Str:D $class-fqn )`

Returns type object for a pluggable class FQN.

### method short2fqn

  * `short2fqn( Str:D $what, Str:D $name )`

  * `short2fqn( $what => $name )`

Converts short name of a pluggable class or a plugin into its FQN. `$what` is either string *'classes'* or *'plugins'*. Returns the `$name` parameter if the name is not found.

### method fqn2short

  * `fqn2short( Str:D $what, Str:D $name )`

  * `fqn2short( $what => $name )`

Converts FQN of a pluggable class or a plugin into its short name. `$what` is either string *'classes'* or *'plugins'*.

### method fqn-class-name

  * `fqn-class-name( Str:D $name )`

Shortcut for `short2fqn( 'classes', $name )`

### method fqn-plugin-name

  * `fqn-plugin-name( Str:D $name )`

Shortcut for `short2fqn( 'plugins, $name )`

### method has-autogen-class

`has-autogen-class( Str:D $class-fqn )`

Returns *True* if `$class-fqn` is already in the registry of auto-generated classes. Helps in avoiding generation of duplicate class names.

### method registry

Returns a deep copy of the registry `Hash`, excluding plugins and classes.

### method plugs

Returns a deep copy of registered plugs. This branch of registry is currently contains only method handlers but other types of plugs might be invented in the future.

### method methods

Returns a copy of registered method handlers `Hash`. It's keys are (by nesting level):

  * pluggable class FQN

  * method of the class

  * plugin FQN

  * method call stage: *before*, *around*, *after*

Leafs are handler methods.

### method pluggables

Returns a copy of pluggables registry. Currently only contains *methods* key.

### method extended classes

Returns a copy of the hash of all classes listed in `for` trait of `plug-class` declarations. The keys are:

  * class FQN

  * plugin FQN

The leafs are list of `plug-class` type objects.

### method plug-classes

Returns a copy of the hash of all registered `plug-classes`. The keys are:

  * plugin FQN

  * `plug-class` FQN

The leafs are hashes of two keys:

  * *type* - `plug-class` type object

  * *extends* - `Set` of class names

### method inventory

Returns a copy of inventory hash. It currently only has one key: *autogen-classs* which is a set of framework-generated class names.

SEE ALSO
========

[OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Manual.md), [OO::Plugin](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin.md) [OO::Plugin::Manager](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Manager.md), [OO::Plugin::Class](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.905/docs/md/OO/Plugin/Class.md)

AUTHOR
======

Vadim Belman <vrurg@cpan.org>

