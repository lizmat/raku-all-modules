use v6.d;
unit class OO::Plugin::Manager:auth<CPAN:VRURG>:ver<0.0.0>:api<0>;
use File::Find;
use OO::Plugin::Metamodel::PluginHOW;
use OO::Plugin::Registry;
use OO::Plugin::Class;
use OO::Plugin::Exception;

=begin pod

=head1 NAME

OO::Plugin::Manager - the conductor for a plugin orchestra.

=head1 SYNOPSIS

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp' )
                .load-plugins
                .initialize( plugin-parameter => $param-value );

    my $plugged-object = $mgr.create( MyClass, class-param => "a value" );

=head1 DESCRIPTION

Most of the description for the functionality of this module can be found in L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md>. Here we just cover
the technical details and attributes/methods.

=head1 TYPES

=head2 enum C<PlugPriority>

Constants defining where the user whants to have a particular plugin:

=item C<plugFirst> – in the beginning of the plugin list
=item C<plugNormal> – in the middle of the list
=item C<plugLast> – in the end of the list

Read about L<sorting|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#sorting> in
L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md>.

=end pod

enum PlugPriority is export <plugLast plugNormal plugFirst>;

my class EventPacket {
    # Event name
    has Str:D $.name is required;
    # Parameters the method has been called with
    has Capture:D $.params is rw is required;
    # Completion promise vow
    has $.vow;
}

# --- ATTRIBUTES
=begin pod

=head1 ATTRIBUTES

=end pod

#| When _True_ will print debug info to the console.
has Bool $.debug is rw = False;

#| The base namespace where to look for plugin modules. See @.namespaces below.
has Str $.base;
#|(
Defines a list of namespaces within $.base attribute where to look from plugin modules. I.e. if set to the default
<Plugin Plugins> then the manager will load modules from ::($.base)::Plugin or ::($.base)::Plugins.
)
has @.namespaces = <Plugin Plugins>;
#| Callback to validate plugin. Allows the user code to check for plugin compatibility, for example. (Not implemented yet)
has &.validator is rw where * ~~ :( $ --> Bool );

#| In strict mode non-pluggable classes/methods cannot be overriden.
has Bool $.strict = False;

#| Errors collected while loading plugin modules.
#| List of hashes of form 'Module::Name' => "Error String".
has @.load-errors;

#| Indicates that the manager object has been initialized; i.e. method initialize() has been run.
has Bool $.initialized = False;

# :moduleName("text reason")
# Reason could later be extended if necessary to be a structure
has %!disabled;

# Information about plugin modules. Hash of hashes of attributes:
# 'A::Plugin::Sample' => { # First level keys must always be plugin's FQN
# Type object corresponding to the class
#       type => TypeObject,
# Plugin version
#       version => v0.0.1,
# Plugin order priority (see PlugPriority)
#       priority => plugNormal,
# Plugin short name as taken either from plugin's module name or from meta.
#       shortname => 'FooPlugin',
# },
has %!mod-info;

# When user wants the plugins to go in the specific order within respective priority. Keys of this hash are priorities.
# Values are lists of plugins
has %!user-order;

# Order of plugins
has @!order;

# Map of all dependencies: after, before, demand
# Keys are dependants, values are sets of dependencies.
has %!dependencies;

# Mapping of short plugin names into FQN
has %!short2fqn;

# Map of plugins into other plugins requiring them.
has %!demanded-by;

# Plugin objects – instantiated plugin classes.
has %!objects;

# Plugin registry instance
has $!registry;

# Caches
has %!cached;

# Event management block.
has Promise $!event-dispatcher;
has Channel $!event-queue;
has Lock $!ev-dispatch-lock .= new;
#| Number of simulatenous event handlers running. Default is 3
has Int:D $.event-workers where * > 0 = 3;
#| Number of seconds for the dispatcher to wait for another event after processing one. Default 1 sec.
has Real:D $.ev-dispatcher-timeout = 1.0;

=begin pod

=head1 METHODS

=end pod

submethod TWEAK (|) {
    $!registry = Plugin::Registry.instance;
}

=begin pod
=head2 method normalize-name
=begin item
C<normalize-name( Str:D $plugin, Bool :$strict = True )>

Normalize plugin name, i.e. makes a name in any form and returns FQN. With C<:strict> fails if no plugin found by the
name in C<$plugin>. With C<:!strict> fails with a text error. Always fails if more than one variant for the given name
found what would happen when two or more plugins register common short name for themselves.
=end item

=begin item
C<normalize-name( Str:D :$plugin, Bool :$strict = True )>

Similar to the above variant except that it takes named argument C<:plugin>.
=end item

I<Note> would always return the C<$plugin> parameter before the plugin manager is initialized.
=end pod

# Due to a slight chance of using more than one plugin manager within same process we can't rely on registry's name
# mapping service because it may contain plugins from another managers too. Though this scenario has enough problems
# to render it useless.

# Only works with plugin names currently. But might be extended to other entities if necessary.
proto method normalize-name (|) {*}
multi method normalize-name ( Str:D $plugin, Bool :$strict = True --> Str:D ) {
    return $plugin with %!mod-info{ $plugin }; # The name is already FQN
    my @name;
    @name = .keys with %!short2fqn{ $plugin };
    unless @name {
        return $plugin unless $strict and $.initialized;
        fail "No FQN for short plugin name '$plugin'; was it installed?";
    }
    fail "Short plugin name '$plugin' maps into more than one FQN" if @name.elems > 1;
    @name[0]
}
multi method normalize-name ( Str:D :$plugin!, Bool :$strict = True --> Str:D ) {
    samewith( $plugin, :$strict )
}

=begin pod
=head2 method short-name

Takes a plugin name and returns its corresponding short name.

=item C<short-name( Str:D $name )>

