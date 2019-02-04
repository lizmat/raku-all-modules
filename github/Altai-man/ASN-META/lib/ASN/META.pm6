use MONKEY-SEE-NO-EVAL;
use nqp;
use ASN::Types;
use ASN::Grammar;

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

my $complex-types = set 'ENUMERATED', 'SEQUENCE', 'SEQUENCE OF', 'SET', 'CHOICE', 'SET OF';

my %simple-builtin-types = 'OCTET STRING' => Str,
        UTF8String => Str,
        BOOLEAN => Bool,
        INTEGER => Int,
        NULL => ASN-Null;

multi sub compile-complex-builtin('ENUMERATED', $type, %POOL, $symbol-name) {
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

    my $new-enum = Metamodel::EnumHOW.new_type(name => $symbol-name, base_type => Int);
    $new-enum.^compose_repr;
    $new-enum = $new-enum but Enumeration;
    my %enum-values = (create_enum_value($new-enum, .key, .value) for $type.params<defs><>);
    $new-enum.^compose;
    %POOL{.key} = ('ENUMERATED VALUE', .value) for %enum-values;
    %POOL{$symbol-name} = ('ENUMERATED', $new-enum);
}

multi sub compile-complex-builtin('SEQUENCE', $type, %POOL, $symbol-name) {
    my $fields = $type.params<fields>;
    my $new-type = Metamodel::ClassHOW.new_type(name => $symbol-name);

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
        # A type that will be assigned to field
        my $field-name = $field.name;
        my $field-type-name = $field.type;
        my $attribute-type = compile-type($field, %POOL,
                $field-type-name (elem) $builtin-types ??
                        $field-name !!
                $field-type-name);

        # Create attribute's name and use it with type to create the attribute itself
        my $name = '$!' ~ S:g/(<[a..z]>)(<[A..Z]>)/$0-$1/.lc with $field-name;
        my $attr = Attribute.new(:$name, type => $attribute-type[1], package => $new-type, :has_accessor);

        # Patch Str attribute with necessary roles
        if $attribute-type[1] === Positional[Str] {
            $attr does ASN::Types::OctetString;
        }

        if $attribute-type[1] ~~ Str {
            given $attribute-type[0] {
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
    %POOL{$symbol-name} = ('SEQUENCE', $new-type);
}

multi sub compile-complex-builtin('SEQUENCE OF', $type, %POOL, $symbol-name) {
    my $of-type = $type.params<of>;

    with $type.params<tag> {
        if .class eq 'APPLICATION' {
            my $new-type = Metamodel::ClassHOW.new_type(name => $symbol-name);
            my $tag-value = .value;
            $new-type.^add_method('ASN-tag-value', method { $tag-value });
            if $of-type.type (elem) $builtin-types {
                $new-type.^add_role(Positional[%simple-builtin-types{$of-type.type}]);
            } else {
                $new-type.^add_role(Positional[compile-type($of-type, %POOL, $of-type.type)[1]]);
            }
            $new-type.^compose;
            return %POOL{$symbol-name} = ('SEQUENCE OF', $new-type);
        }
    }

    if $of-type.type (elem) $builtin-types {
        if $of-type.type (elem) $complex-types {
            my $bottom-type = compile-type($of-type, %POOL, $symbol-name ~ 'Bottom');
            return %POOL{$symbol-name} = ('SEQUENCE OF', Positional[$bottom-type[1]]);
        }
        return %POOL{$symbol-name} = ('SEQUENCE OF', Positional[%simple-builtin-types{$of-type.type}]);
    } else {
        return %POOL{$symbol-name} = ('SEQUENCE OF', Positional[compile-type($of-type, %POOL, $of-type.type)[1]]);
    }
}

multi sub compile-complex-builtin('SET OF', $type, %POOL, $symbol-name) {
    my $of-type = $type.params<of>;
    my $compile-type = compile-type($of-type, %POOL, $of-type.type);
    if ($compile-type[1] === Str) {
        if $compile-type[0] eq 'OCTET STRING' {
            $compile-type = ($compile-type[0], ASN::Types::OctetString);
        }
    }
    return %POOL{$symbol-name} = ('SET OF', ASNSetOf[$compile-type[1]]);
}

multi sub compile-complex-builtin('CHOICE', $type, %POOL, $symbol-name) {
    my $new-type := Metamodel::ClassHOW.new_type(name => $symbol-name);
    my %choices;
    for $type.params<choices>.kv -> $key, $value {
        my ($tag, $real-value);
        if $value ~~ Pair {
            $tag = $value.key.value;
            $real-value = $value.value;
        } else {
            $real-value = $value;
        }
        my $compiled-option = compile-type(ASN::RawType.new(name => '', type => $real-value), %POOL, $key);

        if $compiled-option[1] === Str {
            if $compiled-option[0] eq 'OCTET STRING' {
                $compiled-option = ($compiled-option[0], ASN::Types::OctetString);
            }
        }

        %choices{$key} = $tag.defined ?? ($tag => $compiled-option[1]) !! $compiled-option[1];
        %POOL{$value} = $compiled-option;
    }
    my &method = method { %choices };
    $new-type.^add_method("ASN-choice", &method);
    $new-type.^add_role(ASNChoice);
    $new-type.^compose;
    %POOL{$symbol-name} = ('CHOICE', $new-type);
    ('CHOICE', $new-type);
}

sub compile-simple-builtin($type, %POOL, $symbol-name) {
    # Sets a pair like ElementSize = ('OCTET STRING', Str);

    my $value-to-bind;
    with $type.params<tag> {
        #| In this case, we should not "flat" this symbol
        #| to built-in Perl 6 type, but rather create a wrapper
        #| with ASN-tag-value method implemented
        if .class eq 'APPLICATION' {
            my $new-type = Metamodel::ClassHOW.new_type(name => $symbol-name);
            my $tag-value = .value;
            $new-type.^add_method('ASN-tag-value', method { $tag-value });
            if $type.type eq 'OCTET STRING' {
                # FIXME A hack
                $new-type.^add_role(ASN::Types::OctetString);
            } else {
                $new-type.^add_parent(%simple-builtin-types{$type.type});
            }
            $new-type.^compose;
            $value-to-bind = ($type.type, $new-type);
        }
    }

    $value-to-bind //= ($type.type, %simple-builtin-types{$type.type});
    %POOL{$symbol-name} = $value-to-bind;
}

sub compile-builtin-type($type, %POOL, $symbol-name) {
    #| At this level, type isn't in a cache and has to be compiled
    #| This subroutine compiles a case where global or local name
    #| has to be associated with native ASN type
    #| which means simple linking for non-complex types and create->populate->link for complex ones

    given $type.type -> $type-name {
        if $type-name (elem) $complex-types {
            return compile-complex-builtin($type-name, $type, %POOL, $symbol-name);
        } else {
            return compile-simple-builtin($type, %POOL, $symbol-name);
        }
    }
}

sub compile-type($type, %POOL, $asn-name) {
    #| Number of cases is possible here
    #| * Type is already compiled
    #| * Type must be handled using a plugin
    #| * Type has to be created and added to cache

    #| We always title-case names:
    #| * Top-level names are being left as they are to be suitable for Perl 6 type
    #| * Inner-declared names are based on a field name, so have to be title-case to match the style
    my $symbol-name = $asn-name.tc;

    # Return if cached
    return $_ with %POOL{$symbol-name};

    #| Try it we have a custom type implementation
    with $*PLUGIN -> $plugin-code {
        my $custom-type = EVAL $plugin-code;
        if $custom-type.defined {
            return %POOL{$symbol-name} = $custom-type;
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
        return compile-builtin-type($type, %POOL, $symbol-name);
    } else {
        # Check if custom is among types and reduce a link
        with $*TYPES.grep($type.type eq *.name).first {
            # Make a union of outer and inner type params
            my $params-union = (flat $type.params, .type.params).Hash;
            my $base-type = ASN::RawType.new(name => $asn-name, type => .type.type, params => $params-union);
            return compile-type($base-type, %POOL, $asn-name);
        } else {
            die "Encountered unknown type $type.type()";
        }
    }
}

sub compile-types(ASN::Module $ASN, %POOL) {
    my $*TYPES = $ASN.types.grep(* ~~ ASN::TypeAssignment).List;
    for @$*TYPES {
        compile-type(.type, %POOL, .name) unless %POOL{.name}:exists;
    }
}

sub EXPORT(*@params) {
    my %POOL;
    my $keys = @params.Map;
    my $ASN = parse-ASN slurp $keys<file>;
    my $*PLUGIN = slurp($_) with $keys<plugin>;
    compile-types($_, %POOL) with $ASN;
    %POOL.map({.key => .value[1]}).Map;
}
