use PDF::Font::Loader::Enc;
class PDF::Font::Loader::Enc::Identity
    is PDF::Font::Loader::Enc {

  use Font::FreeType::Face;
  use Font::FreeType::Native;
  use Font::FreeType::Native::Types;

  has UInt %!from-unicode;
  has uint16 @.to-unicode;
  has UInt $.idx-mask;

  method TWEAK(Font::FreeType::Face :$face!) {
      my FT_Face $struct = $face.struct;  # get the native face object
      my FT_UInt $idx;
      my FT_ULong $char-code = $struct.FT_Get_First_Char( $idx);
      $!idx-mask = ($idx div 256) * 256;
      while $idx {
          my uint8 $i = $idx - $!idx-mask;
          @!to-unicode[$i] = $char-code;
          %!from-unicode{$char-code} = $i;
          $char-code = $struct.FT_Get_Next_Char( $char-code, $idx);
      }
      warn { :@!to-unicode, :%!from-unicode }.perl;
  }

  multi method encode(Str $text, :$str! --> Str) {
      self.encode($text).decode: 'latin-1';
  }
  multi method encode(Str $text --> buf8) is default {
      buf8.new: $text.ords.map({ %!from-unicode{$_} }).grep: {$_};
  }

  multi method decode(Str $encoded, :$str! --> Str) {
      $encoded.ords.map({@!to-unicode[$_]}).grep({$_}).map({.chr}).join;
  }
  multi method decode(Str $encoded --> buf8) {
      buf8.new: $encoded.ords.map({@!to-unicode[$_]}).grep: {$_};
  }
}