=begin item
C<short-name( Str:D :$fqn )>

A faster variant of the method because it doesn't attempt to normalize the name and performs fast lookup by FQN.
=end item

=begin item
C<short-name( Plugin:U \plugin-type )>

Gives short name by using plugin's class itself. This is a faster version too because it also uses FQN lookup.

    my $sname = $plugin-manager.short-name( $plugin-obj.WHAT );
=end item
=end pod
proto method short-name (|) {*}
multi method short-name ( Str:D $name ) {
    %!mod-info{ self.normalize-name( $name ) }<shortname>
}
multi method short-name ( Str:D :$fqn ) {
    %!mod-info{ $fqn }<shortname>
}
multi method short-name ( Plugin:U \ptype ) {
    %!mod-info{ ptype.^name }<shortname>
}

=begin pod
=head2 method meta

Returns plugin's META C<Hash>.

=item C<meta( Str:D $plugin )>
=begin item
C<meta( Str:D :$fqn )>

Faster version, avoids name normalization.
=end item
=end pod
proto method meta (|) {*}
multi method meta ( Str:D $plugin --> Hash ) {
    $!registry.plugin-meta( $plugin )
}
multi method meta ( Str:D :$fqn! --> Hash ) {
    $!registry.plugin-meta( :$fqn )
}

=begin pod
=head2 method info

C<info( Str:D $plugin )>

Returns a copy of information hash on a plugin. The hash contains the following keys:

=begin item
C<priority>

