use MONKEY-SEE-NO-EVAL;
use nqp;
use ASN::Types;
use ASN::Grammar;
use ASN::META::Types;

my $builtin-types = set
        'BOOLEAN', 'INTEGER',
        'BIT STRING', 'OCTET STRING',
        'NULL', 'OBJECT IDENTIFIER',
        'Object Descriptor', 'EXTERNAL',
        'REAL', 'ENUMERATED',
        'EMBEDDED PDV', 'UTF8String',
        'RELATIVE OID', 'SEQUENCE',
        'SEQUENCE OF', 'SET', 'SET OF',
        'NumericString', 'PrintableString',
        'T61String', 'VideotexString',
        'IA5String', 'UTFTime',
        'GeneralizedTime', 'GraphicString',
        'VisibleString', 'GeneralString',
        'UniversalString', 'CHARATER STRING',
        'BMPString', 'CHOICE';

my $complex-types = set 'ENUMERATED', 'SEQUENCE', 'SEQUENCE OF', 'SET', 'SET OF', 'CHOICE';

my %simple-builtin-types = 'OCTET STRING' => Str,
        UTF8String => Str,
        BOOLEAN => Bool,
        INTEGER => Int,
        NULL => ASN-Null;

my class RecursionStub {
    has $.type;
}

my sub check-recursion(ASN::RawType $type, Str $name) {
    with @*TYPE-STACK.grep(*.key eq $type.type).first {
        # We have started to recurse!
        # Let's replace the type with a stub
        # and get a parent we have to update later
        # to fix difference between stub and (later) non-stub types
        my @parent-list = @*TYPE-STACK;
        return ASNType.new(:$name, type => RecursionStub.new(type => $_), :@parent-list);
    }
    else {
        unless $name (elem) $builtin-types {
            with $*TYPES.grep({.name eq $name}).first {
                @*TYPE-STACK.push: $name.tc => $_.type;
            } else {
                @*TYPE-STACK.push: $name.tc => $type;
            }
        }
        my $updated-type = compile-type($type, $name (elem) $builtin-types ?? '' !! $name);
        unless $name (elem) $builtin-types {
            @*TYPE-STACK.pop;
        }
        return $updated-type;
    }
}

my sub resolve-recursion(ASNType $type, Str $name) {
    # We need to re-do only recursive types
    if $type.is-recursive {
        my $def = $*TYPES.grep(*.name eq $name).first;
        compile-complex-builtin('CHOICE', $def.type, $name).type.ASN-choice;
        for @($type.parent-list.reverse) -> $parent {
            with $*POOL.has($parent.key) {
                compile-complex-builtin(.base-type, $parent.value, $parent.key);
            }
        }
    }
}

multi sub compile-complex-builtin('ENUMERATED', $type, $name) {
    # FIXME This is kind of a cheating
    # which uses imitation of what Rakudo does using nqp.
    # Rewriting using real Perl 6 is very welcome.
    sub create_enum_value($enum_type_obj, $key, $value) {
        state $index = 0;
        # Create directly.
        my $val := nqp::rebless(nqp::clone($value), $enum_type_obj);
        nqp::bindattr($val, $enum_type_obj, '$!key', $key);
        nqp::bindattr($val, $enum_type_obj, '$!value', $value);
        nqp::bindattr_i($val, $enum_type_obj, '$!index', $index++);

        # Add to meta-object.
        $enum_type_obj.^add_enum_value($val);

        # Result is the value.
        $key => $val
    }

    my $new-enum = Metamodel::EnumHOW.new_type(:$name, base_type => Int);
    $new-enum.^compose_repr;
    $new-enum = $new-enum but Enumeration;
    my %enum-values = (create_enum_value($new-enum, .key, .value) for $type.params<defs><>);
    $new-enum.^compose;
    $*POOL.add(ASNType.new(name => .key, base-type => 'ENUM VALUE', type => .value)) for %enum-values;
    $*POOL.add(ASNType.new(:$name, base-type => 'ENUMERATED', type => $new-enum));
}

