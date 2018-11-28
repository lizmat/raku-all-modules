use v6.c;

my $color-support;
try require ::('Color');
$color-support = ::('Color') !~~ Failure;

class RandomColor {
  has $!seed;
  has %!colorDict;
  has @.list;

  method BUILD(*%options) {
    for %options.keys {
      die "Invalid option '$_'"
        unless $_ eq <hue luminosity count seed format alpha>.any;
    }

    if %options<format>:exists {
      die "A format value of 'color' requires the 'Color' Perl6 module"
        unless %options<format> ne 'color' || $color-support;
    }

    if %options<seed>:exists {
      die 'The seed value must be an integer' unless %options<seed> ~~ Int;
      $!seed = %options<seed>;
    }
    if %options<count>:exists {
      die 'The options value must be an integer'
        unless %options<count> ~~ Int;
    }

    self.loadColorBounds;

    my $oldSeed = $!seed;
    for ^(%options<count> // 1) {
      with $!seed { $!seed++  if $_ }
      my $h = self.pickHue(%options);
      my $s = self.pickSaturation($h, %options);
      my $v = self.pickBrightness($h, $s, %options);
      @!list.push: self.setFormat( [$h, $s, $v], %options );
    }
    $!seed = $oldSeed;
  }

  method pickHue(%options) {
    my $hue = self.randomWithin( |self.getHueRange(%options<hue>) );
    $hue = 360 + $hue if $hue < 0;
    $hue;
  }

