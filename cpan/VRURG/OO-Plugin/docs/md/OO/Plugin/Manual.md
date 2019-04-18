PREFACE
=======

This document is provinding the reader with in-depth explanation of how `OO::Plugin` framework works. Technical details are provided in respective modules.

INTRODUCTION
============

This framework is intended to provide a mechanizm of extending an application functionality through use of third-party provided plugins. The following functionality is provided for a plugin:

  * Method call handling for the purposes ranging from simply monitoring a method call to completely replacing the original method functionality with plug-provided one.

  * Class overriding using inheritance. I.e. an arbitrary core class can be inherited by a plugin-provided class and used by the core code instead of the original.

  * Flexible callbacks.

  * Asynchronous events.

Also supported are automatic plugin module loading, and managing of plugin dependencies and priorities.

DESCRIPTION
===========

Basics
------

All work is done through a plugin manager. It is generally recommended to have a single instance of plugin manager per application. The application, in turn, is supposed to delegate it's object creation functionality to the manager. I.e., where usually we create an instance with this line of code:

    my $foo = Foo.new( attr => 'a value' );

it is now recommended to have this:

    my $foo = $plugin-manager.create( Foo, attr => 'a value' );

Alternatively, if one needs a class to work with but still capable of supporting plugins, he can do the following:

    my \foo-class = $plugin-manager.class( Foo );

What happens under the hood is that the manager takes your class, considers what plugins are requesting to modify its behavior, and then creates a new class for you which will delegate some of its functionality to the plugins. This is somewhat simplified description of what is happening but it is only intended to explain why the delegation is necessary.

All the above also means that the creation of a plugin manager object is one of the first thing an application must do before anything else. Typically, the code would look like this:

class MyApp { has OO::Plugin::Manager $!plugin-manager;

    submethod TWEAK {
        $!plugin-manager .= new( base => 'MyApp' );
        $!plugin-manager.load-plugins;
        $!plugin-manager.initialize( app => self );
    }

}

Of these three steps invocation of the `load-plugins` method is optional. This is where automatic pre-loading of plugins from external modules is happening. Refer to corresponding section below to find out more about this process.

By invocing `initialize` we actually make the manager ready to do its job. The point for having all these stages is to allow an application to perfom some extra additional steps before plugins are activated. Those are:

  * disabling unwanted plugins

  * defining plugin priorities and, possibly, desired order of the plugins

Future versions of the framework may have some additional functionality and this more things could be done before we start using the manager.

**NOTE** *Though plugin disabling and changes to the ordering are not prohibited after the manager is initialized, they're not recommended due to possible unwanted side effect. Moreover, ordering is only done while manager is initializing.*

A thing in the above code which worth mentioning here is the parameters to the `initialize` method call. The method itself doesn't take any. Whatever it receives is getting passed to the constructors of newly created plugin objects (this subject will be covered later). In my code what happens is that application object informs its plugins about itself allowing direct interaction between plugins and the application. By providing special API an application could get even more from its plugins that what is covered by the manager. Consider the following sample plugin:

    plugin MyPlugin {
        has MyApp:D $.app is required;

        submethod TWEAK (|) {
            $.app.register-macro( "some_macro", self.^find_method('my-macro') );
        }

        method my-macro ( $param ) { "$param is now expanded" }
    }

Whatever other extensible subsystem is provided by application is then left up to the application and its plugins, the manager is not involved and thus leaves more space for developer's imagination.

Pre-loading Plugins And Naming.
-------------------------------

When the manager is created it's `base` attribute can be defined. This attribute defines a namespace prefix to be used when looking for plugins in external modules. For the example above the manager will try to load all modules with names starting with *MyApp::Plugin::* or *MyApp::Plugins::*. Upon loading all classes contained in these modules and defined using `plugin` keyword will register themselves with the framework. This allows a single module to define more than one plugin:

    unit module MyApp::Plugins::MySet;

    plugin Plugin1 {
        ...
    }

    plugin Plugin2 {
        ...
    }

As a result of compiling this module the framework will know about two new plugins `Plugin1` and `Plugin2`. Yet, it must be noted that though we're referring to them here with their short names, the framework will know them by their fully qualified names (FQN): `MyApp::Plugins::MySet::Plugin1` and `MyApp::Plugins::MySet::Plugin2`. This is to prevent name clashes when accidentally plugins from different packages are given same names.

Ordering And Priorities
-----------------------

