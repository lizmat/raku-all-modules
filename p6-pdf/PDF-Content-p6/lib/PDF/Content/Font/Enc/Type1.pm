class PDF::Content::Font::Enc::Type1 {

    use PDF::DAO::Dict;
    use PDF::Content::Font::Encodings;
    has $.glyphs = $PDF::Content::Font::Encodings::win-glyphs;
    has $!encoding = $PDF::Content::Font::Encodings::mac-encoding;
    has uint8 @!from-unicode;
    has uint16 @!to-unicode[256];
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

    #| compute the overall font-height
    method height($pointsize?, List :$bbox!, Bool :$from-baseline, Bool :$hanging) {
	my Numeric $height = $bbox[3];
        $height *= .75 if $hanging;  # not applicable to core fonts - approximate
	$height -= $bbox[1] unless $from-baseline;
	$pointsize ?? $height * $pointsize / 1000 !! $height;
    }

    #| reduce string to the displayable characters
    method filter(Str $text-in) {
	$text-in.order.grep({ @!from-unicode[$_] }).join;
    }

    #| map ourselves to a PDF::Content object
    method to-dict($font-name) {
	my %enc-name = :win<WinAnsiEncoding>, :mac<MacRomanEncoding>;
	my $dict = { :Type( :name<Font> ), :Subtype( :name<Type1> ),
		     :BaseFont( :name( $font-name ) ),
	};

	with %enc-name{self.enc} -> $name {
	    $dict<Encoding> = :$name;
	}

	PDF::DAO::Dict.coerce: $dict;
    }

    multi method encode(Str $s, :$str! --> Str) {
        self.encode($s).decode: 'latin-1';
    }
    multi method encode(Str $s --> buf8) is default {
        buf8.new: $s.ords.map({@!from-unicode[$_]}).grep: {$_};
    }

    multi method decode(Str $s, :$str! --> Str) {
        $s.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
    }
    multi method decode(Str $s --> buf16) {
        buf16.new: $s.ords.map({@!to-unicode[$_]}).grep: {$_};
    }

}
