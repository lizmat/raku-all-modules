use v6.d;
use OO::Plugin::Class;

=begin pod
=head1 Name

OO::Plugin::Registry - to register 'em all!

=head1 SYNOPSIS

    Plugin::Registry.instance.plugin-names;     # list of all registered plugins

=head1 DESCRIPTION

This module provides process-wide registration functionality for keeping track of various objects related to
C<OO::Plugin> framework. Most of the needed functionality is provided via higher-level means by
L<OO::Plugin|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin.md> and
L<OO::Plugin::Manager|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manager.md> modules and
described in L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md>.

=head1 EXPORTS

=end pod

package OO::Plugin::Registry::_plugins { }
package OO::Plugin::Registry::_classes { } # For pluggable classes

subset PlugPosition of Str:D where * ~~ any <before around after>;

=begin pod
=head2 class Plugin::Registry

This class is a singleton and it provides the complete API of this module.

=end pod

class Plugin::Registry is export {
    use OO::Plugin::Exception;

    has %!registry;

    my $instance;

    method new ( |params ) { self.instance( |params ) }

=begin pod
=head3 submethod instance

Returns the instance of this class.

=end pod

    submethod instance ( |params ) {
        return $instance //= self.bless( |params );
    }

=begin pod
=head3 method register-plugin

Creates a record mapping plugin FQN (fully qualified name) into its type.

=end pod

    method register-plugin ( Mu:U \type ) {
        OO::Plugin::Registry::_plugins::{ type.^name } = type;
        %!registry<name-map><plugins>:delete;
    }

=begin pod
=head3 method plugin-names

Returns all FQNs of registered plugins.

=end pod

    method plugin-names {
        OO::Plugin::Registry::_plugins::.keys
    }

=begin pod
=head3 method plugin-types

Returns all types of registered plugins.

=end pod

    method plugin-types {
        OO::Plugin::Registry::_plugins::.values;
    }

=begin pod
=head3 method plugin-type

C<plugin-type( Str:D $plugin-FQN )>

Returns type for a given plugin FQN. Fails with C<X::OO::Plugin::NotFound> exception if no such plugin found.
=end pod
    method plugin-type ( Str:D $plugin --> Plugin:U ) {
        fail X::OO::Plugin::NotFound.new( :$plugin ) unless OO::Plugin::Registry::_plugins::{$plugin}:exists;
        OO::Plugin::Registry::_plugins::{$plugin}
    }

=begin pod
=head3 method plugin-meta

Registers or returns plugin's meta.

=begin item
C<plugin-meta( %meta, Mu:U \plugin-type )>

Registers meta for C<plugin-type>.

Note that only new keys from C<%meta> will be registerd. I.e. if we do:

    my $r = Plugin::Registry.instance;
    $r.plugin-meta( {key1 => "a"}, Plugin1 );
    $r.plugin-meta( {key1 => "a2", key2 => "b2"}, Plugin1 );

The final version of meta hash will be:

    key1 => "a", key2 => "b2"

Another special case is handling of I<before>, I<around>, I<after> keys. While they conform to the above restriction,
ther values from the C<%meta> parameter will be converted to a list and stored as a C<Set>.
=end item

=begin item
C<plugin-meta( Str:D $plugin )>
C<plugin-meta( Str:D :$fqn )>
C<plugin-meta( Plugin:U \plugin-type )>

These variants return registered plugin meta. Note that the first one attempts to convert short name to FQN whlie two
other don't and thus they're a little bit faster.
=end item
=end pod

