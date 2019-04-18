use v6.d;
unit module OO::Plugin::Class;

=begin pod

=head1 NAME

OO::Plugin::Class - collection for service classes.

=head1 EXPORTS

=head2 Classes
=end pod

=begin pod

=head3 class C<PluginMessage>

This class is used to provide a plugin with information about the current call. In its pure form the plugin manager is
using objects of this class to communicate with callbacks.

=end pod
class PluginMessage is export {
    #| Parameters the method has been called with
    has Capture:D $.params is rw is required;
    #| Data only available to a single plugin. This data would exists strictly within one execution chain and won't be
    #| exposed to the code from other plugins.
    has $.private is rw;
    #| Data shared among all the plugins. This attribute is similar to .private except this data is shared; i.e. what is
    #| set by one plugin can be read or changed by others.
    has %.shared;
    # Plugin-suggested return value
    has $!rc;
    # Indicates that $!rc was set.
    has Bool:D $!rc-set = False;

    #| This method sets the suggested return value for the current execution chain.
    method set-rc ( $!rc is copy --> Nil ) {
        $!rc-set = True;
    }

    #| Reset the suggested return value.
    method reset-rc ( --> Nil ) {
        $!rc = Nil;
        $!rc-set = False;
    }

    #| Returns _True_ if the suggested return value has been set.
    method has-rc ( --> Bool ) { $!rc-set }

    #| Suggested return value
    method rc { $!rc }
}

=begin pod
=head3 class C<MethodHandlerMsg>

Inherits from C<PluginMessage>. Used to provide information for method handlers.

=end pod
class MethodHandlerMsg is PluginMessage is export {
    #| Instance of the object the original method has been called upon.
    has Any:D $.object is required;
    #| Name of the method being called.
    has Str:D $.method is required;
    #| Stage of method call. Can be one of three strings: _before_, _around_, _after_.
    has Str:D $.stage is rw where * ~~ any <before around after>;
}

=begin pod

=head3 class <Plugin>

The base class of all plugins.

=end pod
class Plugin:auth<CPAN:VRURG>:ver<0.0.0>:api<0> is export {
    #| The plugin manager object which created this plugin instance.
    has $.plugin-manager is required where { is-plug-mgr $_ };
    #| Plugin's fully qualified name.
    has Str:D $.name is required;
    #| Plugin's short name.
    has Str:D $.short-name is required;

    #| Event handler.
    proto method on-event ( Str:D $name, | ) {*}
    # multi method on-event ( Str:D $n, | ) { note "unhandled event $n" }

    #| Callback handler.
    proto method on-callback ( Str:D $cb-name, PluginMessage:D $msg, | ) {*}
}

sub is-plug-mgr ( $obj ) {
    require ::('OO::Plugin::Manager');
    $obj ~~ ::('OO::Plugin::Manager')
}

=begin pod

=head1 SEE Also

L<OO::Plugin::Manual|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manual.md>,
L<OO::Plugin::Manager|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin/Manager.md>,
L<OO::Plugin::Class|https://github.com/vrurg/Perl6-OO-Plugin/blob/v0.0.906/docs/md/OO/Plugin.md>

=AUTHOR  Vadim Belman <vrurg@cpan.org>

=end pod
