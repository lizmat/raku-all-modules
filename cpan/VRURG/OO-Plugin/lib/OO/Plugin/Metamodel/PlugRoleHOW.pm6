use v6.d;
class OO::Plugin::Metamodel::PlugRoleHOW is Metamodel::ParametricRoleHOW {
    use OO::Plugin::Registry;
    use OO::Plugin::Metamodel::PluginHOW;

    has $!oo-plugin;

    method new_type ( :$name, |params ) {
        die "missing 'for' declaration for plug-class $name" unless @*PLUG-CLASS-EXTENDING;
        my $type := self.Metamodel::ParametricRoleHOW::new_type( :$name, |params );
        Plugin::Registry.instance.register-plug( $type, @*PLUG-CLASS-EXTENDING );
        $type
    }

    method compose ( Mu:U \type, :$compiler_services ) {
        my \t = callsame;
        self.set_oo_plugin( type );
        t
    }

    method set_oo_plugin ( $obj ) {
        $!oo-plugin := $*CURRENT-PLUGIN-CLASS;
    }

    method plugin ( Mu:U \type ) {
        $!oo-plugin
    }
}
