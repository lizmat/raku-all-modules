use PDF::Font::Loader::Enc;
class PDF::Font::Loader::Enc::Identity-H
    is PDF::Font::Loader::Enc {

    use Font::FreeType::Face;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;
    use PDF::COS;

    has Font::FreeType::Face $.face is required;
    has uint32 @!to-unicode;
    has UInt $.min-index;
    has UInt $.max-index;
    has Bool $!init;

    multi method encode(Str $text, :$str! --> Str) {
        my $hex-string = self.encode($text).decode: 'latin-1';
        PDF::COS.coerce: :$hex-string;
    }
    multi method encode(Str $text) is default {
        my uint16 @codes;
        my $face-struct = $!face.struct;
        for $text.ords {
            my uint $index = $face-struct.FT_Get_Char_Index($_);
            @!to-unicode[$index] ||= $_;
            @codes.push: $index;
        }
        @codes;
    }

    method !setup-decoding {
        my FT_Face $struct = $!face.struct;
        my FT_UInt $glyph-idx;
        my FT_ULong $char-code = $struct.FT_Get_First_Char( $glyph-idx);
        @!to-unicode[$!face.num-glyphs] = 0;
        while $glyph-idx {
            @!to-unicode[ $glyph-idx ] = $char-code;
            $char-code = $struct.FT_Get_Next_Char( $char-code, $glyph-idx);
        }
    }

    method to-unicode {
        $!init //= do { self!setup-decoding; True }
        @!to-unicode;
    }

    multi method decode(Str $encoded, :$str! --> Str) {
        $.decode($encoded).map({.chr}).join;
    }
    multi method decode(Str $encoded --> buf32) {
        my @to-unicode := self.to-unicode;
        buf32.new: $encoded.ords.map( -> \hi, \lo {@to-unicode[hi +< 8 + lo]}).grep: {$_};
    }

}
