use PDF::Content::Font::Enc::Type1;
use PDF::Font::Loader::Enc;
class PDF::Font::Loader::Enc::Type1
    is PDF::Content::Font::Enc::Type1
    is PDF::Font::Loader::Enc {

  use Font::FreeType::Face;
  use Font::FreeType::Native;
  use Font::FreeType::Native::Types;
  has Font::FreeType::Face $.face is required;

  method lookup-glyph($chr-code) {
      $!face.glyph-name($chr-code);
  }

  method glyph-map {
      return Mu
          unless $!face.has-glyph-names;
      my %codes;
      my FT_Face $struct = $!face.struct;  # get the native face object
      my FT_UInt $glyph-idx;
      my FT_ULong $char-code = $struct.FT_Get_First_Char( $glyph-idx);
      while $glyph-idx {
          %codes{ $!face.glyph-name($char-code) } = $char-code.chr;
          $char-code = $struct.FT_Get_Next_Char( $char-code, $glyph-idx);
      }
      %codes;
  }

}
