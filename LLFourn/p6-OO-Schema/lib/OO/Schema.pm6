use CompUnit::Util :load ,:at-unit, :set-symbols,:descend-WHO,:get-symbols;

{
    # don't want these locally
    multi trait_mod:<is>(Mu:U $node,:$path! is copy) is export {
        $path = $path ~~ Str:D ?? $path !! $node.^name;
        $node.^set-part-of-path($path);
    }
    multi trait_mod:<is>(Mu:U $node,Str:D :$load-from) is export {
        $node.^load-from = $load-from;
    }
}

my submethod node-new(|) {
    die "you cannot instantiate schema node: '{self.^name}'";
}

my submethod load-class {
    self.^load-node-class;
}

my class OO::Schema::NodeHOW is Metamodel::ClassHOW {

    has $!load-from; #= CompUnit to load from
    has Str $!part-of-path;

    method actually-compose(Mu \type,:@path is copy){
        $!load-from ||= join '::', |@path, type.^shortname;

        @path.push($_) with $!part-of-path;

        my $composed := self.Metamodel::ClassHOW::compose(type);
        set-globalish({ "OO-SCHEMA::{$composed.^name}" => $composed });
        set-export({$composed.^name => $composed});

        for type.WHO.kv -> $name,$child is raw {
            next unless $child.HOW ~~ OO::Schema::NodeHOW;
            $child.^add_parent(type);
            type.WHO{$name}:delete;
            $child.^actually-compose(:@path);
        }
        return $composed;
    }

    method load-node-class(Mu \type) {
        my $cu = load($!load-from);
        my $loaded-GLOBALish = $cu.handle.globalish-package;
        my $sym-name = at-unit($cu,"OO-SCHEMA-ENTRY::{type.^name}")
             or die "couldn't find the schema-node in '$!load-from'";

        return descend-WHO($loaded-GLOBALish.WHO,$sym-name);
    }

    method load-from(Mu \type) is rw { $!load-from }

    method set-part-of-path(Mu \type,Str:D $part) {
        $!part-of-path = $part;
    }

    method part-of-path(Mu \type) { $!part-of-path }

    method compose(Mu \type) { type }

    method new_type(:$name,|a) {
        my \type = self.Metamodel::ClassHOW::new_type(:name($name.split('::')[*-1]));
        type.^add_method('new',&node-new);
        type.^add_method('load-class',&load-class);
        type;
    }
}


my class OO::Schema::SchemaHOW is OO::Schema::NodeHOW {

    method compose(Mu \type) {
        type.^set-part-of-path(type.^name) unless type.^part-of-path;
        type.^actually-compose();
    }

    method load-node-class(Mu \type) { Any }
}


multi trait_mod:<is>(Mu:U $class,:$schema-node!) {

    my $schema-WHO = get-globalish('OO-SCHEMA').WHO;
    my $node-name = $schema-node ~~ Str ?? $schema-node !! $class.^shortname;

    if (my $node = $schema-WHO{$node-name}) !=== Any {

        set-unit(%("OO-SCHEMA-ENTRY::{$node-name}" => $class.^name));

        for $node.^parents(:local(1)) {
            my $parent = .^load-node-class;
            if $parent !=== Any {
                $class.^add_parent($parent);
            }
        }

        $class.^add_parent($node);
    } else {
        die "couldn't find {$node-name} in {$schema-WHO.gist}";
    }
}

sub EXPORT {
    set-export(%('&trait_mod:<is>' => &trait_mod:<is>),'node');
    {};
}

package EXPORTHOW {
    package DECLARE {
        constant schema = OO::Schema::SchemaHOW;
        constant node = OO::Schema::NodeHOW;
    }
}
