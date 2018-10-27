use v6;

class String::Koremutake:ver<0.1> {

  my @phonemes = <ba be bi bo bu by da de di do du dy fa fe fi
    fo fu fy ga ge gi go gu gy ha he hi ho hu hy ja je ji jo ju jy ka ke
    ki ko ku ky la le li lo lu ly ma me mi mo mu my na ne ni no nu ny pa
    pe pi po pu py ra re ri ro ru ry sa se si so su sy ta te ti to tu ty
    va ve vi vo vu vy bra bre bri bro bru bry dra dre dri dro dru dry fra
    fre fri fro fru fry gra gre gri gro gru gry pra pre pri pro pru pry
    sta ste sti sto stu sty tra tre>;

  my (%phoneme_to_number,  %number_to_phoneme);

  my $number = 0;
  for @phonemes -> $phoneme  {
    %phoneme_to_number{$phoneme} = $number;
    %number_to_phoneme{$number}  = $phoneme;
    $number++;
  }

  method !numbers-to-koremutake($numbers) {
    my $string;
    for @$numbers -> $n {
      fail "0 <= $n <= 127" unless (0 <= $n) && ($n <= 127);
      $string ~= %number_to_phoneme{$n};
    }
    return $string;
  }

  method !koremutake-to-numbers($string) {
    my @numbers;
    my $phoneme;
    my @chars = $string.split('');

    while ( @chars ) {
      $phoneme ~= shift @chars;
      next unless $phoneme ~~ /<[aeiouy]>/;
      my $number = %phoneme_to_number{$phoneme};
      fail "Phoneme $phoneme not valid" unless defined $number;
      @numbers.push($number);
      $phoneme = "";
    }

    return @numbers; 

  }

  method integer-to-koremutake(Int:D $integer is copy) {
    my @numbers;
    @numbers = (0) if $integer == 0;

    while ($integer != 0) {
      @numbers.push( $integer % 128);
      $integer = floor($integer/128);
    }

    return self!numbers-to-koremutake([reverse @numbers]);
  }

  method koremutake-to-integer(Str:D $string) {
    my $numbers = self!koremutake-to-numbers($string);
    my $integer = 0;

    for @$numbers -> $number {
      $integer = ($integer * 128) + $number;
    }

    return $integer;
  }
}
# vim: filetype=perl6:
