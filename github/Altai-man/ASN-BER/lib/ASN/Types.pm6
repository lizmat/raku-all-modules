enum TagModes is export <Implicit Explicit Automatic>;

enum TagClass is export <Universal Application Context Private>;

role ASNSequence {
    method ASN-order {...}
}

role ASNSequenceOf[$type] {
    has $.seq;

    method type { $type }
}

role ASNSet {
}

role ASNSetOf[$type] is Set {
    method type { $type }
}

role ASNChoice {
    has $.choice-value;

    method ASN-choice() {...}
    method ASN-value() { $!choice-value }

    method key() { $!choice-value.key }
    method value() { $!choice-value.value }

    method new($choice-value) { $?CLASS.bless(:$choice-value) }
}

class ASN-Null {}

# String traits
role ASN::StringWrapper {
    has Str $.value;

    method new(Str $value) { self.bless(:$value) }
}

role ASN::Types::UTF8String does ASN::StringWrapper {}

multi trait_mod:<is>(Attribute $attr, :$UTF8String) is export {
    $attr does ASN::Types::UTF8String;
}

role ASN::Types::OctetString does ASN::StringWrapper {}

multi trait_mod:<is>(Attribute $attr, :$OctetString) is export {
    $attr does ASN::Types::OctetString;
}

# OPTIONAL
role Optional {}

multi trait_mod:<is>(Attribute $attr, :$optional) is export {
    $attr does Optional;
}

# DEFAULT
role DefaultValue[:$default-value] {
    method default-value() { $default-value }
}

multi trait_mod:<is>(Attribute $attr, :$default-value) is export {
    $attr does DefaultValue[:$default-value];
    trait_mod:<is>($attr, :default($default-value));
}

# [0] like tags
role CustomTagged[:$tag] {
    method tag(--> Int) { $tag }
}

multi trait_mod:<is>(Attribute $attr, :$tagged) is export {
    $attr does CustomTagged[tag => $tagged];
}

class ASNValue {
    has $.tag is rw;
    has $.type;
    has $.value;
    has $.default;
}

our $primitive-type is export =
        Int | Str | Bool |
        ASN::Types::UTF8String | ASN::Types::OctetString | ASN-Null;
