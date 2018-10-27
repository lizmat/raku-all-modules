use CompUnit::Util :load ,:at-unit, :set-symbols,:who,:get-symbols;

{
    # don't want these locally
    multi trait_mod:<is>(Mu:U $node,:$path! is copy) is export {
        $path = $path ~~ Str:D ?? $path !! $node.^name;
        $node.^set-part-of-path($path);
    }
    multi trait_mod:<is>(Mu:U $node,Str:D :$load-from) is export {
        $node.^load-from = $load-from;
    }

    multi trait_mod:<is>(Mu:U $class,:$alias!) is export {
        $class.^aliases.append(|$alias);
    }
}

my role SchemaNode  {
    submethod new(|a) {
        self.load-class.new(|a)
    }
    submethod load-class {
        self.^load-node-class;
    }
    multi submethod matches(Cool:D $test) {
        || self.^shortname.lc ~~ $test.lc
        || self.^load-from ~~ $test
        || self.^aliases.map(*.lc).first($test.lc);
    }
    multi submethod matches(Any:U $_) {
        when .WHAT === self.WHAT { True }
        default { self.matches(.^name)  }
    }
    submethod resolve($test) {
        do if self.matches($test) {
            self;
        } else {
            my $res = self.^children.map(*.resolve($test)).first;
            $res === Any ?? Empty !! $res;
        }
    }

    submethod children(:$all){
        |self.^children, |(self.^children».children(:all) if $all);
    }
}

my class OO::Schema::NodeHOW is Metamodel::ClassHOW {

    has $!load-from; #= CompUnit to load from
    has Str $!part-of-path; #= Wether to add it
    has $!class-cache;      #= cache the loaded class
    has @!children;
    has @!aliases;



    method actually-compose(Mu \type,:@path is copy){
        $!load-from ||= join '::', |@path, type.^shortname;

        @path.push($_) with $!part-of-path;

        my $composed := self.Metamodel::ClassHOW::compose(type);
        set-unit("GLOBALish::OO-SCHEMA::{$composed.^name}",$composed );
        set-unit("EXPORT::DEFAULT::{$composed.^name}",$composed);

        for type.WHO.kv -> $name,$child is raw {
            next unless $child.HOW ~~ OO::Schema::NodeHOW;
            $child.^add_parent(type);
            type.WHO{$name}:delete;
            $child.^add_role(SchemaNode);
            $child.^actually-compose(:@path);
            @!children.push: $child;
        }
        return $composed;
    }

    method load-node-class(Mu \type) {
        return $!class-cache if $!class-cache !=== Any;
        my $cu = load($!load-from);
        my $loaded-GLOBALish = $cu.handle.globalish-package;
        my $sym-name = at-unit($cu,"OO-SCHEMA-ENTRY::{type.^name}")
             or die "couldn't find the schema-node in '$!load-from'";

        return $!class-cache = descend-WHO($loaded-GLOBALish.WHO,$sym-name);
    }

    method aliases(Mu $) { @!aliases }

    method children(Mu $) { @!children }

    method load-from(Mu \type) is rw { $!load-from }

    method set-part-of-path(Mu \type,Str:D $part) {
        $!part-of-path = $part;
    }

    method part-of-path(Mu \type) { $!part-of-path }

    # do nothing on compose - compose the class in backwards order,
    # that's what actually-compose is for
    method compose(Mu \type) { type }

    method new_type(:$name,|a) {
        my \type = self.Metamodel::ClassHOW::new_type(:name($name.split('::')[*-1]));
        type;
    }
}

my role Schema {
    submethod resolve($test) {
        self.^children.map(*.resolve($test)).first(* !=== Any);
    }
    submethod children(:$all) { flat self.^children,(|self.^children».children(:all) if $all) };
}


my class OO::Schema::SchemaHOW is OO::Schema::NodeHOW {

    method compose(Mu \type) {
        type.^set-part-of-path(type.^name) unless type.^part-of-path;
        type.^add_role(Schema);
        type.^actually-compose();
    }

    method load-node-class(Mu \type) { Any }
}


multi trait_mod:<is>(Mu:U $class,:$schema-node!) {

    my $schema-WHO = get-unit('GLOBALish::OO-SCHEMA').WHO;
    my $node-name = $schema-node ~~ Str ?? $schema-node !! $class.^shortname;

    if (my $node = $schema-WHO{$node-name}) !=== Any {

        set-unit("OO-SCHEMA-ENTRY::{$node-name}",$class.^name);

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
    set-unit('EXPORT::node::&trait_mod:<is>', &trait_mod:<is>);
    {};
}

package EXPORTHOW {
    package DECLARE {
        constant schema = OO::Schema::SchemaHOW;
        constant node = OO::Schema::NodeHOW;
    }
}
