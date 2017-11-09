class PDF::Content::Font::Enc::Type1 {

    use PDF::Content::Font::Encodings;
    has $.glyphs = $PDF::Content::Font::Encodings::win-glyphs;
    has $!encoding = $PDF::Content::Font::Encodings::mac-encoding;
    has uint8 @!from-unicode;
    has uint16 @.to-unicode[256];
    my subset EncodingScheme of Str where 'mac'|'win'|'sym'|'zapf';
    has EncodingScheme $.enc = 'win';

    submethod TWEAK {
	given $!enc {
	    when 'mac' {
		$!glyphs = $PDF::Content::Font::Encodings::mac-glyphs;
		$!encoding = $PDF::Content::Font::Encodings::mac-encoding;
	    }
	    when 'win' {
		$!glyphs = $PDF::Content::Font::Encodings::win-glyphs;
		$!encoding = $PDF::Content::Font::Encodings::win-encoding;
	    }
	    when 'sym' {
		$!glyphs = $PDF::Content::Font::Encodings::sym-glyphs;
		$!encoding = $PDF::Content::Font::Encodings::sym-encoding;
	    }
	    when 'zapf' {
		$!glyphs = $PDF::Content::Font::Encodings::zapf-glyphs;
		$!encoding = $PDF::Content::Font::Encodings::zapf-encoding;
	    }
	}

        for $!glyphs.pairs {
            my uint16 $code-point = .key.ord;
            my uint8 $encoding = $!encoding{.value}.ord;
            @!from-unicode[$code-point] = $encoding;
            @!to-unicode[$encoding] = $code-point;
        }
    }

    multi method encode(Str $text, :$str! --> Str) {
        self.encode($text).decode: 'latin-1';
    }
    multi method encode(Str $text --> buf8) is default {
        buf8.new: $text.ords.map({@!from-unicode[$_]}).grep: {$_};
    }

    multi method decode(Str $encoded, :$str! --> Str) {
        $encoded.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
    }
    multi method decode(Str $encoded --> buf16) {
        buf16.new: $encoded.ords.map({@!to-unicode[$_]}).grep: {$_};
    }

}