multi sub compile-complex-builtin('SEQUENCE', $type, $name) {
    my $fields = $type.params<fields>;
    my $new-type = Metamodel::ClassHOW.new_type(:$name);

    # if has an application tag, apply it
    with $type.params<tag> {
        if .class eq 'APPLICATION' {
            my $tag-value = .value;
            $new-type.^add_method('ASN-tag-value', method {
                $tag-value
            });
        }
    }

    my @ASN-order = (('$!' ~ S:g/(<[a..z]>)(<[A..Z]>)/$0-$1/.lc) for |$fields>>.name).Array;
    $new-type.^add_method('ASN-order', method { @ASN-order });

    for @$fields -> $field {
        my $field-name = $field.name;
        my $field-type-name = $field.type.type;

        # A type that will be assigned to field
        my $attribute-type = check-recursion($field.type,
                $field-type-name (elem) $builtin-types ??
                $field-name !!
                $field-type-name);

        # Create attribute's name and use it with type to create the attribute itself
        my $name = '$!' ~ S:g/(<[a..z]>)(<[A..Z]>)/$0-$1/.lc with $field-name;
        my $attr = Attribute.new(:$name, type => $attribute-type.type, package => $new-type, :has_accessor);

        # Patch Str attribute with necessary roles
        if $attribute-type.type === Positional[Str] {
            $attr does ASN::Types::OctetString;
        }

        if $attribute-type.type ~~ Str {
            given $attribute-type.base-type {
                when 'OCTET STRING' {
                    $attr does ASN::Types::OctetString;
                }
                when 'UTF8String' {
                    $attr does ASN::Types::UTF8String;
                }
                default {
                    die "Other type of String is encountered: $_";
                }
            }
        }
        # Apply DEFAULT or OPTIONAL
        with $field.params<optional> {
            $attr does Optional;
        } orwith $field.params<default> {
            my $default-value = $_ eq 'FALSE' ?? False !! $_;
            trait_mod:<is>($attr, :default($default-value));
            $attr does DefaultValue[:$default-value];
        }
        # Apply possible context-specific tag
        with $field.params<tag> {
            if .class eq 'CONTEXT-SPECIFIC' {
                $attr does CustomTagged[tag => .value];
            }
        }
        $new-type.^add_attribute($attr);
    }

    $new-type.^add_role(ASNSequence);
    $new-type.^compose;

    $*POOL.add(ASNType.new(
            :$name, base-type => 'SEQUENCE',
            type => $new-type));
}

multi sub compile-complex-builtin('SEQUENCE OF', $type, $name) {
    my $of-type-ref = $type.params<of>;

    with $type.params<tag> {
        if .class eq 'APPLICATION' {
            my $new-type = Metamodel::ClassHOW.new_type(:$name);
            my $tag-value = .value;
            $new-type.^add_method('ASN-tag-value', method { $tag-value });
            if $of-type-ref.type (elem) $builtin-types {
                $new-type.^add_role(Positional[%simple-builtin-types{$of-type-ref.type}]);
            } else {
                $new-type.^add_role(Positional[check-recursion($of-type-ref, $of-type-ref.type).type]);
            }
            $new-type.^compose;
            return $*POOL.add(ASNType.new(:$name, base-type => 'SEQUENCE OF', type => $new-type));
        }
    }

    my $of-type;

    if $of-type-ref.type (elem) $builtin-types {
        if $of-type-ref.type (elem) $complex-types {
            $of-type = check-recursion($of-type-ref, $name ~ 'Bottom').type;
        }
        else {
            $of-type = %simple-builtin-types{$of-type-ref.type};
        }
    } else {
        $of-type = check-recursion($of-type-ref, $of-type-ref.type).type;
    }
    $*POOL.add(ASNType.new(:$name, base-type => 'SEQUENCE OF', type => Positional[$of-type]));
}

multi sub compile-complex-builtin('SET OF', $type, $name) {
    my $of-type-ref = $type.params<of>;
    my $set-parameter = check-recursion($of-type-ref, $of-type-ref.type).clone;
    if ($set-parameter.type === Str) {
        if $set-parameter.base-type eq 'OCTET STRING' {
            $set-parameter.type = ASN::Types::OctetString;
        }
    }
    $*POOL.add(ASNType.new(
            :$name, base-type => 'SET OF',
            type => ASNSetOf[$set-parameter.type]));
}

multi sub compile-complex-builtin('CHOICE', $type, $name) {
    my $new-type := Metamodel::ClassHOW.new_type(:$name);
    my %choices;
    my @parent-list;
    for $type.params<choices>.kv -> $key, $value {
        my ($tag, $real-value);
        if $value ~~ Pair {
            $tag = $value.key.value;
            $real-value = $value.value;
        } else {
            $real-value = $value;
        }
        # We can get a Str name if it is non-complex type and
        # RawType if it is a complex type that was generated.
        if $real-value !~~ ASN::RawType {
            $real-value = ASN::RawType.new(name => $real-value, type => $real-value);
        }

        my $compiled-option = check-recursion($real-value, $real-value.type).clone;
        if $compiled-option.type ~~ RecursionStub {
            @parent-list = $compiled-option.parent-list;
        };
        if $compiled-option.type === Str {
            if $compiled-option.base-type eq 'OCTET STRING' {
                $compiled-option.type = ASN::Types::OctetString;
            }
        }
        %choices{$key} = $tag.defined ?? ($tag => $compiled-option.type) !! $compiled-option.type;
    }
    my &method = method { %choices };
    $new-type.^add_method("ASN-choice", &method);
    $new-type.^add_role(ASNChoice);
    $new-type.^compose;
    my $is-recursive = @parent-list.elems != 0;
    $*POOL.add(ASNType.new(:$name, base-type => 'CHOICE', type => $new-type, :@parent-list, :$is-recursive));
}

