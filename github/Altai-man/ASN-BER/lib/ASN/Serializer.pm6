use ASN::Types;

class ASN::Serializer {
# BOOLEAN
    multi method serialize(Bool $bool, Int $index = 1, :$debug, :$mode) {
        say "Encoding Bool ($bool) with index $index" if $debug;
        self!pack($index, Buf.new($bool ?? 255 !! 0));
    }

    # INTEGER
    multi method serialize(Int $int is copy where $int.HOW ~~ Metamodel::ClassHOW, Int $index = 2, :$debug, :$mode) {
        my $int-encoded = Buf.new;
        my $bit-shift-value = 0;
        my $bit-shift-mask = 0xff;
        while True {
            my $byte = $int +& $bit-shift-mask +> $bit-shift-value;
            if $byte == 0 {
                $int-encoded.append(0) if $int-encoded.elems == 0;
                last;
            }
            $int-encoded.append($byte);
            # Update operands
            $bit-shift-value += 8;
            $bit-shift-mask +<= 8;
        }

        say "Encoding Int ($int) with index $index, resulting in $int-encoded.reverse().perl()" if $debug;
        self!pack($index, $int-encoded.reverse);
    }

    # OctetString
    multi method serialize(ASN::Types::OctetString $str, Int $index = 4, :$debug) {
        my $value-cut = $str.value.substr(0, 10);
        my $buf =  $str.value.encode;
        say "Encoding OctetString ({ $buf.elems > 10 ?? "$value-cut..." !! $value-cut }) with index $index" if $debug;
        self!pack($index, $buf);
    }

    # NULL
    multi method serialize(ASN-Null, Int $index = 5, :$debug, :$mode) {
        say "Encoding Null with index $index" if $debug;
        self!pack($index, Buf.new);
    }

    # ENUMERATED
    multi method serialize($enum-value where $enum-value.HOW ~~ Metamodel::EnumHOW, Int $index = 10, :$debug, :$mode) {
        my $encoded = $enum-value.Int;
        say "Encoding Enum ($enum-value) with index $index, resulting in $encoded" if $debug;
        self!pack($index, Buf.new($encoded));
    }

    # UTF8String
    multi method serialize(ASN::Types::UTF8String $str, Int $index = 12, :$debug) {
        my $value-cut = $str.value.substr(0, 10);
        my $buf = $str.value.encode;
        say "Encoding UTF8String ({ $buf.elems > 10 ?? "$value-cut..." !! $value-cut }) with index $index" if $debug;
        self!pack($index, $buf);
    }

    multi method serialize(ASNSequence $sequence, Int $index is copy = 48, :$debug, :$mode = Implicit) {
        $index += 32 unless $index ~~ 48|-1;
        my Blob $res = Buf.new;
        say "Encoding ASNSequence $sequence.^name() as $sequence.ASN-order().perl()" if $debug;
        for $sequence.ASN-order -> $field {
            my $attr = $sequence.^attributes.grep(*.name eq $field)[0];
            # Params
            my %params;
            %params<default> = $attr.default-value if $attr ~~ DefaultValue;
            %params<tag> = $attr.tag if $attr ~~ CustomTagged;

            my $value = $attr.get_value($sequence)<>;
            next if $attr ~~ Optional && (!$value.defined || $value ~~ Positional && !$value.elems);
            %params<value> = $value;

            if $attr ~~ ASN::Types::UTF8String {
                %params<type> = ASN::Types::UTF8String;
            } elsif $attr ~~ ASN::Types::OctetString {
                %params<type> = ASN::Types::OctetString;
            } elsif $attr.type ~~ Positional {
                %params<type> = $attr.type.of;
            }
            $res.push(self.serialize(ASNValue.new(|%params), :$debug, :$mode));
        }
        self!pack($index, $res);
    }

    # SEQUENCE OF
    multi method serialize(ASNSequenceOf $sequence, Int $index is copy = 48, :$debug, :$mode) {
        return Buf.new unless $sequence.seq.all ~~ .defined;
        $index += 32 unless $index ~~ 48|-1;
        say "Encoding SEQUENCE OF with index $index into:" if $debug;
        my $type = $sequence.type;
        my $res;
        $res.push: self.serialize($_, :$debug, :$mode) for @($sequence.seq);
        $res //= [Buf.new];
        self!pack($index, [~] |$res);
    }

    # SET OF
    multi method serialize(ASNSetOf $set, Int $index = 49, :$debug, :$mode) {
        $index += 32 unless $index ~~ 49|-1;
        say "Encoding SET OF with index $index into:" if $debug;
        my $type = $set.type;
        my $res;
        $res.push: self.serialize($type ~~ ASN::StringWrapper ?? $type.new($_) !! $_, :$debug, :$mode) for $set.keys;
        $res //= [Buf.new];
        self!pack($index, [~] |$res);
    }

    # Common method to enforce custom traits for ASNValue value
    # and call a serializer
    multi method serialize(ASNValue $asn-node, :$debug, :$mode) {
        my $value = $asn-node.value;

        # Don't serialize undefined values of type with a default
        return Buf.new if $asn-node.default eqv $value;
        return self.serialize($asn-node.type.new($value), |($_ + 128 with $asn-node.tag) :$debug, :$mode) if $value ~~ Str;

        if $value ~~ Positional {
            my $seq = $value.map({
                if $asn-node.type ~~ ASN::StringWrapper {
                    $asn-node.type.new($_);
                } else {
                    $_;
                }
            }).Array;
            return self.serialize(ASNSequenceOf[$asn-node.type].new(:$seq), |($_ + 128 with $asn-node.tag), :$debug, :$mode);
        }
        self.serialize($value, |($_ + 128 with $asn-node.tag), :$debug, :$mode);
    }

    # CHOICE has to be handled specially
    multi method serialize(ASNChoice $choice, :$debug, :$mode) {
        my $description = $choice.ASN-choice;
        my $choice-item = $description{$choice.ASN-value.key};
        unless $description{$choice.ASN-value.key}:exists {
            die "Could not find value by $choice.ASN-value().key() out of $description.perl()";
        }
        my $value = $choice.ASN-value.value;

        my $index = do given $mode {
            when Implicit {
                if $choice-item ~~ Pair {
                    $choice-item.key + 128;
                } else {
                    $choice-item.ASN-tag-value + 64;
                }
            }
        }
        $index += 32 unless $value ~~ $primitive-type;

        my $inner = self.serialize($value, -1, :$debug, :$mode);
        say "Encoding ASNChoice by $description.perl() with value: $value.perl()" if $debug;
        Buf.new(|($index == -1 ?? () !! ($index, |self!calculate-len($inner))), |$inner);
    }

    # Dying method to detect types not yet implemented
    multi method serialize($unknown-type, :$debug) {
        die "NYI for: $unknown-type.perl()";
    }

    method !pack($index, $value) {
        if $index == -1 {
            Buf.new($value);
        } else {
            Buf.new($index, |self!calculate-len($value), |$value);
        }
    }

    method !calculate-len(Blob $value, :$infinite) {
        with $infinite {
            return Buf.new(128);
        }
        if $value.elems <= 127 {
            return Buf.new($value.elems);
        }
        my $long = self.serialize($value.elems, -1);
        if $long.elems > 126 {
            die "The value is too long, please use streaming";
        }
        return Buf.new($long.elems + 128, |$long);
    }
}
