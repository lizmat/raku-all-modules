class ASNType {
    has Str $.name;
    has Str $.base-type;
    has $.type is rw;
    has @.parent-list;
    has $.is-recursive = False;
}

class TypePool {
    has ASNType %!types;

    method has(Str $name --> ASNType) {
        return Nil if $name.chars == 0;
        %!types{$name}
    }

    method add(ASNType $type) {
        return $type if $type.name.chars == 0;
        %!types{$type.name} = $type;
        $type;
    }

    method export {
        %!types.map({ .key, .value.type }).flat.Map;
    }
}
