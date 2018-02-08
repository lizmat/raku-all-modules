use v6;

unit module Voicer;
use ScaleVec;
use Result;
use Result::Imports;

# A simplistic voicing allocator which returns a Seq of ScaleVec steps, high to low.
# The bass voice will be allocated at the end.
# The rest of the voices will be allocated high to low from the melody note.
# If there isn't enough room for a unique note per voice, notes will be doubled up starting from the top.
# The ordering of the two space parameters does not matter.
# Any voice-count values less than 2 will only return the specified bass step.
sub voicing(ScaleVec $sv, Numeric $melody, Numeric $bass, Int $voice-count --> Seq) is export {
  my ($melody-step, $bass-step) = ($melody, $bass).map: { $sv.reflexive-step($_).round }
  my $space = $melody-step - $bass-step;
  
  sort { $^b <=> $^a }, gather {
    for ^($voice-count - 1) -> $n {
      if $space == 0 {
        # If there is no space there is only one option and we cannot mod by 0
        take $melody-step;
      }
      else {
        take $melody-step - ($n % $space)
      }
    }
    take $bass-step;
  }
}
