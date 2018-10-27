use v6;

class PDF::API6::Font::Synthetic {

    use PDF::Content::Font::Enc::Type1;
    has PDF::Content::Font::Enc::Type1 $.encoder handles <encode decode enc>;
    has $!font-obj handles <stringwidth height>;
    has $!dict;

    method !encoding-name {
        my %enc-name = :win<WinAnsiEncoding>, :mac<MacRomanEncoding>;
        with %enc-name{self.enc} -> $name {
            :$name;
        }
    }

    method !make-dict {
        my $dict = {
            :Type( :name<Font> ), :Subtype( :name<Type3> ),
            :BaseFont( :name( $!metrics.FontName ) ),
        };
        $dict<Encoding> = $_ with self!encoding-name;
        $dict;
    }

   method to-dict {
        $!dict //= PDF::Content::Font.make-font(
            PDF::COS::Dict.coerce(self!make-dict),
            self);
    }

   method cb-finish {
       warn "la la la";
   }

}