sub compile-simple-builtin($type, $name) {
    my $value-to-bind;
    with $type.params<tag> {
        #| In this case, we should not "flat" this symbol
        #| to built-in Perl 6 type, but rather create a wrapper
        #| with ASN-tag-value method implemented
        if .class eq 'APPLICATION' {
            my $new-type = Metamodel::ClassHOW.new_type(:$name);
            my $tag-value = .value;
            $new-type.^add_method('ASN-tag-value', method { $tag-value });
            if $type.type eq 'OCTET STRING' {
                # FIXME A hack
                $new-type.^add_role(ASN::Types::OctetString);
            } else {
                $new-type.^add_parent(%simple-builtin-types{$type.type});
            }
            $new-type.^compose;
            $value-to-bind = ASNType.new(:$name, base-type => $type.type, type => $new-type);
        }
    }

    $value-to-bind //= ASNType.new(
            :$name, base-type => $type.type,
            type => %simple-builtin-types{$type.type});
    $*POOL.add($value-to-bind);
}

sub compile-builtin-type($type, $symbol-name) {
    #| At this level, type isn't in a cache and has to be compiled
    #| This subroutine compiles a case where global or local name
    #| has to be associated with native ASN type
    #| which means simple linking for non-complex types and create->populate->link for complex ones

    given $type.type -> $type-name {
        if $type-name (elem) $complex-types {
            return compile-complex-builtin($type-name, $type, $symbol-name);
        } else {
            return compile-simple-builtin($type, $symbol-name);
        }
    }
}

sub compile-type($type, $asn-name) {
    #| Number of cases is possible here
    #| * Type is already compiled
    #| * Type must be handled using a plugin
    #| * Type has to be created and added to cache

    #| We always title-case names:
    #| * Top-level names are being left as they are to be suitable for Perl 6 type
    #| * Inner-declared names are based on a field name, so have to be title-case to match the style
    my $symbol-name = ($asn-name // '').tc;

    # Return if cached
    with $*POOL.has($symbol-name) {
        return $_;
    }
    orwith $type.name {
        return $_ with $*POOL.has($_);
    }

    #| Try if we have a custom type implementation
    with $*PLUGIN {
        with EVAL $_ {
            return $*POOL.add($_);
        }
    }

    #| If it is not compiled, we have
    #| * Type = Custom | Native
    #| * bind: CustomName -> NativeType (1)
    #| * bind: CustomName -> CustomName (2)
    #| * bind: (field) -> Type (3)
    #| 1 demands us to simply return native type
    #| 2 and 3 demand us to either compile or get a type from cache and create type chain links
    if $type.type (elem) $builtin-types {
        return compile-builtin-type($type, $symbol-name);
    } else {
        # Check if custom is among types and reduce a link
        with $*TYPES.grep($type.type eq *.name).first {
            # Make a union of outer and inner type params
            my $params-union = (flat $type.params, .type.params).Hash;
            my $base-type = ASN::RawType.new(name => $asn-name, type => .type.type, params => $params-union);
            return compile-type($base-type, $asn-name);
        } else {
            die "Encountered unknown type $type.type()";
        }
    }
}

sub compile-types(ASN::Module $ASN) {
    my $*TYPES = $ASN.types.grep(* ~~ ASN::TypeAssignment).List;
    my @*FIRST-PASS-ATTRS;
    my @*TYPE-STACK;
    $*POOL.export;
    for @$*TYPES {
        @*TYPE-STACK.push: .name.tc => .type;
        # Compile a type and resolve its possibly recursive parts
        my $first-pass-type = compile-type(.type, .name);
        @*TYPE-STACK = ();
        resolve-recursion($first-pass-type, .name);
    }
}

sub EXPORT(*@params) {
    my $keys = @params.Map;
    my $ASN = parse-ASN slurp $keys<file>;
    my $*PLUGIN = slurp($_) with $keys<plugin>;
    my $*POOL = TypePool.new;
    compile-types($_) with $ASN;
    $*POOL.export.Map;
}
