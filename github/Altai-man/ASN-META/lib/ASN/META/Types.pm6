class ASNType {
    has Str $.name;
    has Str $.base-type;
    has $.type is rw;
    has $.parent;
    has $.is-recursive = False;
}

class TypePool {
    has ASNType @.types;

    method has(Str $name --> ASNType) {
        return Nil if $name.chars == 0;
        @!types.grep(*.name eq $name)[*-1];
    }

    method add(ASNType $type) {
        return $type if $type.name.chars == 0;
        @!types.push: $type;
        $type;
    }

    method export {
        @!types.map({ .name, .type}).flat.Map;
    }
}
