NAME
====

OO::Plugin::Manager - the conductor for a plugin orchestra.

SYNOPSIS
========

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp' )
                .load-plugins
                .initialize( plugin-parameter => $param-value );

    my $plugged-object = $mgr.create( MyClass, class-param => "a value" );

DESCRIPTION
===========

Most of the description for the functionality of this module can be found in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md). Here we just cover the technical details and attributes/methods.

TYPES
=====

enum `PlugPriority`
-------------------

Constants defining where the user whants to have a particular plugin:

  * `plugFirst` – in the beginning of the plugin list

  * `plugNormal` – in the middle of the list

  * `plugLast` – in the end of the list

Read about [sorting](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md#sorting) in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md).

ATTRIBUTES
==========

### has Bool $.debug

When _True_ will print debug info to the console.

### has Str $.base

The base namespace where to look for plugin modules. See @.namespaces below.

### has Positional @.namespaces

Defines a list of namespaces within $.base attribute where to look from plugin modules. I.e. if set to the default <Plugin Plugins> then the manager will load modules from ::($.base)::Plugin or ::($.base)::Plugins.

### has Callable[<anon>] &.validator

Callback to validate plugin. Allows the user code to check for plugin compatibility, for example. (Not implemented yet)

### has Bool $.strict

In strict mode non-pluggable classes/methods cannot be overriden.

### has Positional @.load-errors

Errors collected while loading plugin modules. List of hashes of form 'Module::Name' => "Error String".

### has Bool $.initialized

Indicates that the manager object has been initialized; i.e. method initialize() has been run.

### has <anon> $.event-workers

Number of simulatenous event handlers running. Default is 3

### has Real:D $.ev-dispatcher-timeout

Number of seconds for the dispatcher to wait for another event after processing one. Default 1 sec.

METHODS
=======

method normalize-name
---------------------

  * `normalize-name( Str:D $plugin, Bool :$strict = True )`

    Normalize plugin name, i.e. makes a name in any form and returns FQN. With `:strict` fails if no plugin found by the name in `$plugin`. With `:!strict` fails with a text error. Always fails if more than one variant for the given name found what would happen when two or more plugins register common short name for themselves.

  * `normalize-name( Str:D :$plugin, Bool :$strict = True )`

    Similar to the above variant except that it takes named argument `:plugin`.

*Note* would always return the `$plugin` parameter before the plugin manager is initialized.

method short-name
-----------------

Takes a plugin name and returns its corresponding short name.

  * `short-name( Str:D $name )`

  * `short-name( Str:D :$fqn )`

    A faster variant of the method because it doesn't attempt to normalize the name and performs fast lookup by FQN.

  * `short-name( Plugin:U \plugin-type )`

    Gives short name by using plugin's class itself. This is a faster version too because it also uses FQN lookup.

        my $sname = $plugin-manager.short-name( $plugin-obj.WHAT );

method meta
-----------

Returns plugin's META `Hash`.

  * `meta( Str:D $plugin )`

  * `meta( Str:D :$fqn )`

    Faster version, avoids name normalization.

method info
-----------

`info( Str:D $plugin )`

Returns a copy of information hash on a plugin. The hash contains the following keys:

  * `priority`

    Priority (see [`PlugPriority`](#enum-plugpriority))

  * `shortname`

    Plugin's short name

  * `type`

    Type (class) object of the plugin

  * `version`

    Version (`Version` object)

method set-priority
-------------------

Set plugins priority in the plugin order.

  * `set-priority( @plugins, PlugPriority:D :$priority, :$with-order? )`

    `set-priority( *@plugins, PlugPriority:D :$priority, :$with-order? )`

    The most comprehensive version of the method. Allow not only setting of the priority for a bulk of the plugins but also to define their order within the specified priority when `:with-order` is used.

    *Note* that each new call of this method with `:with-order` adverb will override previously set order for the specified priority.

  * `set-priority( $plugin, PlugPriority:D :$priority )`

See [`PlugPriority`](#enum-plugpriority)

method get-priority
-------------------

Returns priority value for a given plugin.

  * `get-priority( Str:D $plugin )`

  * `get-priority( Str:D :$fqn )`

    Faster version, avoids name normalization.

See [`PlugPriority`](#enum-plugpriority)

method load-plugins
-------------------

Initiates automatic loading of plugin modules by traversing modules in repositories and search paths. Only the modules with names begining in prefix defined by [`base` attribute](#has-str-base) and followed by any of [`namespaces`](#has-positional-namespaces) will be loaded. For example:

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp' ).load-plugins;

would auto-load all modules starting with *MyApp::Plugin::* or *MyApp::Plugins::*; whereas:

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp', namespaces => <Ext Extensions> ).load-plugins;

would autoload *MyApp::Ext::* or *MyApp::Extensions::*.

Returns the invocing `OO::Plugin::Manager` object, making chained method calls possible.

If a module cannot be loaded due to a error the method appends a `Pair` of `$module-name => $error-text` to [`@.load-errors`](#has-positional-load-errors). When [`$.debug`](#has-bool-debug) is *True* the error text will include error's stack backtrace too.

*Note* that modules are just loaded and no other work is done by this method.

method initialize
-----------------

  * `initialize( |create-params )`

Performs final initialization of the plugin manager object. This includes:

  * iterating over all plugin classes and collecting their meta information and technical info

  * rebuilding internal caches and structures to reflect the collected information

  * order the plugins corresponding based on priorities, user-defined order, and dependencies

  * create plugin objects

After completion the plugin manager object is marked as *initialized* effictevly disabling some of its functionality which only makes sense until the initialization.

The `create-params` parameter is passed to plugin object constructors at the creation stage. For example:

    class MyApp {
        has $.mgr;
        submethod TWEAK {
            $.mgr = OO::Plugin::Manager.new
                        .load-plugins
                        .initialize( app => self );
        }
    }

would pass the application object to all loaded plugins. This would simplify the communication between a plugin and the user code.

**NOTE** The second initialization stage includes building of mapping of short plugin names to FQN. Before this is done

method disable
--------------

Disables plugins.

  * `disable( Str:D $plugin, Str:D $reason )`

  * `disable( Plugin:U \type, Str:D $reason )`

  * `disable( @plugins, Str:D $reason )`

  * `disable( *@plugins, Str:D $reason )`

A disabled plugin won't have its object created and will be excluded from any interaction with application code. For any disabled plugin there is a text reason explaining why it was disabled. For example, if a plugin has been found to participate in a demain cyclic dependecy then it will be disabled with *"Participated in a demand circle"* reason. The applicatiob code can later collect the reasons to display them back to the end-user.

*Implementation note.* The method allows both short plugin names and FQN, as most other methods do. But the name normalization is not possible before the initialization is complete. To make it all even more fun, disabling is not possible _after_ the initialization! To resolve this collision, all calls to `disable` from the user code are only getting recorded by the framework. The recorded calls are then replayed at the initialization time. Because of this trick it is not possible to read disable reasons at early stages of the plugin manager life cycle.

method disabled
---------------

If plugin is disabled, a reason text is returned. Undefined value is returned otherwise.

  * `disabled( Str:D $plugin )`

  * `disabled( Str:D :$fqn )`

    Faster version, not using name normalization

  * `disabled( Plugin:U \type )`

There is a parameter-less variant of the method:

  * `disabled()`

which would return a hash where keys are plugin FQNs and values are reasons.

method enabled
--------------

Opposite to [`disabled`](#routine-disabled) method. Returns _True_ if plugin is enabled. Supports all the same signatures as `disabled` does.

method order
------------

Returns list of plugin names as they were ordered at the initialization time.

method plugin-objects
---------------------

Returns a ordered Seq plugin objects.

See [`order`](#routine-order)

method callback
---------------

`callback( Str:D $callback-name, |callback-params )`

Initiate a callback named `$callback-name`. Passes `callback-params` to plugins' callback handlers.

Method returns what callback handler requested to return.

Read more in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md#callbacks).

method cb
---------

Shortcut for [`callback`](#routine-callback).

method event
------------

`event( Str:D $event-name, |event-params )`

Initiates an event named `$event-name` and passes `event-params` to all event handlers.

Returns a `Promise` which will be kept upon this particular event is completely handled; i.e. when all event handlers are completed. The promise is resolved to an array of `Promise`s, one per each event handler been called.

Read more in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md#events).

See also [`finish`](#routine-finish).

method has-plugin
-----------------

`has-plugin( Str:D $plugin )`

Returns true if plugin is registered with this manager

method plugin-object
--------------------

  * `plugin-object( Str:D $plugin )`

  * `plugin-object( Str:D :$fqn )`

Retruns the requested plugin object if it exists. As always, the `:$fqn` version is slightly faster.

method all-enabled
------------------

Returns unordered `Seq` of all enabled plugin FQNs.

method class
------------

`class( MyClass )`

One of the two key methods of this class. For a given class it creates a newly generated one with all `plug-class`es and method handlers applied. All the magic this framework provides with regard to extending application classes functionality through delegating to the plugins is only possible after calling this method. Read more in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md#basics).

method create
-------------

`create( MyClass, |constructor-params )`

Creates a new instance for class `MyClass` with all the magic applied, as described for [method `class`](#class) and in [OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md#basics). This method is what must be used in place of the standard `new`.

method finish
-------------

This is the plugin manager finalization method. It must always be called before application shutdown to ensure proper completion of all event handers possibly still running in the background.

SEE ALSO
========

[OO::Plugin::Manual](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md), [OO::Plugin](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin.md), [OO::Plugin::Class](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Class.md) [OO::Plugin::Registry](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Registry.md),

AUTHOR
======

Vadim Belman <vrurg@cpan.org>