It is possible for a two more plugins to be handling same method, class, or callback. In this case it becomes very important to define the order in which their respective handlers are used. When ordering plugins the manager takes into consideration a couple of plugin attributes such as:

  * user-defined priority

  * user-defined ordering

  * plugin-declared dependencies

Priorities could be of three different levels: *first*, *normal*, and *last*. Their names suggest that user wants a plugin to be one of the first in the list, one of the last, or in the middle. The latter is the default.

Within each priority a user can define in what particular order he wants the plugins. See [section](#user-defined-ordering) below.

To simplify user's life we don't want to make it his responsibility to find out if a *Plugin1* only works if it follows, say, *Plugin2*. The framework lets plugins define these kind of relations. More than that, it is also possible to specify wether the relation is desirable or it is demanded. Consider the following code:

    plugin Plugin1 after Plugin2 before Plugin3 demands Plugin4, Plugin5 {
        ...
    }

Though rather unlikely to be met in real life, this code demonstrates what can be specified for a plugin. Here traits `after` and `before` (**note** that `before` is just a reverse of `after`. I.e. `Plugin1 before Plugin2` is the same as `Plugin2 after Plugin1`) define desirable relations. In other words, no fatalities would happen if these relations are broken. 'Broken' means here that either *Plugin2* or *Plugin3* are missing; or together with *Plugin1* and, possibly with some other plugins too, they form a circular dependency (see below about sorting).

On the other hand, `demand` means that if it can't be fulfilled then the only way to resolve the situation is to disable this plugin.

### User Defined Ordering

It is possible for a user to specifically set the wanted order of plugins within each priority. E.g., for a set of plugins *P1, P2, P3, P4, P5, P6, P7, P8, P9, P10* a user can specify that:

  * *P7*, *P3*, *P5* must go *first* and preserve the order specified; i.e. *P5* must go after *P3*, and *P3* must go after *P7*.

  * *P4*, *P1*, *P8* must got *last* and preserve the orider specified.

For user-ordered plugins there is a rule that they will go first within their priority if they belong to *first* or *normal*; and they will go after unordered ones within *last*.

**NOTE** Read the followin section carefully as the resulting order might differ from user expectations.

### Sorting

The manager will do its best to conform all the ordering parameters. But due to the complexity of the matter the only rule which can be taken for granted is:

  * *a demanded plugin will preceed the one which demands it*

  * *if a couple of plugins demanding each other form a cyclic dependency graph then all nodes of the graph will be disabled*

  * *if a plugin demands a disabled or missing plugin it will be disabled too*

All other relations, including user-defined, are considered voluntary. Though they're prioritized in the following order (from more prioritized down to less):

  * `after`/`before` relations

  * user order within priority

  * user-specified priority

For example, if a *Plugin1* is of lowest *last* priority but is demanded by or must go before *Plugin2* which is of *first* priority – then *Plugin1* will go before *Plugin2* in the order no matter of their priorities.

As it was stated above, `after` and `before` doesn't impose strict requirements. For that matter if such dependencies form a cycle then manager has the right to break it at any link. For example, we have:

    A -> B -> C -> D -> A

where arrow stands for `after`. The resulting order could be any of:

    A, D, C, B
    B, A, D, C,
    C, B, A, D
    D, C, B, A

It would only depend on what plugin is chosen first by the sorting algorithm to start building the sequence. With regard to the priorities, cicles might produce pretty surprising result: a plugin with higher priority will go last in the order! Say, specifying that *D* has the *first* priority while leaving all others at *normal* will result in the third sequence of the above example.

Also, because demanded relations are unbreakable, then when a cycle is formed of all `demand`s execpt for a single link the manager will predictably break that link, making it's left side element the first. For example, if `A -> B` is the desired one whereas all the reast are demanding, then the final order will be:

    A, D, C, B

### How Ordering Is Used?

This will be covered in the section below.

Writing A Plugin
----------------

A plugin is an instance of a class inheriting from a `Plugin` class defined in [OO::Plugin::Class](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Class.md) module. To reduce the boilerplate and provide better readability of the code special class declarator `plugin` is provided:

    plugin MyPlugin {
        ...
    }

It is accompanied with three additional traits: `after`, `before`, and `demand`, each of them taking a list of plugin names:

    plugin MyPlugin after Plugin1, Plugin2, MyApp::Plugin::Plugin3 {
        ...
    }

As you can see, the names could be in both short and FQN forms. Their validity is not checked at the compile time because the order of loading of plugin modules cannot be pre-determined. Besides, since `after` and `before` are not strict missing a plugin cannot be considered a error. For this reason, all the checks are preformed at run-time.

### Method Handling

A plugin can request to handle a public method call in an application class. This is not just call interception as one might expect but something bigger than that. Method handling allows a wide variety of tricks from simply monitoring method calls to completely substitute a method with own code (which is in fact the interception as I see it). It is also possible to mangle with the original method parameters and return value.

The method call process is split in three stages: *before* the call, *around* it, and *after*. Every stage has certain specific and its own purpose. We'll get to this later. For now what matters is that the manger considers each stage as a separate queue of routines to be executed. I call it _execution chain_. In a way, the original method is also considered as a member of the *around* chain, though a special one. The order of the routines is defined by the order of the plugins they belong to. For example:

    plugin Plugin1 {
        method around-bar1 ( $msg ) is plug-around(:MyClass<bar>) { ... }
    }

    plugin Plugin2 before Plugin1 {
        method around-bar2 ( $msg ) is plug-around(:MyClass<bar>) { ... }
    }

`around-bar2` will gain control before `around-bar1` due to `before` trait defining the plugin order.

**NOTE** I'm not detailing the code itself in hope that it is self-explainable. Will carry on on syntax later anyway.

A special packet of information is passed to every method handler as the first method parameter. It is called *message* and it is an object of `MethodHandlerMsg` class. The object is presistent across one method call handling session and is being passed to each and every handler method. In addition to some technical information about the call, it contains two special attributes: `shared` and `private`. Those are read/write accessible and can be used by plugins to pass information between different handlers and stages.

  * `shared` is a hash which is kept unchanged by the manager and therefore allows for some data exchange between method handlers from different plugins within the current handling session.

  * `private` is somewhat similar to `shared` except that it is a unique value being kept for each plugin separately. It only allows a plugin to store a value across stages of the same handling session. `private` is a scalar and its content is solely defined by what a plugin code stores in it.

For example:

    plugin Plugin1 {
        method before-bar ( $msg ) is plug-before(:MyClass<bar>) {
            $msg.private = "info from 'before'";
        }

        method after-bar ( $msg ) is plug-after(:MyClass<bar>) {
            say $msg.private; # "info from 'before'"
        }
    }

#### Method Return Value

Method handlers plugged into *around* or *after* stages can override the return value of a method. To do so they must set `rc` attribute or the message packet using `set-rc` method:

    plugin Plugin1 {
        method around-bar ( $msg ) is plug-around(:MyClass<bar>) {
            $msg.set-rc("my return");
        }
    }

For the *around* stage this action would a have a side-effect of preventing the original method from being executed.

The handlers of *after* stage can use the `rc` attribute of the message packet to inspect the return value (wherever it was set previously). They're also allowed to change it.

The *before* stage handlers are not allowed to set the return value. If they attempt to then a warning would be issued by the manager.

**NOTE** The return value is not checked agains the original method's signature constraint if there is one.

#### Chain Control

A method handler is capable of controlling the execution chain up to some extent. It can request the manager to either stop processing the chain right away or restart it from the beginning. Those actions are similar to `last` and `redo` commands available for controling the loops. Correspondingly, the framework provides `plug-last` and `plug-redo` for the convinience of a plugin writer. Behind the scenes special exceptions `CX::Plugin::Last` and `CX::Plugin::Redo` are utilized.

With `plug-last` *around* and *after* handlers can supply a single parameter to set the return value on the message packet.

`plug-redo` must be used with care as it may cause an infinite loop. Next versions of this framework might impose a limit on the number of `redo`s emitted by a single plugin.

#### Parametrized Handlers

The message object received by a handler has an attribute `params` which is a `Capture` of the orginal method parameters. Having a handler which is only deals with the message packet has an advantage of making it capable of handling multiple original methods in the most simple way. For example, the following code would record all calls of all methods of `MyClass`:

    plugin Recorder {
        method bind-them-all ( $msg ) is plug-before( 'MyClass' ) {
            say $msg.method, " with ", $msg.params;
        }
    }

But this isn't really handy when one actually needs to have access to the parameters. Of course, there are a couple of ways to destructure a `Capture` object, but that adds to the complexity of the code - something I always want to avoid. For this reason, there is a simpler solution. If the plugin manager sees more than one parameter in the handler signature it passes the orignal method parameters next to the message packet object:

    class MyClass {
        method bar ( Int:D $i ) {
            return -$i
        }
    }

    plugin Plugin1 {
        method before-bar ( $msg, Int:D $i ) is plug-before(:MyClass<bar>) {
            say "bar() with Int: $i";
        }
    }

    OO::Plugin::Manager.new.create( MyClass ).bar( 42 ); # bar() with Int: 42

**NOTE** For speeding up operations parameters are not checked against handler signature by the plugin manager code.

**NOTE** The framework checks for the handler signature validity by inspecting its first parameter. It has to be a scalar (i.e. has `$` sigil) and be of type `Any`. It would better bet `MethodHandlerMsg` but due to a bug in Perl6 this is not possible for now because it causes an internal error.

Same rule apply to multi-dispatch method handlers where the `plug-` traits are to be applied to the `proto`:

    plugin Plugin1 {
        proto method around-bar ( $msg ) is plug-around(:MyClass<bar>) {*}
        multi method around-bar ( $msg ) { ... }

        proto method before-bar ( $msg, | ) is plug-before(:MyClass<bar>) {*}
        multi method before-bar ( $msg, Int:D $i ) { ... }
    }

**NOTE** Currently it is possible to apply the trait to one of a `multi` variants within multi-dispatch. Doing so is highly discouraged and will be a error at some point in the future!

#### Performance Matters

It must be noted that method handling while being very powerful and flexible tool is pretty costly performance-wise. For speed-sensitive applications consider using [Class Overriding](#Class Overriding).

### Class Overriding

This is a very straightforward method of providing extended or altered functionality for your core. Whenever necessary a plugin can declare a so called `plug-class` which will inherit from a core class:

    use OO::Plugin;
    use OO::Plugin::Manager;

    class MyClass {
        method foo ( Str $s ) {
            S:g/\s/_/ given $s
        }
    }

    plugin Plugin1 {
        plug-class MyPlug for MyClass {
            method foo ( Str $s ) {
                callwith( "my prefix for $s" );
            }
        }
    }

    my $mgr = OO::Plugin::Manager.new.initialize;
    my $inst = $mgr.create( MyClass );
    say $inst.foo("1 2 3");                             # my_prefix_for_1_2_3
    say $inst.^mro;                                     # ((MyClass_4jN3Lv) (MyPlug_YHNAfr) (MyClass) (Any) (Mu))

*Note* that the output of the last line is a sample. The last six chars following the underscore char are random.

Let me explain the magic behind this code. Actually, `plug-class` doesn't declare a class. It declares a role (*they're certain limitations in Rakudo making this the only possible way*). For each `plug-class` defined for the requested core class (`MyClass` in the example) the manager generates an empty class and apply the `plug-class` role to it. Then it sets a parent for the new class (not necessarily it is the core class as more than one plugin is defining a `plug-class` for it). Eventually, a new class is generated which inherits from the newly created inheritance chain.

This result of the alogirth can be observed in the output of `.^mro`. Say, if we add another plugin to the above code:

    plugin Plugin2 before Plugin1 {
        plug-class MyPlug2 for MyClass {
            ...
        }
    }

The resulting chain would then look like this:

    ((MyClass_4jN3Lv) (MyPlug2_NjJk1a) (MyPlug_YHNAfr) (MyClass) (Any) (Mu))

Note that `Plugin2` is declaring to go *before* `Plugin1` - so goes `MyPlug2` before `MyPlug` in the MRO. This is how plugin ordering works for class overriding.

As `plug-class` is a role in nature, so all of the role limitations apply. For example, a role cannot have `our` declarations. Most of those limitations could be overcome by using `plugin`'s body:

    plugin Plugin1 {
        out $plug-class-variable;

        plug-class MyPlug for MyClass {
            method foo {
                say $plug-class-variable;
            }
        }
    }

A `plug-class` doesn't have direct access to the plugin object of his respective `plugin` though. But the object can be obtained with the plugin manager API.

### Callbacks

_Callback_ is a way of calling a special method of a plugin and getting a return value from it. A callback is defined by a string name and can further be detailed with method signature.

Callback is the most simple and straightforward way of direct interaction between application code and plugins: a plugin defines a multi-method `on-callback`:

    plugin Plugin1 {
        multi method on-callback ( 'my-callback', $msg, Str $p1, Int $p2 ) {
            ...
            return "The Universe";
        }
    }

Then application issue a call:

    my $mgr = OO::Plugin::Manager.new;
    ...
    say $mgr.callback( 'my-callback', "the answer", 42 ); # The Universe

and it gets dispatched to matching `on-callback` methods of all plugins. This also implies that for any given callback the term _execution chain_ defined in [Method Handling](#Method Handling) applies too, as well as the methods to control the chain using `plug-last` or `plug-redo` routines.

Similarly to method handling, a callback receives a message object of `PluginMessage` type. (*Actually, `PluginMessage` is the base class of `MethodHandlerMsg`*) And same way, as for method handling, a callback can specify its return value using `set-rc` method of the object or by returning the value. In the latter case the value must be defined and not already set in any other manner (like by a previous callback in the chain) or it will be dropped by the manager. If a callback needs to return a type then this can only be done with `set-rc` or `plug-last`.

If a callback doesn't use `plug-last` to indicate the termination of the execution chain, then any next callback from a later-located plugin can override it with own value using `set-rc` method of the message object.

### Events

Similarly to callbacks, _event_ is a way of calling a special method of a plugin. Events are different in a way that they're handled asynchronously and are designed for mostly one-way communication: from application to plugins. Event is handled by a multi-method too:

    plugin Plugin1 {
        multi method on-event ( 'my-event', Str $p1, Int $p2 ) {
            ...
        }
    }

Contrary to other handler methods, it doesn't receive any special message object, as it is clear from the example.

On the application side, sending of an event is as simple as:

    my $mgr = OO::Plugin::Manager.new;
    ...
    my $promise = $mgr.event( 'my-event;, "the answer", 42 );

The returned `Promise` will be kept when all event handlers are completed.

If there is more than one event handler with the same signature matching the passed parameters, then they will be executed in parallel. The number of simultaneously running handlers is limited by `event-workers` attribute of the plugin manager. Setting it to 1 will cause the handlers to be called one after another but still in a separate thread, so the main application code may proceed as usual.

Clearly, the plugin ordering doesn't apply to event handling; this neither execution chain is used. Therefore it is guaranteed that for every event all its matching handlers will be called.

To allow the handlers complete without interruption it is highly recommended for an application to call method `finish` on the plugin manager object before exiting the application:

    $mgr.finish;

#### Nuances

  * Events are dispatched by a special method in its own thread. To reduce resource consumption, it is not getting started until an event is sent by the application. It will also shutdown if no event is been sent over a timeout period. The timeout is defined by `ev-dispatcher-timeout` attribute of the manager.

  * It is still possible to obtain return value of a particular event handler. The `Promise` returned by the `event` method is kept with an array of `Promise`s of each event handler. Those are being kept with two-element arrays where the first element is a plugin object, and the second is event handler return value.

  * If an event handler throws and exception it is silently consumed by the dispatcher. But the exception can be fetched from the second element of event handler's `Promise` where it will be stored instead of the return value.

***NOTE** Other methods of reporting errors back to the user code are considered. Any feedback is welcome!*

Plugin META
-----------

Any plugin has some meta-data attached to it. The format is as simple as it can be: it's a hash of meta-keys with values. There is no predefined set of keys. Any application can use any keys for its own purpose. Though a couple of keys are reserved for the plugin manager itself. Those are:

  * `version`

    Plugin version. Must be a `Version` object.

  * `name`

    Plugin short name as the developer wants it to be. This allows to override short name obtained from plugin's module name. Both name can later be used to get FQN of the plugin.

  * `after`, `before`

    Desirable ordering relations.

  * `demand`

    Demanding `after` ordering relation.

The meta is registered from within plugin's body block either with `plugin-meta` routine, or with `our %meta` hash:

    plugin Plugin1 {
        our %meta = key1 => "value1",
                    key2 => "value2",
                    key3 => 42,
                    ;

        plugin-meta key1 => "value 1",
                    key4 => "value 4",
                    demand => <Plugin2 Plugin3>,
                    ;
    }

For the same key `key1` the value from `plugin-meta` will take precedence. Generally speaking, the precedence of sources for the meta are:

  * plugin declaration

  * `plugin-meta`

  * `%meta`

Keys declared in higher priority override keys from lower priority source.

`after`, `before`, and `demand` are keys which are taken special care. Those can be declared in the plugin declarion with traits of the same names. So, for the code:

    plugin Plugin1 after Plugin2 {
        our %meta = demand => <Plugin5>,
                    before => <Plugin6>,

        plugin-meta after  => <Plugin3>,
                    before => <Plugin3>,
                    ;
    }

The final meta will be:

    after  => <Plugin2>, # from the declaration
    before => <Plugin3>, # from plugin-meta
    demand => <Plugin5>, # from %meta

**NOTE** Though the values above are strings, in real life ordering meta keys are `Set`s of plugin names.

Another meta key taken from plugin declaration is `version`:

    plugin Plugin1:ver<0.1.0> {
        ...
    }

unless there is manually defined `version` key declared by the programmer.

Pluggables
----------

The framework provides a special trait `is pluggable` which is applicable to both classes and methods and marks those of them which the users wants to allow to be overriden. For example:

    class Foo is pluggable {
        ...
    }

    class Bar {
        ...
        method plug-me is pluggable {
            ...
        }
    }

The outcome of applying the trait differs depending on wether the plugin manager is in *strict* or *loose* mode. In the former case it will raise an error for any attempt to override an unpluggable class or attach a handler to an unpluggable method. In the latter case (which is the default) any class or method is considered pluggable and gets registed as such with [OO::Plugin::Registry](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Registry.md).

A user can request a registry of pluggables from [OO::Plugin::Registry](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Registry.md#method-pluggable-classes). This information can be used, for example, to provide a plugin developer with the information about what objects are opened for "suggestions".

Note though that in *loose* mode the manager will register any class or method requested by a plugin as pluggable. This functionality is considered experimental and might be a subject for change in the future.

Traits
------

The framework provides a couple of traits. They were mostly noted in this manual, but it worth listing them all together in this section.

### is pluggable

The most simple trait simply marking a class or a method as allowed for plugging. It is described in section [Pluggables](#pluggables).

### is plug-(before|around|after)

These three traits must be applied to plugin methods implementing method handling. They define what stage of the method call to install the handler into. Their parameters define what method of what class is to be handled. There're two forms allowed for the parameters: `List` and `Hash`.

In the list form each element of the list could either be a `Pair` or a string. When it's a pair then the key is a class name and the value is a method name. The method name, in turn, could be just an asterisk *'*'* to specify all public methods of the class:

    plugin Plugin1 {
        method around-foo ( ... ) is plug-around( :Foo<foo> ) {
            ...
        }
        method monitor ( |params ) is plug-before( Foo => '*', 'Bar', <Baz Fubar> ) {
            ...
        }
    }

*Note* Despite all over this manual I use *(before|around|after)-* prefix for method handlers, it's has nothing to do with the framework requirements. The method handler name is absolutely irrelevant and can be anything allowed by Perl6.

The `monitor` handler will be called before all methods of `Foo`, `Bar`, `Baz`, and `Fubar` classes. Whereas `around-foo` will only handle method `foo` of `Foo`, pardon for this pub.

When the trait parameter is a hash the it must have two keys: *class* and *method*:

    plugin Plugin1 {
        method monitor ( |params ) is plug-before{ class => 'Foo', method => '*' } {
            ...
        }
    }

### after, before, demand

These three are pseudo-traits in a way that they don't have a representation via the `trait_mod` routine. They can only be used with a plugin class declared with `plugin` keyword. Their meaning is mostly outlined in `Ordering And Priorities|#ordering-and-priorities` section of this manual. Their syntax is extremely simple: they all take a list of plugin names in unquoted form. Note that it is not plugin classes we're talking about now because if a class is not available then this would be a syntax error. But the validity of these names is checked much later, at the plugin manager initialization stage. And even then only the absense of *demand*ed plugins is considered a problem.

It is also worth noting that both short names and FQNs are accepted by the traits. Though the use of short names must be carefully considered because of their possible duplication.

    plugin Plugin1 after MyApp::Plugins::Pugin2, Plugin5 before MyApp::Plugins::Plugin4 {
        ...
    }

### for

This one is also a pseudo-trait in the same meaning, as the previously noted ordering traits. It can only be applied to a `plug-class`. Another similarity to the ordering traits is that `for` accepts list of unquoted names. Though this time it's a list of classes the related `plug-class` plans to extend. Short class names are allowed too but with the same precaution about possible duplicates.

**NOTE** Be very careful about mistypes in `for` declaration. There is no way to make sure that a missing class name is because it is wrongly spelled or because it wasn't requested by application code.

SEE ALSO
========

[OO::Plugin](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin.md), [OO::Plugin::Manager](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manager.md), [OO::Plugin::Class](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Class.md) [OO::Plugin::Registry](https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Registry.md)

AUTHOR
======

Vadim Belman <vrurg@cpan.org>

