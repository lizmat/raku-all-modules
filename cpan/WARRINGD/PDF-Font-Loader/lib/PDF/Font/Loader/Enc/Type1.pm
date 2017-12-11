use PDF::Content::Font::Enc::Type1;
use Font::FreeType::Face;

class PDF::Font::Loader::Enc::Type1
  is PDF::Content::Font::Enc::Type1 {

  has Font::FreeType::Face $.face is required;

  method lookup-glyph($chr-code) {
      $!face.glyph-name($chr-code);
  }

}