Priority (see L<C<PlugPriority>|#enum-plugpriority>)
=end item
=begin item
C<shortname>

Plugin's short name
=end item
=begin item
C<type>

Type (class) object of the plugin
=end item
=begin item
C<version>

Version (C<Version> object)
=end item
=end pod
method info ( Str:D $plugin --> Hash ) {
    my $fqn = self.normalize-name( $plugin );
    # $fqn would contain Failure if the name cannot be normalized.
    return $fqn unless $fqn;

    %!mod-info{ $fqn }.clone
}

=begin pod
=head2 method set-priority

Set plugins priority in the plugin order.

=begin item
C<set-priority( @plugins, PlugPriority:D :$priority, :$with-order? )>

C<set-priority( *@plugins, PlugPriority:D :$priority, :$with-order? )>

The most comprehensive version of the method. Allow not only setting of the priority for a bulk of the plugins but also
to define their order within the specified priority when C<:with-order> is used.

I<Note> that each new call of this method with C<:with-order> adverb will override previously set order for the
specified priority.
=end item
=item C<set-priority( $plugin, PlugPriority:D :$priority )>

See L<C<PlugPriority>|#enum-plugpriority>
=end pod
proto method set-priority (|) {*}

# If :with-order is set then the order of plugins in the array is preserved for the corresponding priority.
multi method set-priority ( |params( @plugins, PlugPriority:D $priority, :$with-order? ) ) {
    if $!initialized || $*PLUG-INITIALZING {
        my @fqn = @plugins.map( {
            my $fqn;
            %!mod-info{ $fqn = self.normalize-name( $_ ) }<priority> = $priority;
            $fqn
        } );
        %!user-order{ $priority } = @fqn if $with-order;
    }
    else {
        self!record-replay( &?BLOCK, params );
    }
}

multi method set-priority ( @plugins, PlugPriority:D :$priority = plugNormal, :$with-order? ) {
    samewith( @plugins, $priority, :$with-order )
}

multi method set-priority ( Str:D $plugin, PlugPriority:D $priority = plugNormal ) {
    samewith( @$plugin, $priority )
}

multi method set-priority ( *@plugins where { $_.all ~~ Str:D }, PlugPriority:D :$priority = plugNormal, :$with-order? ) {
    samewith( @plugins, $priority )
}

=begin pod
=head2 method get-priority

Returns priority value for a given plugin.

=item C<get-priority( Str:D $plugin )>
=begin item
C<get-priority( Str:D :$fqn )>

Faster version, avoids name normalization.
=end item

See L<C<PlugPriority>|#enum-plugpriority>
=end pod

proto method get-priority (|) {*}
multi method get-priority ( Str:D $plugin --> PlugPriority:D ) {
    %!mod-info{ self.normalize-name( $plugin ) }<priority>
}
# This variant is provided for cases when plugin's FQN is already known
multi method get-priority ( Str:D :$fqn! --> PlugPriority:D ) {
    %!mod-info{ $fqn }<priority>
}

=begin pod
=head2 method load-plugins

Initiates automatic loading of plugin modules by traversing modules in repositories and search paths. Only the modules
with names begining in prefix defined by L<C<base> attribute|#has-str-base> and followed by any of
L<C<namespaces>|#has-positional-namespaces> will be loaded. For example:

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp' ).load-plugins;

would auto-load all modules starting with I<MyApp::Plugin::> or I<MyApp::Plugins::>; whereas:

    my $mgr = OO::Plugin::Manager.new( base => 'MyApp', namespaces => <Ext Extensions> ).load-plugins;

would autoload I<MyApp::Ext::> or I<MyApp::Extensions::>.

Returns the invocing C<OO::Plugin::Manager> object, making chained method calls possible.

If a module cannot be loaded due to a error the method appends a C<Pair> of C<<$module-name => $error-text>> to
L<C<@.load-errors>|#has-positional-load-errors>. When L<C<$.debug>|#has-bool-debug> is I<True> the error text will
include error's stack backtrace too.

I<Note> that modules are just loaded and no other work is done by this method.
=end pod

method load-plugins ( --> ::?CLASS:D ) {
    my @mods = self!find-modules;
    MOD:
    for @mods -> $mod {
        require ::($mod);

        CATCH {
            default {
                self!dbg: "Module load failed:\n" ~ ~$_ ~ $_.backtrace.full ~ "----------------------";
                @!load-errors.push: $mod => ~$_ ~ ( $!debug ?? $_.backtrace !! "");
            }
        }
    }
    self!dbg: "Loaded plugins";
    self
}

=begin pod
=head2 method initialize
=item C<initialize( |create-params )>

Performs final initialization of the plugin manager object. This includes:

=item iterating over all plugin classes and collecting their meta information and technical info
=item rebuilding internal caches and structures to reflect the collected information
=item order the plugins corresponding based on priorities, user-defined order, and dependencies
=item create plugin objects

After completion the plugin manager object is marked as I<initialized> effictevly disabling some of its functionality
which  only makes sense until the initialization.

The C<create-params> parameter is passed to plugin object constructors at the creation stage. For example:

    class MyApp {
        has $.mgr;
        submethod TWEAK {
            $.mgr = OO::Plugin::Manager.new
                        .load-plugins
                        .initialize( app => self );
        }
    }

would pass the application object to all loaded plugins. This would simplify the communication between a plugin and the
user code.

B<NOTE> The second initialization stage includes building of mapping of short plugin names to FQN. Before this is done
=end pod

method initialize ( |c-params --> ::?CLASS:D ) {
    die "Can't re-initialize" if $!initialized;

    my $*PLUG-INITIALZING = True;
    %!mod-info = ();
    for $!registry.plugin-types -> \type {
        my $fqn = type.^name;

        self!dbg: "*** TRYING PLUGIN: ", $fqn, " // ", type.^shortname, ", base: ", $.base;

        # Skip plugins with full name not starting with $.base
        my @ns = @!namespaces;
        my $base = $!base;
        next if $.base and $fqn !~~ /^ $base  '::' @ns '::' /;

        self!dbg: "*** PASSED PLUGIN: ", $fqn;

        my $shortname = type.^shortname;
        # Keys from the registry module override keys from plugin module's %meta
        $!registry.plugin-meta( $_, type ) with type::<%meta>;

        my %mod-meta = self.meta( $fqn );

        # TODO: Make sure the version is defined for the plugin.
        %!mod-info{ $fqn }<version> = %mod-meta<version> // $_ given type.^ver;
        %!mod-info{ $fqn }<shortname> = %mod-meta<name> // $shortname;
        %!mod-info{ $fqn }<priority> //= plugNormal;
        %!mod-info{ $fqn }<type> = type;
    }

    self!rebuild-short2fqn;
    self!replay;
    self!rebuild-dependencies;
    self!build-order;

    for @!order -> $fqn {
        next if self.disabled( :$fqn );
        %!objects{ $fqn } = $!registry.plugin-type( $fqn ).new(
            |c-params,
            plugin-manager => self,
            name => $fqn, # It is already FQN as a result of !build-order
            short-name => self.short-name( :$fqn ),
        );
    }

    $!initialized = True;

    self
}

=begin pod
=head2 method disable

Disables plugins.

=item C<disable( Str:D $plugin, Str:D $reason )>
=item C<disable( Plugin:U \type, Str:D $reason )>
=item C<disable( @plugins, Str:D $reason )>
=item C<disable( *@plugins, Str:D $reason )>

A disabled plugin won't have its object created and will be excluded from any interaction with application code. For any
disabled plugin there is a text reason explaining why it was disabled. For example, if a plugin has been found to
participate in a demain cyclic dependecy then it will be disabled with I<"Participated in a demand circle"> reason. The
applicatiob code can later collect the reasons to display them back to the end-user.

I<Implementation note.> The method allows both short plugin names and FQN, as most other methods do. But the name
normalization is not possible before the initialization is complete. To make it all even more fun, disabling is not
possible U<after> the initialization! To resolve this collision, all calls to C<disable> from the user code are only
getting recorded by the framework. The recorded calls are then replayed at the initialization time. Because of this
trick it is not possible to read disable reasons at early stages of the plugin manager life cycle.
=end pod

proto method disable (|) {*}

multi method disable ( |params( Str:D $plugin, Str:D $reason ) ) {
    # Due to the issue #2362 (https://github.com/rakudo/rakudo/issues/2362) we MUST preserve &?ROTINE outside of if
    # control block.
    die "Cannot disable plugin: the manager is already initialized" if $!initialized;
    my &method = &?ROUTINE;
    if try $*PLUG-INITIALZING { # Only do the work while maanger is initializing
        my $fqn = self.normalize-name: $plugin;
        unless %!disabled{$fqn} {
            %!disabled{ $fqn } = $reason;
            with %!demanded-by{ $fqn } {
                # Disable all demanding plugins.
                self.disable( $_, "Demands disabled '{self.short-name($fqn)}'" ) for .keys;
            }
        }
    } else {
        self!record-replay( &method, params );
    }
}

multi method disable ( Plugin:U \type, Str:D $reason --> Nil ) {
    samewith( type.^name, $reason );
}

multi method disable ( @plugins, Str:D $reason ) {
    for @plugins {
        samewith( $_, $reason )
    }
}

multi method disable ( *@plugins, Str:D :$reason ) {
    samewith( @plugins, $reason )
}

=begin pod
=head2 method disabled

If plugin is disabled, a reason text is returned. Undefined value is returned otherwise.

=item C<disabled( Str:D $plugin )>
=begin item
C<disabled( Str:D :$fqn )>

Faster version, not using name normalization
=end item
=item C<disabled( Plugin:U \type )>

There is a parameter-less variant of the method:

=item C<disabled()>

which would return a hash where keys are plugin FQNs and values are reasons.
=end pod

proto method disabled (|) {*}
multi method disabled ( Str:D $name ) {
    %!disabled{ self.normalize-name( $name, :!strict ) }
}
multi method disabled ( Str:D :$fqn! ) {
    %!disabled{ $fqn }
}
multi method disabled ( Plugin:U \ptype ) {
    samewith( fqn => ptype.^name )
}
multi method disabled () {
    %!disabled.clone;
}

=begin pod
=head2 method enabled

Opposite to L<C<disabled>|#routine-disabled> method. Returns _True_ if plugin is enabled. Supports all the same
signatures as C<disabled> does.
=end pod

method enabled (|c --> Bool) {
    ! self.disabled(|c)
}

=begin pod
=head2 method order

Returns list of plugin names as they were ordered at the initialization time.
=end pod

method order { @!order.clone }

=begin pod
=head2 method plugin-objects

Returns a ordered Seq plugin objects.

See L<C<order>|#routine-order>
=end pod
method plugin-objects {
    @!order.map: { %!objects{ $_ } }
}

=begin pod
=head2 method callback

C<callback( Str:D $callback-name, |callback-params )>

Initiate a callback named C<$callback-name>. Passes C<callback-params> to plugins' callback handlers.

Method returns what callback handler requested to return.

Read more in
L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#callbacks>.
=end pod

method callback( Str:D $cb-name where ? *, |params ) {
    my PluginMessage $msg .= new: params => params;
    my \cb-params = \( $cb-name, $msg, |params );

    my %by-plugin; # Plugin private data

  CALLBACKS:
    for self!plugins-cando( 'on-callback', cb-params ) -> $pobj {
        my $*CURRENT-PLUGIN = $pobj;
        my $loop-action;
        my $fqn = $pobj.name;
        $msg.private = %by-plugin{ $fqn };

        # Isolate exceptions raised in the callback handler with do.
        do {
            self!dbg: "&&& EXECUTE CALLBACK $cb-name";
            my $rc = $pobj.on-callback( |cb-params );
            $msg.set-rc( $rc ) if $rc.defined and not $msg.has-rc;

            CATCH {
                self!dbg: "!!! CAUGHT ", $_.perl;
                when CX::Plugin::Last | CX::Plugin::Redo {
                    $loop-action = $_;
                }
                default { .rethrow }
            }
        }

        %by-plugin{ $fqn } = $msg.private;
        $msg.private = Nil;

        given $loop-action {
            when CX::Plugin::Last {
                self!dbg: "!!! LAST EXCEPTION, RC==", $msg.rc;
                $msg.set-rc( .rc );
                last CALLBACKS
            }
            when CX::Plugin::Redo {
                redo CALLBACKS
            }
        }
    }

    return $msg.rc;
}

=begin pod
=head2 method cb

Shortcut for L<C<callback>|#routine-callback>.
=end pod

method cb (|c) { self.callback( |c ) }

=begin pod
=head2 method event

C<event( Str:D $event-name, |event-params )>

Initiates an event named C<$event-name> and passes C<event-params> to all event handlers.

Returns a C<Promise> which will be kept upon this particular event is completely handled; i.e. when all event handlers
are completed. The promise is resolved to an array of C<Promise>s, one per each event handler been called.

Read more in
L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#events>.

See also L<C<finish>|#routine-finish>.
=end pod
method event ( Str:D $name where { .chars > 0 }, |params ) {
    $!ev-dispatch-lock.protect: {
        unless $!event-queue {
            self!dbg: "+++ Creating event queue";
            $!event-queue .= new;
            $!event-queue.closed.then( { $!event-queue = Nil } );
        }

        unless $!event-dispatcher.defined {
            self!dbg: "+++ Starting event dispatcher";
            $!event-dispatcher = start {
                self!dispatch-event;
            }

            $!event-dispatcher.then( {
                self!dbg: "... Event dispatcher is done, cleaning up";
                # Clean up after dispatcher finishes.
                $!event-dispatcher = Nil;
            } );
        }
    }

    self!dbg: "Sending event to the queue";
    my $complete = Promise.new;
    $!event-queue.send: EventPacket.new( :$name, vow => $complete.vow, params => params );
    $complete
}

=begin pod
=head2 method has-plugin

C<has-plugin( Str:D $plugin )>

Returns true if plugin is registered with this manager
=end pod
method has-plugin ( Str:D $plugin --> Bool ) {
    %!mod-info{ $plugin }:exists
        or ( %!short2fqn{ $plugin }:exists and %!short2fqn{ $plugin }.elems > 0 )
}

=begin pod
=head2 method plugin-object

=item C<plugin-object( Str:D $plugin )>
=item C<plugin-object( Str:D :$fqn )>

Retruns the requested plugin object if it exists. As always, the C<:$fqn> version is slightly faster.
=end pod

proto method plugin-object (|) {*}
multi method plugin-object ( Str:D $name ) {
    %!objects{ self.normalize-name: $name }
}
multi method plugin-object( Str:D :$fqn ) {
    %!objects{ $fqn }
}

=begin pod
=head2 method all-enabled

Returns unordered C<Seq> of all enabled plugin FQNs.
=end pod
# Return all enabled plugins
method all-enabled ( --> Seq:D ) {
    %!mod-info.keys.grep: { self.enabled( fqn => $_ ) }
}

=begin pod
=head2 method class

C<class( MyClass )>

One of the two key methods of this class. For a given class it creates a newly generated one with all C<plug-class>es
and method handlers applied. All the magic this framework provides with regard to extending application classes
functionality through delegating to the plugins is only possible after calling this method. Read more in
L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#basics>.
=end pod

method class ( Any:U \type --> Any:U ) {

    return %!cached<types>{ type.^name } if %!cached<types>{ type.^name }:exists;

    my Mu:U $plug-class;
    if !$.strict or $!registry.is-pluggable( type ) {
        # Force-register class as pluggable to allow for later short<->fqn name transofrmations
        $!registry.register-pluggable( type ); # EXPERIMENTAL Class name mapping might not be needed after all.
        $plug-class := self!build-class( type );
    }
    else {
        # Leave non-pluggable classes alone.
        $plug-class := type;
    }

    %!cached<types>{ type.^name } = $plug-class;
}

=begin pod
=head2 method create

C<create( MyClass, |constructor-params )>

Creates a new instance for class C<MyClass> with all the magic applied, as described for L<method C<class>|#class> and
in L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#basics>. This
method is what must be used in place of the standard C<new>.
=end pod

method create ( Any:U \type, |params ) {
    my \wrapped-class = self.class( type );
    wrapped-class.new( |params )
}

=begin pod
=head2 method finish

This is the plugin manager finalization method. It must always be called before application shutdown to ensure proper
completion of all event handers possibly still running in the background.
=end pod

method finish {
    # First, let the event loop complete.
    $!event-queue.close;
    await $!event-dispatcher if $!event-dispatcher.defined;
}

method !find-modules ( --> Array(Iterable) ) {
    return () unless ? $.base; # Don't load external plugins if base is not defined.
    gather {
        for $*REPO.repo-chain -> $r {
            given $r {
                when CompUnit::Repository::FileSystem {
                    my @bases = @.namespaces.map: { $*SPEC.catdir( ( $!base ~ '::' ~ $_ ).split( '::' ) ) };
                    # Get number of elements in the base prefix – to drop them off later and form pure module path and
                    # name.
                    my $dircount = $*SPEC.splitdir( $r.prefix ).elems;
                    for find( dir => .prefix, type => 'dir', exclude => rx{ [ '/' || ^^ ] '.precomp'}, :keep-going ) -> $dir {
                        given $dir {
                            when / @bases $ / {
                                for .dir.grep: { .f } -> $path {
                                    my $mod-name =
                                        $*SPEC.splitdir( $path.extension( "", joiner => "" ) )[ $dircount..* ]
                                              .join( '::' );
                                    take $mod-name;
                                }
                            }
                        }
                    }
                }
                when CompUnit::Repository::Installation {
                    next unless .installed;
                    my @bases = @.namespaces.map: { $!base ~ '::' ~ $_ };
                    for .installed -> $distro {
                        for $distro.meta<provides>.keys.grep( rx/ ^ @bases / ) -> $module {
                            take $module;
                        }
                    }
                }
            }
        }
    }
}

method !pre-sort {
    my @mods = self.all-enabled;

    my $count = @mods.elems;

    # Define priority ranges.
    my %pval =
                plugFirst  => 0,
                plugNormal => $count,
                plugLast   => $count * 2;

    my @sorted;

    for plugFirst, plugNormal, plugLast -> $prio {
        my @user-ordered = @( %!user-order{ $prio } // () );
        my $user-defined = set( @user-ordered );
        my @pmods = @mods.grep: { !$user-defined{ $_ } and %!mod-info{ $_ }<priority> == $prio };
        if $prio == plugLast {
            # For the last plugins we suggest that user wants them to be very last.
            @sorted.append: |@pmods, |@user-ordered;
        }
        else {
            @sorted.append: |@user-ordered, |@pmods;
        }
    }

    @sorted
}

method !topo-sort ( @mods ) {
    my enum TPSSeenMark <tpsTemp tpsFinal>;
    my $circled-on; # Plugin on which we detected a possible demand circle.
    my @demand-circle; # Plugins forming circle and demanding each other.
    my @sorted;

    # --- START walk-elem
    sub walk-elem ( $fqn, %SEEN is copy, :$depth = 0 ) {
        my @collected;

        sub msg (**@m) { self!dbg( "  " x $depth, |@m ) }

        %SEEN{ $fqn } = tpsTemp;

        # self!dbg: %SEEN.perl;

        my class X::OO::Plugin::BadDep is Exception { }
        sub bad-dep {
            # %SEEN{ $fqn } = tpsFinal;
            msg "Reporting bad dependency for ", self.short-name($fqn);
            X::OO::Plugin::BadDep.new.throw
        }

        with %!dependencies{$fqn} -> %deps {
            my $sn = self.short-name: $fqn;
            msg "@@@ Checking deps of {$sn}: ", %deps.perl;
            for <demand after> -> $dt {
                msg ">> DEP TYPE $dt";
                my $demands = $dt eq 'demand'; # Just a shortcut.
            DEPENDENCY:
                for %deps{$dt}.keys -> $p {
                    my $snp = try { self.short-name: $p } // $p;
                    msg "??? Trying DEP $snp";
                    next DEPENDENCY if %SEEN{ $p } ~~ tpsFinal;
                    my $bad-dep-msg;
                    if !self.has-plugin($p) { # Check if dependecy actually exists
                        $bad-dep-msg = "Demands missing '$snp' plugin";
                    }
                    elsif self.disabled( $p ) {
                        msg "... DISABLED $snp ";
                        $bad-dep-msg = "Demands disabled '$snp' plugin";
                    }
                    with $bad-dep-msg {
                        msg "BAD MSG: ", $bad-dep-msg;
                        next unless $demands; # For soft dependency simply proceed further, skip this dep.
                        # Otherwise disable current plugin and notify caller.
                        self.disable( $fqn, $_ );
                        bad-dep;
                    }
                    given %SEEN{$p} {
                        when tpsTemp {
                            msg "!!! CIRCLED ON $snp";
                            unless $demands {
                                # Simply skip this dependency if not demanding.
                                msg "SKIPPING $snp for now";
                                next DEPENDENCY
                            }
                            $circled-on = $p;
                            # @demand-circle.push: $p;
                            bad-dep;
                        }
                        when tpsFinal {
                            next DEPENDENCY;
                        }
                        when TPSSeenMark:D {
                            die "Sorting code changed but hasn't been completed!"
                        }
                        when Any:D {
                            die "Unexpected TPS seen mark value: " ~ $_.perl
                        }
                    }
                    # Our dependency is clear, OK to proceed
                    msg "& WALKING ON DEPENDENCY $snp";
                    my ($subc);
                    ($subc, %SEEN) = walk-elem( $p, %SEEN, depth => $depth + 1 );
                    @collected.append: @$subc;

                    CATCH {
                        msg "??? CAUGHT: ", $_.WHAT;
                        when X::OO::Plugin::BadDep {
                            msg "!!! Bad dep for $sn";
                            if $demands {
                                with $circled-on {
                                    msg "?? STILL IN CIRCLE AT DEPTH $depth ON ", self.short-name( $circled-on ), ", rolled back to $sn";
                                    # We're in a possible demand circle.
                                    @demand-circle.push: $p;
                                    if $circled-on eq $fqn {
                                        msg "ROLLED BACK DEMAND CIRCLE at depth $depth: ", @demand-circle.reverse.map({self.short-name: $_}).join("->");
                                        # We returned back to the plugin on which the circle was detected. This IS a
                                        # demand circle after all.
                                        my $circle-str = @demand-circle.map( {self.short-name: $_} ).reverse.join( ' -> ' );
                                        for @demand-circle -> $cp {
                                            msg "Disabling ", self.short-name($cp);
                                            self.disable( $cp, "Participated in a demand circle $circle-str" );
                                            %SEEN{$cp} = tpsFinal;
                                        }
                                        $circled-on = Nil;
                                        @demand-circle = ();
                                        # redo DEPENDENCY; # Try finding out more about this node
                                    }
                                    else {
                                        msg "CLEANING UP SEEN for $sn";
                                        %SEEN{$fqn}:delete; # Clean up seen mark.
                                    }
                                }

                                if $depth == 0 {
                                    self!dbg: "<< !! RETURNING COLLECTED: ", @collected.map: { self.short-name($_) };
                                    return ( @collected, %SEEN );
                                }
                                else {
                                    bad-dep; # Report back to the caller unless this is the top element.
                                }
                            }
                            else {
                                msg "NOT DEMANDING $sn -> $snp";
                            }

                            # It makes sense to retry the same dependency because otherwise we can miss it as a side
                            # effect of rolling back a circle.
                            # do { msg "⚛⚛ REDO DEPENDENCY $snp for $sn"; redo DEPENDENCY } unless %SEEN{ $p } ~~ tpsFinal;
                        }
                        default { .rethrow }
                    }
                }
            }
        }

        msg "+++ Adding ", self.short-name($fqn), " to collected";
        %SEEN{$fqn} = tpsFinal;
        @collected.push: $fqn;
        self!dbg: "<< RETURNING COLLECTED: ", @collected.map: { self.short-name($_) };
        return ( @collected, %SEEN );
    }
    # --- END walk-elem

    my %TPS-SEEN;
    for @mods -> $fqn {
        self!dbg: "SEEN ", self.short-name( $fqn ), ": ", %TPS-SEEN{$fqn};
        next if %TPS-SEEN{$fqn} or self.disabled( :$fqn );
        my $collected;
        ($collected, %TPS-SEEN) = walk-elem( $fqn, %TPS-SEEN );
        self!dbg: "*** SEEN: ", %TPS-SEEN.pairs.map( { self.short-name( $_.key ) ~ ":" ~ $_.value } ).join(", ");
        @sorted.append: @$collected if $collected;
    }

    @sorted
}

method !build-order {
    # Will later do sorting, etc. For now just get in any order skipping all disabled
    self!dbg: "build-order";
    my @mods = self!pre-sort;
    self!dbg: "PRE-SORT:", @mods.map({self.short-name: $_}).join(" → ");
    @!order = self!topo-sort( @mods ); # XXX Don't forget to change!
    self!dbg: "FINAL ORDER: ", @!order.join( " → " );
}

method !autogen-class-name ( Str:D $base ) {
    my $name;
    repeat {
        $name = $base ~ "_" ~ ( ('a'..'z', 'A'..'Z', '0'..'9').flat.pick(6).join );
    } while $!registry.has-autogen-class( $name ); # Be on the safe side, however small are the changes for generating same class name again
    $!registry.register-autogen-class( $name );
    $name
}

# Parameters: wrapped-type, original type
method !build-class-chain ( Mu:U \wtype, Mu:U \type --> Mu:U ) {

    # Build list of plug-classes for this type
    my $type-name = type.^name;
    my %type-ext = $!registry.extended-classes{ $type-name } // {};

    my $last-class := type;

    if %type-ext {
        # Higher-priority plugins must have their classes first in MRO
        for @!order.reverse -> $fqn {
            # self!dbg: "??? TYPE EXT for $type-name of $fqn: ", %type-ext;
            with %type-ext{ $fqn } {
                for $_.list -> \plug-class {
                    self!dbg: "... Plugin $fqn extends $type-name with ", plug-class.^name, " // ", plug-class.HOW;
                    my $name = self!autogen-class-name( plug-class.^name );
                    my \pclass = Metamodel::ClassHOW.new_type( :$name );
                    pclass.^add_parent( $last-class );
                    pclass.^add_role( plug-class );

                    pclass.^compose;

                    $last-class := pclass;
                }
            }
        }
    }

    # The wrapper's class my-plugin will
    my &plugin-method = my submethod {
        my $caller;
        my $skip = True;
        for Backtrace.new.list {
            next unless .code.^can('package');
            $skip &&= .package !=== $?CLASS;
            next if $skip;
            ( $caller = $_ ) && last if .package !=== $?CLASS;
        }
        # TODO Return plugin object when wrapper class gets .plugin-manager attribute
        my \plugin = $caller.package.^plugin;
    };
    &plugin-method.set_name('plugin');
    wtype.HOW.add_parent( wtype, $last-class );
}

# build-class is supposed to be called for unprocessed classes only.
method !build-class ( Mu:U \type --> Mu:U ) {

    my $type-name = type.^name;
    my %methods = $!registry.methods{ $type-name } // {};
    my $wrapper-name = self!autogen-class-name( $type-name );
    my \wtype = Metamodel::ClassHOW.new_type( name => $wrapper-name );

    my $plugin-manager = self;

    self!build-class-chain( wtype, type );

    for %methods.keys -> $mname {
        self!dbg: "-- GENERATING METHOD ", $mname;
        my %routines; # Ordered list of routines to be called for the methods. Keys are stages: before, around, after
        for @!order -> $plugin-fqn {
            self!dbg: "--- PLUGIN $plugin-fqn";
            with %methods{ $mname }{ $plugin-fqn } {
                for .keys -> $stage {
                    self!dbg: "---- STAGE $stage";

                    my &routine = $_{ $stage };
                    self!dbg: "---- SIGNATURE: ", &routine.signature.perl;
                    my $is-dispatcher = &routine.is_dispatcher;
                    my $params = &routine.signature.params;
                    my $param-last = $params.end;
                    # If proto doesn't have | in its signature then dummy named parameter %_ of type Mu is
                    # implicitly added to the end.
                    with $params[$param-last] {
                        $param-last-- if .type ~~ Mu and .slurpy and .named and .name eq '%_';
                    }

                    self!dbg: "PARAM-LAST: ", $param-last, ", type: ", $params[$param-last].type,
                                ", name:", $params[$param-last].name,
                                ", optional:", $params[$param-last].optional,
                                ", slurpy:", $params[$param-last].slurpy,
                                ", named:", $params[$param-last].named,
                                ", name:", $params[$param-last].name,
                                "\n", $params[$param-last].perl;

                    my Bool $with-params = $param-last > 1;

                    self!dbg: "---- MUST USE PARAMS? ", $with-params;

                    %routines{ $stage }.push: %(
                        :&routine,
                        :$with-params,
                        :$plugin-fqn,
                        plugin-obj => %!objects{ $plugin-fqn },
                    );
                }
            }
        }

        my &orig-method = type.^find_method( $mname );
        # self!dbg: "Orig method signature: ", &orig-method.signature;
        # self!dbg: "Orig method mutli: ", &orig-method.candidates;

        # --- WRAPPING METHOD GENERATION BEGINS
        my &plug-method = my method ( |params ) {
            my &callee = nextcallee;
            # self!dbg: "Wrapper for method $mname on ", self.WHICH;
            my ( %by-plugin );

            my MethodHandlerMsg $msg .= new(
                :object(self),
                :params(params),
                :method($mname),
            );

            STAGE:
            for <before around after> -> $stage {

                my Bool $redo-stage = False;

                $msg.stage = $stage;
                $plugin-manager!dbg: "&&& AT STAGE $stage";

                if %routines{ $stage } {
                    my @routine-list = %routines{ $stage }.List;
                    @routine-list = @routine-list.reverse if $stage ~~ 'after';
                    for @routine-list -> $r {
                        # This is where we actually call plugs.
                        my $*CURRENT-PLUGIN = $r<plugin-obj>;

                        $msg.private = %by-plugin{ $r<plugin-fqn> };

                        my &routine = $r<routine>;

                        # Call multi-method
                        $plugin-manager!dbg: "&&& EXECUTE HANDLER ", $r<plugin-obj>.name, "::", &routine.name;

                        if $r<with-params> {
                            $r<plugin-obj>.&routine( $msg, |params );
                        }
                        else {
                            $r<plugin-obj>.&routine( $msg );
                        }

                        %by-plugin{ $r<plugin-fqn> } = $msg.private; # Remember what's been set by the plugin (if was)
                        $msg.private = Nil; # Just be on the safe side...

                        if $msg.has-rc and $stage ~~ 'before' {
                            warn "Plugin `$r<plugin-fqn>` set return value for method $mname at 'before' stage";
                            $msg.reset-rc;
                        }
                    }

                    CATCH {
                        when CX::Plugin::Last {
                            $plugin-manager!dbg: "*** 'LAST' CONTROL RAISED BY ", $_.plugin.^name;
                            $msg.set-rc( $_.rc ) unless $stage ~~ 'before';
                        }
                        when CX::Plugin::Redo {
                            $plugin-manager!dbg: "*** 'REDO' CONTROL RAISED BY ", $_.plugin.^name;
                            $redo-stage = True;
                            .resume
                        }
                        default { $_.rethrow }
                    }
                }

                given $stage {
                    when 'around' {
                        # Only call the original method if no rc is set.
                        if !$msg.has-rc {
                            # self!dbg: "Refer to the original";
                            # self!dbg: "PARAMS: ", params;
                            $msg.set-rc( self.&callee( |$msg.params ) );
                        }
                    }
                }

                redo if $redo-stage;
            }

            $msg.rc
        };
        # --- WRAPPING METHOD GENERATION ENDS

        &plug-method.set_name( $mname );

        wtype.^add_method(
            $mname,
            &plug-method
        );
    }

    wtype.^compose
}

method !rebuild-short2fqn ( --> Nil ) {
    %!short2fqn = ();
    %!mod-info.kv.map: -> $fqn, %info {
        %!short2fqn{ %info<shortname> } ∪= $fqn;
        # ... because <shortname> might have source in plugin meta.
        %!short2fqn{ %info<type>.^shortname }      ∪= $fqn;
    };
}

method !reverse-deps-hash ( Str:D $key, :$strict? --> Hash:D ) {
    my %deps;
    for %!mod-info.keys -> $fqn {
        with self.meta( $fqn ){ $key } {
            %deps{ self.normalize-name( $_, :!strict ) } ∪= $fqn for .keys;
            CATCH {
                when X::OO::Plugin::NotFound {
                    # Ignore missing plugins for non-strict dependencies
                    self.disable( $fqn, "Required plugin " ~ .plugin ~ " not found" ) if ? $strict;
                }
                default { .rethrow }
            }
        }
    }
    %deps
}

method !rebuild-dependencies {
    %!demanded-by = self!reverse-deps-hash('demand', :strict);
    for %!mod-info.keys {
        my %pmeta = $!registry.plugin-meta( fqn => $_ );

        proto settify (|) {*}
        multi settify ( Any:U $ --> Setty:D ) { SetHash.new }
        multi settify ( Setty:D $val --> Setty:D ) {
            SetHash.new: $val.keys.map: { self.normalize-name( $_, :!strict ) };
        };

        %!dependencies{$_}<after>  = settify( %pmeta<after> );
        %!dependencies{$_}<demand> = settify( %pmeta<demand> );
        my %rbefore = self!reverse-deps-hash( <before> );
        %!dependencies{.key}<after> ∪= .value for %rbefore.pairs;
    }
}

# record-replay/replay pair allows to postpone a method execution for later by recording the parameters it was called
# with.
has @!replay-requests;
method !record-replay ( &method, Capture $params ) {
    @!replay-requests.push: { :&method, :$params };
}
method !replay {
    my @records = @!replay-requests;
    @!replay-requests = ();

    for @records -> % (:&method, :$params) {
        self.&method( |$params );
    }
}

method !plugins-cando ( Str:D $method-name, Capture:D \params ) {
    gather {
        for self.plugin-objects -> $pobj {
            my @mlist = $pobj.^can( $method-name ) || next;
            take $pobj if @mlist[0].cando( \( $pobj, |params ) );
        }
    }
}

method !dispatch-event {
    my $p-queue = Channel.new;
    my Lock $pq-lock .= new; # Prevent accidental closing of $p-queue before it's stuffed with worker events.
    self!dbg: "Created worker event queue:", $p-queue.WHICH;

    # Prepare event workers
    my @workers = (^$!event-workers).map: {
        start {
            self!dbg: ">>> EVENT WORKER #", $*THREAD.id, " STARTED";
            react {
                whenever $p-queue -> @ ($pobj, $ev) {
                    self!dbg: ">>> ", $*THREAD.id, " WORKING ON EVENT ", $ev.perl;
                    $ev.vow.keep( # Signal back the completion.
                        [ $pobj, $pobj.on-event( $ev.name, |$ev.params ) ]
                    );
                    CATCH {
                        default {
                            # TODO Implement a common way of reporting these exceptions with minimal involvement of the
                            # user code. Or the user can register a callback where we will be reporting all errors.
                            # DAMNIT! Supplies, of course!
                            $ev.vow.break( [$pobj, $_] );
                        }
                    }
                }
            }
            self!dbg: ">>> EVENT WORKER #", $*THREAD.id, " FINISHING";
        }
    };

    self!dbg: "Created ", @workers.elems, " workers";

    my Bool $done = False;

    # Enter the event loop
    while !$done {
        self!dbg: "... Enter the event loop";

        my atomicint $got-events ⚛= 0;
        my @control-promises;

        # Timeout if no events to dispatch
        @control-promises.push: Promise.in( $!ev-dispatcher-timeout ).then( {
                self!dbg: "... Timeout, got events: ", $got-events;
                $done = $got-events == 0; # No events received while in timeout period, finish the event loop
                $!event-queue.close;
            }
        ) if $!ev-dispatcher-timeout > 0;

        # Finish upon main queue closing – most likely, due to shutdown
        # Actual event dispatching.
        @control-promises.push: $!event-queue.closed.then( {
            self!dbg: "!!! {$*THREAD.id} Finishing by closed queue";
            $done = True
        } );


        @control-promises.push:
            start {
                # Fetch an EventPacket
                self!dbg: "AWAITING FOR A PACKET";
                my $ev = await $!event-queue;
                self!dbg: "GOT PACKET: ", $ev;
                $got-events⚛++;
                self!dbg: "Event packet from the queue: ", $ev.perl;
                # Make params for the event handler.
                my $handler-params = \( $ev.name, |$ev.params );
                my @w-complete;
                $pq-lock.protect: {
                    for self!plugins-cando( 'on-event', $handler-params ) -> $pobj {
                        my $p = Promise.new;
                        @w-complete.push: $p;
                        my $w-ev = $ev.clone( vow => $p.vow );
                        self!dbg: "... Sending event for matching plugin: ", $pobj.^name, " into ", $p-queue.WHICH;
                        $p-queue.send: ($pobj, $w-ev);
                    }
                }
                Promise.allof( |@w-complete ).then( {
                    self!dbg: "@@@ W-COMPLETE of {$ev.name}: ", @w-complete.perl;
                    $ev.vow.keep( @w-complete )
                } );
            };

        my $rc = await Promise.anyof( @control-promises );

        self!dbg: "<<< RC of await: ", $rc, ", done: ", $done;
    }

    self!dbg: "=== CLOSING WORKERS QUEUE";
    $pq-lock.protect: { $p-queue.close };

    # Let all workers finish first.
    await @workers;
}

method !dbg (*@msg) {
    note |@msg if $.debug;
}


=begin pod

=head1 SEE ALSO

L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md>,
L<OO::Plugin|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin.md>,
L<OO::Plugin::Class|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Class.md>
L<OO::Plugin::Registry|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Registry.md>,

=AUTHOR  Vadim Belman <vrurg@cpan.org>

=end pod
