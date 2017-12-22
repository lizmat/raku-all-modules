class PDF::Content::Font::Enc::Type1 {
    use Font::AFM;
    use PDF::Content::Font::Encodings;
    has $.glyphs = %Font::AFM::Glyphs;
    has UInt %!from-unicode;
    has UInt %!subset;
    has uint16 @.to-unicode[256];
    has uint8 @!fallback-cids;
    has uint8 @!differences;
    my subset EncodingScheme of Str where 'mac'|'win'|'sym'|'zapf';
    has EncodingScheme $.enc = 'win';

    submethod TWEAK {
        my array $encoding;
	given $!enc {
	    when 'mac' {
		$encoding = $PDF::Content::Font::Encodings::mac-encoding;
	    }
	    when 'win' {
		$encoding = $PDF::Content::Font::Encodings::win-encoding;
	    }
	    when 'sym' {
		$encoding = $PDF::Content::Font::Encodings::sym-encoding;
	    }
	    when 'zapf' {
		$!glyphs = $PDF::Content::Font::Encodings::zapf-glyphs;
		$encoding = $PDF::Content::Font::Encodings::zapf-encoding;
	    }
	}

        @!to-unicode = $encoding.list;
        my uint16 @more-cids;
        for 1 .. 255 -> $idx {
            my uint16 $code-point = @!to-unicode[$idx];
            if $code-point {
                %!from-unicode{$code-point} = $idx;
                @more-cids.unshift: $idx;
            }
            else {
                @!fallback-cids.push($idx)
            }
        }
        @!fallback-cids.append: @more-cids;
        # map non-breaking space to a regular space
        %!from-unicode{"\c[NO-BREAK SPACE]".ord} //= %!from-unicode{' '.ord};
    }

    method lookup-glyph(UInt $chr-code) {
        $!glyphs{$chr-code.chr}
    }

    method glyph-map {
        %( $!glyphs.invert );
    }

    method !add-encoding($chr-code, $idx) {
        %!from-unicode{$chr-code} = $idx;
        @!to-unicode[$idx] = $chr-code;
        %!subset{$chr-code} = $idx;
        @!differences.push: $idx;
    }
    method add-encoding($chr-code, :$idx is copy = %!from-unicode{$chr-code} // 0) {
        if $idx {
            %!subset{$chr-code} = $idx;
        }
        else {
            my $glyph-name = self.lookup-glyph($chr-code);
            if $glyph-name && $glyph-name ne '.notdef' {
                # try to remap the glyph to a spare encoding or other unused glyph
                while @!fallback-cids && !$idx {
                    $idx = @!fallback-cids.shift;
                    my $old-chr-code = @!to-unicode[$idx];
                    if $old-chr-code && %!subset{$old-chr-code} {
                        # already inuse
                        $idx = 0;
                    }
                    else {
                        # add it to the encoding scheme
                        self!add-encoding($chr-code, $idx);
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
        buf8.new: $text.ords.map({%!subset{$_} || self.add-encoding($_) }).grep: {$_};
    }

    multi method decode(Str $encoded, :$str! --> Str) {
        $encoded.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
    }
    multi method decode(Str $encoded --> buf16) {
        buf16.new: $encoded.ords.map({@!to-unicode[$_]}).grep: {$_};
    }

    method differences {
        Proxy.new(
            STORE => sub ($, @differences) {
                my %glyph-map := self.glyph-map;
                my uint32 $idx = 0;
                for @differences {
                    when UInt { $idx  = $_ }
                    when Str {
                        self!add-encoding(.ord, $idx)
                            with %glyph-map{$_};
                        $idx++;
                    }
                }
            },
            FETCH => sub ($) {
                my %seen;
                my @diffs;
                my int $cur-idx = -2;
                for @!differences.list.sort {
                    unless $_ == ++$cur-idx {
                        @diffs.push: $_;
                        $cur-idx = $_;
                    }
                    @diffs.push: 'name' => self.lookup-glyph( @!to-unicode[$_] ) // '.notdef';
                }
                @diffs
            },
        )
    }
}
