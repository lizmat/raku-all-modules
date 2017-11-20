class PDF::Content::Font::Enc::Type1 {
    use Font::AFM;
    use PDF::Content::Font::Encodings;
    has $.glyphs = %Font::AFM::Glyphs;
    has array $!encoding;
    has UInt %!from-unicode;
    has uint16 @.to-unicode[256];
    has uint8 @!spare-encodings;
    has uint8 @!differences;
    my subset EncodingScheme of Str where 'mac'|'win'|'sym'|'zapf';
    has EncodingScheme $.enc = 'win';

    submethod TWEAK {
	given $!enc {
	    when 'mac' {
		$!encoding = $PDF::Content::Font::Encodings::mac-encoding;
	    }
	    when 'win' {
		$!encoding = $PDF::Content::Font::Encodings::win-encoding;
	    }
	    when 'sym' {
		$!encoding = $PDF::Content::Font::Encodings::sym-encoding;
	    }
	    when 'zapf' {
		$!glyphs = $PDF::Content::Font::Encodings::zapf-glyphs;
		$!encoding = $PDF::Content::Font::Encodings::zapf-encoding;
	    }
	}

        @!to-unicode = $!encoding.list;
        for 1 .. 255 -> $encoding {
            my uint16 $code-point = @!to-unicode[$encoding];
            if $code-point {
                %!from-unicode{$code-point} = $encoding;
            }
            else {
                @!spare-encodings.push($encoding)
            }
        }
        # map non-breaking space to a regular space
        %!from-unicode{"\c[NO-BREAK SPACE]".ord} //= %!from-unicode{' '.ord};
    }

    method lookup-glyph(UInt $chr-code) {
          $!glyphs{$chr-code.chr}
    }

    method !add-encoding($chr-code) {
        my $glyph-name = self.lookup-glyph($chr-code);
        if  @!spare-encodings && $glyph-name && $glyph-name ne '.notdef' {
            my $idx = @!spare-encodings.shift;
            %!from-unicode{$chr-code} = $idx;
            @!to-unicode[$idx] = $chr-code;
            @!differences.push: $idx;
            $idx;
        }
        else {
            0
        }
    }
    multi method encode(Str $text, :$str! --> Str) {
        self.encode($text).decode: 'latin-1';
    }
    multi method encode(Str $text --> buf8) is default {
        buf8.new: $text.ords.map({%!from-unicode{$_} || self!add-encoding($_) }).grep: {$_};
    }

    multi method decode(Str $encoded, :$str! --> Str) {
        $encoded.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
    }
    multi method decode(Str $encoded --> buf16) {
        buf16.new: $encoded.ords.map({@!to-unicode[$_]}).grep: {$_};
    }

    method differences {
        my @diffs;
        my uint8 $cur-idx = 0;
        for @!differences {
            @diffs.push: $_
                unless $_ == $cur-idx;
            @diffs.push: 'name' => self.lookup-glyph( @!to-unicode[$_] );
            $cur-idx = $_ + 1;
        }
        @diffs;
    }
}