    proto method plugin-meta (|) {*}
    multi method plugin-meta ( %meta, Mu:U \type ) {
        die "Can't register meta for {type.^name} which is not a Plugin" unless type ~~ Plugin;

        my $pname = type.^name;

        # The order of setting meta data for a plugin is:
        # 1. decalaration (plugin Foo after/before/demand)
        # 2. plugin-meta call from within plugin block.
        # 3. %meta hash in plugin block.
        # The priority of data lowers from top to bottom. Thus, keys defained on later stages must not override keys
        # from earlier ones.

        for %meta.keys -> $key {
            next if %!registry<meta>{$pname}{$key}:exists;
            given $key {
                when any <after before demand> {
                    %!registry<meta>{$pname}{$key} ∪= %meta{$key}.list;
                }
                default {
                    %!registry<meta>{$pname}{$key} = %meta{$key};
                }
            }
        }
    }
    multi method plugin-meta ( Str:D $plugin --> Hash:D ) {
        self!deep-clone( %!registry<meta>{ self.short2fqn( :$plugin ) } // {} )
    }
    multi method plugin-meta ( Str:D :$fqn! --> Hash:D ) {
        self!deep-clone( %!registry<meta>{ $fqn } // {} )
    }
    multi method plugin-meta ( Plugin:U $plugin ) { samewith( fqn => $plugin.^name ) }

    proto method register-pluggable (|) {*}
    multi method register-pluggable ( Method:D $method ) {
        # note "REGISTERING METHOD ", $method.name, " from ", $method.package.^name;
        %!registry<pluggables><methods>{ $method.package.^name }{ $method.name } = $method;
        self.register-pluggable( $method.package ); # Implicitly register method's class as pluggable
    }
    multi method register-pluggable ( Mu:U \type ) {
        my $name = type.^name;
        # Avoid name-map rebuild if class is being re-registered
        return if OO::Plugin::Registry::_classes::{ $name }:exists;
        OO::Plugin::Registry::_classes::{ $name } = type;
        %!registry<name-map><classes>:delete;
        %!registry<extended-classes>:delete;
    }

    proto method register-plug (|) {*}
    multi method register-plug ( Method:D $routine,
                                Str:D $class,
                                Str:D $method = '*',
                                PlugPosition :$position = 'around',
                                *%params ) {
        # We could constain routine signature in the parameter but better provide explanatory errors.
        my $signature = $routine.signature;
        die "Invalid signature of the method handler" unless $signature ~~ :(Any: $, *%, *@ );
        my $fparam = $signature.params[1];
        die "Unsupported type constraint '", $fparam.type.WHO, "' for the first parameter"
            unless $fparam.type === Any | MethodHandlerMsg;
        die 'First parameter sigil must be $, not ' ~ $fparam.sigil
            unless $fparam.sigil eq '$';

        my $fqn = $routine.package.^name;
        my \type = self.type( $class );

        my @methods = $method eq '*' ?? type.^methods.map( *.name ) !! [ $method ];
        for @methods -> $class-method {
            die "There is already a handler for $class method $class-method in plugin $fqn"
                if %!registry<plugs><methods>{ $class }{ $class-method }{ $fqn }{ $position }:exists;

            %!registry<plugs><methods>{ $class }{ $class-method }{ $fqn }{ $position } = $routine;
        }
    }
    multi method register-plug ( Method:D $routine,
                                Mu:U \type,
                                Str:D $method = '*',
                                PlugPosition :$position = 'around' ) {
        self.register-pluggable( type );  # Implicitly register the class as pluggable.
        self.register-plug( $routine, type.^name, $method, :$position );
    }

    # plug-class registration block
    multi method register-plug ( Mu:U \plug-class, :@extending where { all .map: * ~~ Str:D  } ) {
        my $plug-name = plug-class.^name;
        # note "$plug-name extends {@extending}";
        given %!registry<plug-classes>{ $*CURRENT-PLUGIN-CLASS.^name }{ $plug-name } {
            $_<type> = plug-class;
            $_<extends> ∪= @extending.map( { self.fqn-class-name: $_ } );
        }
        # note "!!! PLUG CLASSES: ", %!registry<plug-classes>;
        %!registry<extended-classes>:delete; # Must be rebuild later
    }
    multi method register-plug ( Mu:U \plug-class, Mu:U \extending ) {
        self.register-pluggable( extending );
        self.register-plug( plug-class, extending => extending.^name.list );
    }
    multi method register-plug ( Mu:U \plug-class, @extending ) {
        self.register-plug( plug-class, extending => @extending.map: { $_ ~~ Str ?? $_ !! $_.^name } );
    }

    # Record manager-generated classes
    method register-autogen-class ( Str:D $class ) {
        %!registry<inventory><autogen-classs> ∪= $class;
    }

=begin pod
=head3 method pluggable-classes

Returns all classes registered as pluggable. Consider the
L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md#pluggables> with
regard to I<strict> or I<loose> modes of operation of the plugin manger class.
=end pod

    method pluggable-classes ( --> List ) {
        OO::Plugin::Registry::_classes::.keys
    }

=begin pod
=head3 method is-pluggable

=begin item
C<is-pluggable( Mu:U \class )>
C<is-pluggable( Str:D $class-fqn )>

I<True> if class is pluggable.
=end item

=begin item
C<is-pluggable( Str:D $class-fqn, Str:D $method )>

I<True> if method of a class is pluggable.
=end item
=end pod

    proto method is-pluggable (|) {*}
    multi method is-pluggable ( Mu:U \type --> Bool:D ) {
        OO::Plugin::Registry::_classes::{ type.^name }:exists
    }
    multi method is-pluggable ( Str:D $class --> Bool:D ) {
        OO::Plugin::Registry::_classes::{ $class }:exists
    }
    multi method is-pluggable ( Str:D $class, Str:D $method --> Bool:D ) {
        %!registry<pluggables><methods>{ $class }{ $method }:exists
    }

=begin pod
=head3 method type

C<type( Str:D $class-fqn )>

Returns type object for a pluggable class FQN.
=end pod

    method type ( Str:D $class-name --> Mu:U ) {
        OO::Plugin::Registry::_classes::{ $class-name }
    }

=begin pod
=head3 method short2fqn

=item C<short2fqn( Str:D $what, Str:D $name )>
=item C«short2fqn( $what => $name )»

Converts short name of a pluggable class or a plugin into its FQN. C<$what> is either string I<'classes'> or
I<'plugins'>. Returns the C<$name> parameter if the name is not found.
=end pod

    proto method short2fqn (|) {*}
    multi method short2fqn ( Str:D $what where * ~~ 'classes' | 'plugins', Str:D $name --> Str:D ) {
        self!build-name-map;
        %!registry<name-map>{ $what }<short2fqn>{ $name } // $name
    }
    multi method short2fqn ( Str:D :$plugin --> Str:D ) {
        samewith( 'plugins', $plugin );
    }
    multi method short2fqn ( Str:D :$class --> Str:D ) {
        samewith( 'classes', $class );
    }
    # multi method short2fqn ( *%what where *.keys.elems == 1 --> Str:D ) {
    #     for %what.kv -> $what, $name {
    #         return samewith( $what, $name );
    #     }
    # }

=begin pod
=head3 method fqn2short

=item C<fqn2short( Str:D $what, Str:D $name )>
=item C«fqn2short( $what => $name )»

Converts FQN of a pluggable class or a plugin into its short name. C<$what> is either string I<'classes'> or I<'plugins'>.
=end pod

    proto method fqn2short (|) {*}
    multi method fqn2short( Str:D $what, Str:D $name --> Str:D ) {
        self!build-name-map;
        %!registry<name-map>{ $what }<fqn2short>{ $name } // $name
    }
    # multi method fqn2short( *%what where *.keys.elems == 1 --> Str:D ) {
    #     for %what.kv -> $what, $name {
    #         samewith( $what, $name );
    #     }
    # }
    multi method fqn2short ( Str:D :$plugin --> Str:D ) {
        samewith( 'plugins', $plugin )
    }
    multi method fqn2short ( Str:D :$class --> Str:D ) {
        samewith( 'classes', $class )
    }

=begin pod
=head3 method fqn-class-name

=item C<fqn-class-name( Str:D $name )>

Shortcut for C<short2fqn( 'classes', $name )>
=end pod

    method fqn-class-name ( Str:D $name ) {
        self.short2fqn( <classes>, $name )
    }

=begin pod
=head3 method fqn-plugin-name

=item C<fqn-plugin-name( Str:D $name )>

Shortcut for C<short2fqn( 'plugins, $name )>
=end pod

    method fqn-plugin-name ( Str:D $name ) {
        self.short2fqn( <plugins>, $name )
    }

=begin pod
=head3 method has-autogen-class

C<has-autogen-class( Str:D $class-fqn )>

Returns I<True> if C<$class-fqn> is already in the registry of auto-generated classes. Helps in avoiding generation of
duplicate class names.
=end pod

    method has-autogen-class ( Str:D $class --> Bool ) {
        ? %!registry<inventory><autogen-class>{ $class }
    }

    method !deep-clone ( $element ) {
        return $element unless $element.defined;
        $element.deepmap: {
            $_ ~~ Mu:U ?? $_ !! $_.clone
        }
    }

    method !build-name-map {
        sub gen-maps ( @type-list ) {
            # note "   \$";
            my %map;
            %map<short2fqn> = @type-list.map( { .^shortname => .^name } ).Hash;
            %map<fqn2short> = %map<short2fqn>.invert.Hash;
            # note "NAME MAP:", %map;
            %map
        }

        %!registry<name-map><classes> //= gen-maps( OO::Plugin::Registry::_classes::.values );
        %!registry<name-map><plugins> //= gen-maps( self.plugin-types );
    }

    method !build-extended-classes {
        # note ">>> PLUG     CLASSES: ", %!registry<plug-classes>.perl;
        for %!registry<plug-classes>.kv -> $plugin, %plugs {
            for %plugs.kv -> $plug-name, $plug-data  {
                for $plug-data<extends>.keys {
                    # Class name comes from a user and this could end up being in short form.
                    # Plugin name comes in FQN form already because it is taken from a type.
                    # note "    >>> Mapping $_: ", self.fqn-class-name: $_;
                    %!registry<extended-classes>{ self.fqn-class-name: $_ }{ $plugin }.push: $plug-data<type>;
                }
            }
        }
        # note "!!! PLUG     CLASSES: ", %!registry<plug-classes>.perl;
        # note "!!! EXTENDED CLASSES: ", %!registry<extended-classes>.perl;
    }

=begin pod
=head3 method registry

Returns a deep copy of the registry C<Hash>, excluding plugins and classes.

=end pod
    method registry ( --> Hash:D ) {
        self!deep-clone( %!registry )
    }

=begin pod
=head3 method plugs

Returns a deep copy of registered plugs. This branch of registry is currently contains only method handlers but other
types of plugs might be invented in the future.
=end pod

    method plugs ( --> Hash:D ) {
        self!deep-clone( %!registry<plugs> //= {} )
    }

=begin pod
=head3 method methods

Returns a copy of registered method handlers C<Hash>. It's keys are (by nesting level):

=item pluggable class FQN
=item method of the class
=item plugin FQN
=item method call stage: I<before>, I<around>, I<after>

Leafs are handler methods.
=end pod

    method methods ( --> Hash:D ) {
        self!deep-clone( %!registry<plugs><methods> //= {} )
    }

=begin pod
=head3 method pluggables

Returns a copy of pluggables registry. Currently only contains I<methods> key.
=end pod

    method pluggables ( --> Hash:D ) {
        self!deep-clone( %!registry<pluggables> //= {} )
    }

=begin pod
=head3 method extended classes

Returns a copy of the hash of all classes listed in C<for> trait of C<plug-class> declarations. The keys are:

=item class FQN
=item plugin FQN

The leafs are list of C<plug-class> type objects.
=end pod

    method extended-classes ( --> Hash:D ) {
        self!build-extended-classes unless %!registry<extended-classes>:exists;
        self!deep-clone( %!registry<extended-classes> // {} )
    }

=begin pod
=head3 method plug-classes

Returns a copy of the hash of all registered C<plug-classes>. The keys are:

=item plugin FQN
=item C<plug-class> FQN

The leafs are hashes of two keys:

=item I<type> - C<plug-class> type object
=item I<extends> - C<Set> of class names
=end pod

    method plug-classes ( --> Hash:D ) {
        self!deep-clone( %!registry<plug-classes> //= {} )
    }

=begin pod
=head3 method inventory

Returns a copy of inventory hash. It currently only has one key: I<autogen-classs> which is a set of framework-generated
class names.
=end pod
    method inventory ( --> Hash:D ) {
        self!deep-clone( %!registry<inventory> //= {} )
    }
}

=begin pod

=head1 SEE ALSO

L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manual.md>,
L<OO::Plugin|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin.md>
L<OO::Plugin::Manager|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Manager.md>,
L<OO::Plugin::Class|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.904/docs/md/OO/Plugin/Class.md>

=AUTHOR  Vadim Belman <vrurg@cpan.org>

=end pod
