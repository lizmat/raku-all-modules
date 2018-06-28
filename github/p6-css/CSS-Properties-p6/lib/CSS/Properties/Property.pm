use v6;

use CSS::Module;

class CSS::Properties::Property {

    has Str $.name;
    has Bool $.inherit;
    has Str $.synopsis;
    has Str $.default;
    has $.default-ast;
    has Str @.children;
    has Str $.edge;
    has Str @.edges;

    method box { False }

    multi method build( Str :$!name!, :$!synopsis!, Array :$default, :$!inherit = False, Bool :$box = False, :@!children, :$!edge = Str, :@!edges ) {
        die "$!name css property should be composed via CSS::Properties::Edges"
            if $box && !self.box;
        # second entry is the compiled default value
         with $default {
             $!default = .[0];
             $!default-ast = [ .[1].map: { $_ ~~ Hash && .keys == 1 ?? .pairs[0] !! $_ } ];
         }
    }

    multi method build(Str :$name!, CSS::Module :$module = (require CSS::Module::CSS3).module) is default {
        my Hash \metadata = $module.property-metadata;
        die "unknown property: $name"
            unless metadata{$name}:exists;

        die "malformed metadata for property $name"
            unless metadata{$name}<synopsis>:exists;

        self.build( :$name, |metadata{$name} );
    }

    submethod BUILD(|c) {
        self.build(|c)
    }

}
