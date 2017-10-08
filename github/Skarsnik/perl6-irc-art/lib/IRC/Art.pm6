=begin pod

=head1 Name IRC::Art

=head1 Synopsis

  use IRC::Art;
  use YourFavoriteIrcClient;
  
  my $art = IRC::Art.new(4, 4); # A 4x4
  $art.rectangle(0, 0, 3, 3, :color(4)); #draw a red square
  $art.text("6.c", 1, 1, :color(13), :bold); # put the 6.c text starting at 1,1
  for $art.result {
    $irc.send-message('#perl6', $_);
  }

=head1 Description

IRC::Art offers you a way to create basic art on IRC. It works mainly like a small graphics library
with methods to "draw" like pixel, text or rectangle.

=head1 Usage

Create an C<IRC::Art> object and use the various drawing methods on it. 
Every change writes over the previous of the existing execpt for the text method.


=end pod

class IRC::Art {
  has	@.canvas;
  has	$.height;
  has	$.width;
  

=begin pod
=head2 new(?width, ?height)
  
Create a new canvas filled with blanks (space), sized according to the width and
height information.
  
=end pod

  multi method new($w, $h) {
    self.bless(width => $w, height => $h);
  }
  
  multi method new() {
    self.bless();
  }
  
  submethod BUILD(:$width, :$height) {
    $!height = $height;
    $!width = $width;
    return unless $width.defined;
    for ^$height -> $i {
      for ^$width -> $j {
        @!canvas[$i][$j] = " ";
      }
    }
  }

=begin pod
=head2 result

Returns the canvas as an array of irc strings that you can put in a loop to
send the art.
=end pod

  method result {
    return @.canvas.map:{@($_).join('')};
  }

=begin pod
=head2 Str

The C<Str> method returns the first row of the canvas as a single string.

=end pod

  method Str {
    return @.canvas[0].join('');
  }
  
=begin pod
=head2 pixel($x, $y, :$color, $clear)

Place or clear the pixel at the given x/y coordinate

=end pod
  method pixel($x, $y, :$color, :$clear) {
    my @tx = @($x);
    my @ty = @($y);
    for @ty.kv -> $i, $my {
      @.canvas[$my][@tx[$i]] = "\x03" ~ "$color,$color " ~ "\x03" unless $clear;
      @.canvas[$my][@tx[$i]] = " " if $clear;
    }
  }

=begin pod
=head2 rectangle($x1, $y1, $x2, $y2, :$color, $clear)

Place or clear a rectangle of pixels from x1/y1 to x2/y2 corners

=end pod

  method rectangle($x1, $y1, $x2, $y2, :$color, :$clear) {
    for $y1..$y2 -> $ty {
      for $x1..$x2 -> $tx {
         self.pixel($tx, $ty, :$color, :$clear);
      }
    }
  }

=begin pod
=head2 text($text, $x, $y, :$color, $bold, $bg)

Place some text, starting at the x/y coordonates.

$color is the color of the text

$bg is the color of the background

=end pod

  method text($text, $x, $y, :$color is copy, :$bold, :$italic, :$bg) {
    my @letters = $text.comb;
    $color //= '';
    for ^@letters.elems -> $pos {
      my $v = '';
      my $bg2 = $bg;
      my $letter = @letters[$pos];
      my $pixel := @!canvas[$y][$x + $pos];
      self.pixel($x + $pos, $y, :color($1)) if $pixel ~~ /\x03(\d?)","(\d)/;
      $bg2 //= $1;
      $bg2 //= '';
      $v = ',' if $bg or $pixel ne " ";
      #Bolt alone
      if $bold and !$color and !$italic {
        $pixel .= subst(/\s/, "\x02$letter\x02");
      }
      #bold and color
      if $bold and $color and !$italic {
        ($bg2, $color, $letter) = correct-num($bg2, $color, $letter).list and 
        $pixel = "\x03{$color}{$v}{$bg2}\x02$letter\x02\x03";
      }
      #color only
      if !$bold and $color and !$italic { 
        ($bg2, $color, $letter) = correct-num($bg2, $color, $letter).list and 
        $pixel = "\x03{$color}{$v}{$bg2}$letter\x03";
      }
      if (!$bold and !$color) {
        ($bg2, $color, $letter) = correct-num($bg2, $color, $letter).list and 
        $pixel = "\x03{$v}{$bg2}$letter\x03";
      }
      #Just text FIXME
      if (!$bold and !$bg and !$color and !$italic) {
         ($bg2, $color, $letter) = correct-num($bg2, $color, $letter).list and 
         $pixel = $letter;
      }
      #single digit number must be corrected to 0x in some case
      sub correct-num(*@a) {
        my @t = @a;
        @t[0] = "0@t[0]" if @t[0] ~~ /^\d$/ and @t[2] ~~ /^\d$/;
        @t[1] = "0@t[1]" if @t[1] ~~ /^\d$/ and @t[2] ~~ /^\d$/;
        return @t;
      }
    }
  }
 
=begin pod
=head2 save($filename) load($filename)

Save the canvas in a Perl 6. Use load to load it.

=end pod

  method save(Str $file) {
    my $fh = open $file, :w;
    $fh.print(@!canvas.perl);
    $fh.close;
  }
  
use MONKEY-SEE-NO-EVAL;

  method load(Str $file) {
    my $data = slurp $file;
    @!canvas = EVAL($data);
  }
}

=begin pod
=head1 Colors

These color are mainly indicative, it depends too much on the irc client configuration.

 0 : light grey
 1 : Black
 2 : Dark Blue
 3 : Dark Green
 4 : Red
 5 : Dark red
 6 : Violet
 7 : Orange
 8 : Yellow
 9 : Light Green
 10 : Dark light blue
 11 : Lighter blue
 12 : Blue
 13 : Pink
 14 : Dark Grey
 15 : Grey
 
=end pod