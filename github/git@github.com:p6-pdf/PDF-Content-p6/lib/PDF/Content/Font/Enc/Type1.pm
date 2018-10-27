use PDF::Content::Font::Enc::Glyphic;

class PDF::Content::Font::Enc::Type1
    does PDF::Content::Font::Enc::Glyphic {
    use PDF::Content::Font::Encodings :mac-encoding, :win-encoding, :sym-encoding, :std-encoding, :zapf-encoding, :zapf-glyphs;
    has UInt %!from-unicode;  #| all encoding mappings
    has UInt %!charset;       #| used characters
    has uint16 @.to-unicode[256];
    has uint8 @!fallback-cids;
    my subset EncodingScheme of Str where 'mac'|'win'|'sym'|'zapf';
    has EncodingScheme $.enc = 'win';

    submethod TWEAK {
        my array $encoding = %(
            :mac($mac-encoding),   :win($win-encoding),
            :sym($sym-encoding),   :std($std-encoding),
            :zapf($zapf-encoding),
        ){$!enc};

	self.glyphs = $zapf-glyphs
            if $!enc eq 'zapf';

        @!to-unicode = $encoding.list;
        my uint16 @encoded-cids;
        for 1 .. 255 -> $idx {
            my uint16 $code-point = @!to-unicode[$idx];
            if $code-point {
                %!from-unicode{$code-point} = $idx;
                # CID used in this encoding schema. rellocate as a last resort
                @encoded-cids.unshift: $idx;
            }
            else {
                # spare CID use it first
                @!fallback-cids.push($idx)
            }
        }
        @!fallback-cids.append: @encoded-cids;
        # map non-breaking space to a regular space
        %!from-unicode{"\c[NO-BREAK SPACE]".ord} //= %!from-unicode{' '.ord};
    }

    method set-encoding($chr-code, $idx) {
        unless %!from-unicode{$chr-code} ~~ $idx {
            %!from-unicode{$chr-code} = $idx;
            @!to-unicode[$idx] = $chr-code;
            %!charset{$chr-code} = $idx;
            $.add-glyph-diff($idx);
        }
    }
    method add-encoding($chr-code, :$idx is copy = %!from-unicode{$chr-code} // 0) {
        if $idx {
            %!charset{$chr-code} = $idx;
        }
        else {
            my $glyph-name = self.lookup-glyph($chr-code);
            if $glyph-name && $glyph-name ne '.notdef' {
                # try to remap the glyph to a spare encoding or other unused glyph
                while @!fallback-cids && !$idx {
                    $idx = @!fallback-cids.shift;
                    my $old-chr-code = @!to-unicode[$idx];
                    if $old-chr-code && %!charset{$old-chr-code} {
                        # already inuse
                        $idx = 0;
                    }
                    else {
                        # add it to the encoding scheme
                        self.set-encoding($chr-code, $idx);
                   }
                }
            }
        }
        $idx;
    }
    multi method encode(Str $text, :$str! --> Str) {
        self.encode($text).decode: 'latin-1';
    }
    multi method encode(Str $text --> buf8) is default {
        buf8.new: $text.ords.map({%!charset{$_} || self.add-encoding($_) }).grep: {$_};
    }

    multi method decode(Str $encoded, :$str! --> Str) {
        $encoded.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
    }
    multi method decode(Str $encoded --> buf16) {
        buf16.new: $encoded.ords.map({@!to-unicode[$_]}).grep: {$_};
    }

}