  method pickSaturation($h, %options) {
    return 0            if (%options<hue> // '')        eq 'monochrome';
    return (0..99).pick if (%options<luminosity> // '') eq 'random';

    my $saturationRange = self.getSaturationRange($h);
    my ($sMin, $sMax) = ($saturationRange.min, $saturationRange.max);
    given %options<luminosity> {
      when 'bright' { $sMin = 55         }
      when 'dark'   { $sMin = $sMax = 10 }
      when 'light'  { $sMax = 55         }
    }
    self.randomWithin($sMin, $sMax);
  }

  method pickBrightness($h, $s, %options) {
    my ($bMin, $bMax) = ( self.getMinimumBrightness($h, $s), 100 );

    given %options<luminosity> {
      when 'dark'   { $bMin = $bMax = 20          }
      when 'light'  { $bMin = ($bMin + $bMax) / 2 }
      when 'random' { ($bMin, $bMax) = (0, 100)   }
    }

    self.randomWithin($bMin, $bMax);
  }

  method setFormat($hsv, %options) {
    do given %options<format> {
      when 'hsvarray'   { $hsv                             }
      when 'hslarray'   { self.HSVtoHSL($hsv)              }
      when 'hsl'        { my $hsl = self.HSVtoHSL($hsv);
                          "hsl({ $hsl.join(', ') })"       }
      when 'hsla'       { my $hsl = self.HSVtoHSL($hsv);
                          my $a = %options<alpha> // rand;
                          "hsla({ $hsl.join(', ') }, $a)"  }
      when 'rgbarray'   { self.HSVtoRGB($hsv)              }
      when 'rgb'        { my $rgb = self.HSVtoRGB($hsv);
                          "rgb({ $rgb.join(', ') })"       }
      when 'rgba'       { my $rgb = self.HSVtoRGB($hsv);
                          my $a = %options<alpha> // rand;
                          "rgba({ $rgb.join(', ') }, $a)"  }
      when 'color'      { ::('Color').new( hsv => $hsv )   }
      default           { self.HSVtoHex($hsv)              }
    }
  }

  method getMinimumBrightness($h, $s) {
    my $lowerBounds = self.getColorInfo($h)<lowerBounds>;

    for ^($lowerBounds.elems - 1) {
      my ($s1, $v1) = $lowerBounds[$_];
      my ($s2, $v2) = $lowerBounds[$_ + 1];

      if $s1 <= $s <= $s2 {
        my $m = ($v2 - $v1) / ($s2 - $s1);
        my $b = $v1 - $m * $s1;
        return $m * $s + $b
      }
    }
    0;
  }

  method getHueRange($colorInput) {
    given $colorInput {
      when Int {
        return ($_, $_) if 0 < $_ < 100;
      }

      when Str {
        return %!colorDict{$_}<hueRange> if %!colorDict{$_}:exists;
        if m:i/^ '#'? ( <xdigit> ** 3 | <xdigit> ** 6 ) $/ {
          return ($/[0], $/[0]);
        }
      }
    }
    (0, 360);
  }

  method getSaturationRange($h) {
    self.getColorInfo($h)<saturationRange>;
  }

  method getColorInfo($h is copy) {
    $h -= 360 if 334 <= $h <= 360;
    for %!colorDict.keys {
      next without %!colorDict{$_}<hueRange>;
      my $c = %!colorDict{$_};
      return $c if $c<hueRange>[0] <= $h <= $c<hueRange>[1];
    }
    return 'Color not found'
  }

  method randomWithin(*@range) {
    do with $!seed {
      my ($min, $max) = ( @range[0] // 0, @range[1] // 1 );
      $!seed = ($!seed * 9301 + 49297) % 233280;
      ($min + ($!seed / 233280) * ($max - $min)).floor
    } else {
      (@range[0]..@range[1]).pick;
    }
  }

  method HSVtoHex($hsv) {
    my @rgb = self.HSVtoRGB($hsv);
    "#{ @rgb.map( *.fmt('%02x') ).join() }"
  }

  method defineColor($name, $hueRange, $lowerBounds) {
    %!colorDict{$name} = {
      hueRange        => $hueRange,
      lowerBounds     => $lowerBounds,
      saturationRange => ($lowerBounds[0][0], $lowerBounds[*-1][0]),
      brightnessRange => ($lowerBounds[*-1][1], $lowerBounds[0][1]);
    };
  }

  method loadColorBounds {
    self.defineColor('monochrome', Nil, [ [0, 0], [100, 0] ]),
    self.defineColor('red',     [-26, 18], [
      [20, 100],  [30, 92], [40, 89], [50, 85], [60, 78], [70, 70],
      [80, 60],   [90, 55], [100, 50]
    ]);
    self.defineColor('orange',   [19, 46], [
      [20,100],   [30, 93], [40, 88], [50, 86], [60, 85], [70, 70],
      [100,70]
    ]);
    self.defineColor('yellow',   [47, 62], [
      [25, 100],  [40, 94], [50, 89], [60, 86], [70, 84], [80, 82],
       [90, 80], [100, 75]
    ]);
    self.defineColor('green',   [63, 178], [
      [30, 100],  [40, 90], [50, 85], [60, 81], [70, 74], [80, 64],
       [90, 50], [100, 40]
    ]);
    self.defineColor('blue',   [179, 257], [
      [20, 100], [30, 86],  [40, 80], [50, 74], [60, 60], [70, 52],
       [80, 44], [90, 39], [100, 35]
    ]);
    self.defineColor('purple', [258, 282], [
      [20, 100], [30, 87],  [40, 79], [50, 70], [60, 65], [70, 59],
       [80, 52], [90, 45], [100, 42]
    ]);
    self.defineColor('pink',   [283, 334], [
      [20, 100], [30, 90], [ 40, 86], [60, 84], [80, 80], [90, 75],
      [100, 73]
    ]);
  }

  method HSVtoRGB($hsv) {
    my ($h, $s, $v) = ($hsv[0], $hsv[1] / 100, $hsv[2] / 100);

    $h = 1   if $h === 0;
    $h = 359 if $h === 360;
    $h /= 360;

    my $h_i = ($h * 6).floor;
    my $f = $h * 6 - $h_i;
    my $p = $v * (1 - $s);
    my $q = $v * (1 - $f * $s);
    my $t = $v * (1 - (1 - $f) * $s);
    my ($r, $g, $b) = (256 xx 3);

    given $h_i {
      when 0 { ($r, $g, $b) = ($v, $t, $p) }
      when 1 { ($r, $g, $b) = ($q, $v, $p) }
      when 2 { ($r, $g, $b) = ($p, $v, $t) }
      when 3 { ($r, $g, $b) = ($p, $q, $v) }
      when 4 { ($r, $g, $b) = ($t, $q, $v) }
      when 5 { ($r, $g, $b) = ($v, $p, $q) }
    }

    (($r, $g, $b) »*« (255 xx 3)).map( *.floor ).List;
  }

  method HexToHSB($hex is copy) {
    $hex ~~ s/^ '#'//;
    $hex ~= $hex if $hex.chars == 3;
    my $red   = "0x{ $hex.substr(0, 2) }".Int div 255;
    my $green = "0x{ $hex.substr(2, 2) }".Int div 255;
    my $blue  = "0x{ $hex.substr(4, 2) }".Int div 255;

    my $cMax = ($red, $green, $blue).max;
    my $delta = $cMax - ($red, $green, $blue).min;
    my $saturation = $cMax ?? ($delta / $cMax) !! 0;

    do given $cMax {
      when $red {
        ( 60 * ((($green - $blue) / $delta) % 6) || 0, $saturation, $cMax )
      }

      when $green {
          ( 60 * ((($blue - $red) / $delta) + 2) || 0, $saturation, $cMax )
      }

      when $blue {
         ( 60 * ((($red - $green) / $delta) + 4) || 0, $saturation, $cMax )
      }
    }
  }

  method HSVtoHSL ($hsv) {
    my ($h, $s, $v) = ($hsv[0], $hsv[1] / 100, $hsv[2] / 100);
    my $k = (2 - $s) * $v;

    (
      $h,
      (0.5 + ($s * $v / ($k < 1 ?? $k !! 2 - $k) * 10000)).floor / 100,
      $k / 2 * 100
    )
  }
}
