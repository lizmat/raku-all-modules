use ASN::Types;

class ASN::Parser {
    has $.type;

    method is-complete(Blob $input is copy --> Bool) {
        my $tag = self.get-tag($input);
        my $len = self.get-length($input);
        $len <= $input.elems;
    }

    multi method parse(Blob $input, :$debug, :$mode, :$to-chop = True) {
        my $in = Buf.new($input);
        # Chop off first tag and length
        if $to-chop {
            self.get-tag($in);
            self.get-length($in);
        }
        self.parse($in, $!type, :$debug, :$mode);
    }

    multi method parse(Buf $input is rw, ASNSequence $type, :$debug, :$mode) {
        say "Parsing ASNSequence of type $type.^name()" if $debug;
        my @params = do gather {
            for $type.ASN-order.kv -> $i, $field {
                if $input.elems == 0 {
                    my $remain = $type.ASN-order[$i .. *].map(-> $attr {$type.^attributes.grep({$_.name eq $attr})[0]});
                    unless $remain.map({ $_ ~~ Optional|DefaultValue }).all {
                        die "Part of content is missing";
                    }
                    last;
                }
                my $attr = $type.^attributes.grep(*.name eq $field)[0];
                my %params;
                %params<name> = $field;
                %params<tag> = $attr.tag if $attr ~~ CustomTagged;
                %params<type> = self!calculate-type($attr);
                my $key = self!normalize-name($field);
                my $asn-value = ASNValue.new(|%params);

                next if $attr ~~ Optional|DefaultValue && self!check-optional($input, $asn-value);

                my $value = self.parse($input, $asn-value, :$debug, :$mode);
                take $key;
                take self!post-process($value);
            }
        }
        $type.bless(|Map.new(@params));
    }

    method !calculate-type($attr) {
        my $is-sequence = $attr.type ~~ Positional;
        given $attr {
            when ASN::Types::UTF8String {
                return $is-sequence ?? ASNSequenceOf[ASN::Types::UTF8String] !! ASN::Types::UTF8String;
            }
            when ASN::Types::OctetString {
                return $is-sequence ?? ASNSequenceOf[ASN::Types::OctetString] !! ASN::Types::OctetString;
            }
            default {
                return $is-sequence ?? ASNSequenceOf[$attr.type.of] !! $attr.type;
            }
        }
        die "NYI for $attr.perl()";
    }

    method !post-process($value) {
        return $value.map(*.value) if $value ~~ Positional && $value.of ~~ ASN::StringWrapper;
        return $value.value if $value ~~ ASN::StringWrapper;
        $value;
    }

    method !check-optional(Buf $input is rw, ASNValue $value) {
        my $tag-to-be = self!calculate-tag($value);
        my $tag = self.get-tag($input);
        $input.unshift($tag);
        $tag-to-be !~~ $tag;
    }

    method !parse-sequence(Buf $input is rw, $type, $holder, :$debug, :$mode) {
        while $input.elems != 0 {
            my $tag = self.get-tag($input);
            my $len = self.get-length($input);
            my $piece-bytes = $input.subbuf(0, $len);
            $input .= subbuf($len);
            $holder.push: self!post-process(self.parse($piece-bytes, $type, :$tag, :$debug, :$mode));
        }
        $holder;
    }

    multi method parse(Buf $input is rw, ASNSequenceOf $type, :$debug, :$mode) {
        say "Parsing ASNSequenceOf of $type.type().perl()" if $debug;
        my $of = $type.type;
        $of = Str if $of ~~ ASN::StringWrapper;
        my Positional[$of] $values = Array[$of].new;
        self!parse-sequence($input, $type.type, $values, :$debug, :$mode);
        $values;
    }

    multi method parse(Buf $input is rw, ASNSetOf $type, :$debug, :$mode) {
        note "Parsing ASNSetOf of $type.type().perl()" if $debug;
        my Array $set .= new;
        self!parse-sequence($input, $type.type, $set, :$debug, :$mode);
        $type.new(|$set);
    }

    multi method parse(Buf $input is rw, ASNChoice $choice, :$tag, :$debug, :$mode) {
        say "Parsing ASNChoice with $tag.perl()" if $debug;
        my $item-index = $tag +& 0b11011111;
        if $tag +& 128 == 128 {
            # APPLICATION tag
            $item-index -= 128;
        } elsif $tag +& 64 == 64 {
            # Context-specific tag
            $item-index -= 64;
        } else {
            # Universal tag
        }

        my $item = $choice.ASN-choice.grep({ (.value ~~ Pair ?? .value.key !! .value.ASN-tag-value) eq $item-index })[0];
        my $value-type = $item.value ~~ Pair ?? $item.value.value !! $item.value;

        my $choice-index;
        if $value-type ~~ ASNChoice {
            $choice-index = self.get-tag($input);
            my $length = self.get-length($input);
        }

        $choice.new(Pair.new($item.key, self.parse($input, $value-type, tag => $choice-index, :$debug, :$mode)));
    }

