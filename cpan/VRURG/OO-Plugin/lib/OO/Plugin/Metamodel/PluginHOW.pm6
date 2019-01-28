use v6.d;
unit class OO::Plugin::Metamodel::PluginHOW is Metamodel::ClassHOW;
use OO::Plugin::Class;
use OO::Plugin::Registry;

method new_type ( :$name, |params ) {
    # In hope that compilation doesn't take advantage of multi-threading...
    $*CURRENT-PLUGIN-CLASS := callsame;
    $*CURRENT-PLUGIN-CLASS.^add_parent( Plugin );
    $*CURRENT-PLUGIN-CLASS
}

method compose ( Mu \type, :$compiler_services ) {
    my \ptype = callsame;
    my $registry := Plugin::Registry.instance;
    $registry.register-plugin( type );
    $registry.plugin-meta( %*CURRENT-PLUGIN-META, ptype );
    ptype
}
