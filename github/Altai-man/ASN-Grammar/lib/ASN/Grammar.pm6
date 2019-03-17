# A quickly created grammar made to parse a single `ldap.asn` file
# though it possibly can parse a bigger scope of ASN.1 declarations

grammar ASN::Grammar {
    # Basic part
    token TOP { <module>+ }
    rule module { \n* <id-string> \n* 'DEFINITIONS' <default-tag> '::=' 'BEGIN' \n* <body>? \n* 'END' \n* }
    rule default-tag { <( <explicit-or-implicit-tag> )> 'TAGS' }
    token body { [ <type-assignment> || <value-assignment> ]+ }

    # Type part
    rule type-assignment { <id-string> '::=' <type> }
    token type { <builtin> || <id-string> }
    proto token builtin {*}

    token builtin:sym<null> { 'NULL' }
    token builtin:sym<boolean> { 'BOOLEAN' }
    token builtin:sym<real> { 'REAL' }
    rule builtin:sym<integer> { 'INTEGER' [ <named-number-list> || <constraint-list> ]? }
    rule builtin:sym<object-id> { 'OBJECT' 'IDENTIFIER' }
    rule builtin:sym<string> { 'OCTET' 'STRING' }
    rule builtin:sym<bit-string> { 'BIT' 'STRING' }
    token builtin:sym<bits> { 'BITS' }
    rule builtin:sym<sequence> { 'SEQUENCE' '{' <element-type-list> '}'}
    rule builtin:sym<sequence-of> { 'SEQUENCE' 'OF' <type> }
    rule builtin:sym<set> { 'SET' '{' <element-type-list> '}' }
    rule builtin:sym<set-of> { 'SET' 'OF' <type> }
    rule builtin:sym<choice> { 'CHOICE' '{' <element-type-list> '}' }
    rule builtin:sym<enumerated> { 'ENUMERATED' <named-number-list> }
    rule builtin:sym<any> { 'ANY' }
    rule builtin:sym<tagged> { <tag> <explicit-or-implicit-tag>? <type>}

    token named-number-list { '{' \n* <named-number>+ % ",\n" \s* '}' }
    rule named-number { \s* <id-string> '(' <number> ')'}
    token number { <value:sym<number>> || <binary-value> || <hex-value> || <id-string> }

    rule constraint-list { '(' <lower-end-point> <value-range>? ')' }
    token lower-end-point { <value> || 'MIN' }
    token upper-end-point { <value> || 'MAX' }
    rule value-range { '<'? '..' '<'? <upper-end-point> }
    rule tag { '[' <class>? (\d+) ']'}
    token class { 'UNIVERSAL' || 'APPLICATION' || 'PRIVATE' }

    token element-type-list { <element-type>+ % ",\n" }
    rule element-type { <?> <id-string>? <type> <optional-or-default>? }
    rule optional-or-default { 'OPTIONAL' || 'DEFAULT' <id-string>? <value> }

    # Value part
    rule value-assignment { <id-string> <type> '::=' <value>\n* }
    proto token value {*}
    token value:sym<null> { 'NULL' }
    token value:sym<bool> { 'TRUE' || 'FALSE' }
    token value:sym<special-real> { 'PLUS-INFINITY' || 'MINUS-INFINITY' }
    token value:sym<number> { '-'? \d+ }
    token value:sym<binary> { "'" <[01]>* "'" <[bB]> }
    token value:sym<hex> {  "'" <xdigit>* "'" <[hH]> }
    token value:sym<string> { '"' ( <-["]> | '""' )* '"' }
    token value:sym<bit> { '{' <name-value-component>* '}' }
    token value:sym<defined> { <id-string> }
    token name-value-component { ','? <name-or-number> }
    token name-or-number { \d+ || <id-string> || <name-and-number> }
    rule name-and-number { <id-string> '(' \d+ ')' || <id-string> '(' <id-string> ')' }

    token explicit-or-implicit-tag { 'EXPLICIT' || 'IMPLICIT' }
    token id-string { <[A..Z a..z]> <[A..Z a..z 0..9 \- _ ]>* }
}

class ASN::Module {
    has $.name;
    has $.schema;
    has @.types;
}

class ASN::TypeAssignment {
    has $.name;
    has $.type;
}

class ASN::ValueAssignment {
    has $.name;
    has $.type;
    has $.value;
}

class ASN::RawType {
    has $.name;
    has $.type;
    has %.params;
}

class ASN::Tag {
    subset TagClass of Str where 'APPLICATION'|'PRIVATE'|'CONTEXT-SPECIFIC'|'UNIVERSAL';
    has TagClass $.class;
    has Int $.value;
}

class ASN::Result {
    method TOP($/) {
        if $<module>.elems == 1 {
            make ASN::Module.new(|$<module>[0].made) if $<module>.elems == 1;
        } else {
            make $<module>.map(ASN::Module.new(|$_.made));
        }
    }
    method module($/) {
        make Map.new('name', ~$<id-string>, 'schema', ~$<default-tag>.trim, Pair.new('types', $<body>.made));
    }

    method body($/) {
        my @types;
        @types.push: .made for $<value-assignment>;
        @types.push: .made for $<type-assignment>;
        make @types;
    }

    method type-assignment($/) {
        make ASN::TypeAssignment.new(name => ~$<id-string>, type => $<type>.made);
    }

    method type($/) {
        make $_.made with $<builtin>;
        make ASN::RawType.new(:name(~$_), :type(~$_)) with $<id-string>;
    }

    method builtin:sym<null>($/) { make ASN::RawType.new(:type('NULL')) }
    method builtin:sym<boolean>($/) { make ASN::RawType.new(:type('BOOLEAN')) }
    method builtin:sym<real>($/) { make ASN::RawType.new(:type('REAL')) }
    method builtin:sym<integer>($/) { make ASN::RawType.new(:type('INTEGER')) }
    method builtin:sym<object-id>($/) { make ASN::RawType.new(:type('OBJECT IDENTIFIER')) }
    method builtin:sym<string>($/) { make ASN::RawType.new(:type('OCTET STRING')) }
    method builtin:sym<bit-string>($/) { make ASN::RawType.new(:type('BIT STRING')) }
    method builtin:sym<bits>($/) { make ASN::RawType.new(:type('BITG')) }
    method builtin:sym<sequence>($/) {
        my $fields = $<element-type-list>.made;
        make ASN::RawType.new(:type('SEQUENCE'), params => { :$fields });
    }
    method builtin:sym<sequence-of>($/) { make ASN::RawType.new(:type('SEQUENCE OF'), params => {:of($<type>.made)}) }
    method builtin:sym<set>($/) { make ASN::RawType.new(:type('SET')) }
    method builtin:sym<set-of>($/) { make ASN::RawType.new(:type('SET OF'), params => {:of($<type>.made)}) }
    method builtin:sym<choice>($/) {
        my $choice = $<element-type-list>.made.List;
        my %choices;
        for @$choice -> $item {
            with $item.params<tag> {
                %choices{$item.name} = ($_ => $item.type);
            } else {
                %choices{$item.name} = $item.type;
            }
        }
        make ASN::RawType.new(:type('CHOICE'), params => { :%choices })
    }
    method builtin:sym<enumerated>($/) {
        make ASN::RawType.new(:type('ENUMERATED'), params => { defs => $<named-number-list>.made })
    }
    method builtin:sym<tagged>($/) {
        my $inner = $<type>.made;
        $inner.params<tag> = $<tag>.made;
        make $inner;
    }

    method named-number-list($/) { make $<named-number>>>.made.Hash }
    method named-number($/) { make $<id-string>.Str => $<number>.Str.Int }

    method element-type-list($/) { make $<element-type>>>.made.List }
    method element-type($/) {
        my $inner = $<type>.made;
        my %params = $inner.params;
        with $<optional-or-default> {
            with $_<value> {
                %params<default> = $_.made;
            } else {
                %params<optional> = True;
            }
        }
        make ASN::RawType.new(:name(~$<id-string>), type => $inner.type, :%params);
    }

    method tag($/) {
        my $class = $<class> // 'CONTEXT-SPECIFIC';
        make ASN::Tag.new(class => $class.Str.uc, value => $0.Str.Int)
    }

    method value-assignment($/) {
        make ASN::ValueAssignment.new(name => ~$<id-string>, type => ~$<type>.trim, value => $<value>.made);
    }
    method value:sym<defined>($/) {
        # FIXME This is a hack, as this rule somehow overrides `bool` rule
        if $/.Str eq 'TRUE' {
            make True;
        } elsif $/.Str eq 'FALSE' {
            make False;
        } else {
            make ~$/;
        }
    }
    method value:sym<null>($/) { make 'NULL' }
    method value:sym<bool>($/) { make ($/.Str eq 'FALSE' ?? False !! True) }
    method value:sym<number>($/) { make $/.Int }
    method value:sym<string>($/) { make ~$/ }
}

our sub parse-ASN(Str $source) is export {
    my $clean-source = $source.subst(/ \s* '--' .*? \n /, "\n", :g).subst("\n\n", "\n", :g);
    ASN::Grammar.parse($clean-source, :actions(ASN::Result.new)).made;
}