    multi method parse(Buf $input is rw, ASNValue $value, :$debug, :$mode) {
        my $tag = self.get-tag($input);
        my $length = self.get-length($input);
        my $asn-bytes = $input.subbuf(0, $length);
        $input .= subbuf($length);
        self.parse($asn-bytes, $value.type, :$tag, :$debug, :$mode);
    }

    method get-tag(Buf $input is rw, :$immutable = False --> Int) {
        my $tag = $input[0];
        $input .= subbuf(1) unless $immutable;
        $tag;
    }

    method get-length(Buf $input is rw, :$immutable = False --> Int) {
        my $length = $input[0];
        if $length <= 127 {
            $input .= subbuf(1) unless $immutable;
            return $length;
        } else {
            my $octets = $input.subbuf(1, $length - 128);
            $input .= subbuf($length - 127) unless $immutable;
            return self.parse($octets, Int);
        }
    }

    method !calculate-tag(ASNValue $value) {
        my $tag = 0;
        with $value.tag {
            my $tag = $_ + 128;
            $tag += 32 if $value.type ~~ ASNSequence|ASNSequenceOf|ASNSet|ASNSetOf;
            return $tag;
        }
        $tag += do given $value.type {
            when Bool {
                1
            }
            when $_ ~~ Int && $_.HOW ~~ Metamodel::ClassHOW {
                2
            }
            when ASN::Types::OctetString {
                4
            }
            when ASN-Null {
                5
            }
            when $_ ~~ Enumeration && $_.HOW ~~ Metamodel::EnumHOW {
                10
            }
            when ASN::Types::UTF8String {
                12
            }
            when Positional {
                16
            }
        }
        return self!convert-choice-to-tags($value.type) if $value.type ~~ ASNChoice;
        $tag;
    }

    method !convert-choice-to-tags(ASNChoice $choice) {
        my @opts = gather {
            for @($choice.ASN-choice) -> $option {
                if $option.value ~~ Pair {
                    take $option.value.key.Int + 128;
                } else {
                    my $tag = $option.value.ASN-tag-value + 64;
                    $tag += 32 if $option.value !~~ $primitive-type;
                    take $tag;
                }
            }
        }
        @opts.any;
    }

    method !normalize-name(Str $name) {
        ~("$name" ~~ / \w .+ /)
    }

    multi method parse(Buf $input is rw, @positional, :$debug, :$mode) {
        my $type = @positional.of;
        my @temp;
        self!parse-sequence($input, $type, @temp, :$debug, :$mode);
        @positional.new(@temp);
    }

    multi method parse(Buf $input is rw, Int $type where $type.HOW ~~ Metamodel::ClassHOW, :$debug) {
        my $total = 0;
        for (0, 8 ... *) Z @$input.reverse -> ($shift, $byte) {
            $total +|= $byte +< $shift;
        }
        say "Parsing $total out of $input.perl()" if $debug;
        $total;
    }

    multi method parse(Buf $input is rw, ASN::Types::UTF8String $str, :$debug) {
        my $decoded = $input.decode();
        say "Parsing `$decoded.perl()` out of $input.perl()" if $debug;
        $str.new($decoded);
    }

    multi method parse(Buf $input is rw, ASN::Types::OctetString $str, :$debug) {
        my $decoded = $input.decode;
        say "Parsing `$decoded.perl()` out of $input.perl()" if $debug;
        $str.new($decoded);
    }

    multi method parse(Buf $input is rw, Bool $bool, :$debug, :$mode) {
        say "Parsing `{ $input[0] != 0 }` out of $input.perl()" if $debug;
        my $value = $input[0];
        return $value != 0;
    }

    multi method parse(Buf $input is rw, $enum-type where $enum-type.HOW ~~ Metamodel::EnumHOW, :$debug, :$mode) {
        say "Parsing `$input[0]` out of $input.perl()" if $debug;
        $enum-type($input[0]);
    }

    multi method parse(Buf $input, ASN-Null $type, :$debug) {
        say "Parsing NULL out of $input.perl()" if $debug;
        $type.new;
    }
}
