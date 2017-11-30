use v6;
use PDF::Font;
use PDF::Lite;
use Test;
# ensure consistant document ID generation
srand(123456);
my $pdf = PDF::Lite.new;
my $deja = PDF::Font.load-font("t/fonts/DejaVuSans.ttf");
my $otf-font = PDF::Font.load-font("t/fonts/Cantarell-Oblique.otf");

$pdf.add-page.text: {
   .font = $deja;
   .text-position = [10, 760];
   .say: 'Hello, world';
   .say: 'WAV', :kern;
   my $s;
   my $n = 0;
   .font = $deja, 8;
   $deja.face.forall-chars: -> $_ {
       $s ~= .char-code.chr;
       $s ~= ' ' if $n++ %% 10
   };
   .say: $s, :width(400);
}

$pdf.add-page.text: {
   .text-position = [10, 500];
   .font = $otf-font;
   .say: "Sample Open Type Font";
   .say: 'Bye, for now';
}
lives-ok { $pdf.save-as: "t/freetype.pdf"; };

done-testing;

