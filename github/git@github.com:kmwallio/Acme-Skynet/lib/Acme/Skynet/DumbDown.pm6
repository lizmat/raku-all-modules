use v6;
use Lingua::EN::Stem::Porter;
=begin pod

=head1 NAME

Acme::Skynet::DumbDown

=head1 DESCRIPTION

Acme::Skynet::DumbDown converts a word or sentence into an easier to
understand format.  It remove plurals and attempts to identify the
root of a word.

=head2 Examples

    use Acme::Skynet::DumbDown;

    # Single world
    say dumber('cats'); # => cat

    # Sentence
    say dumber('he eats cats'); # => 'he eat cat'

    # Decontract
    say extraDumber("what's up") # => 'what is up'

=head2 ACKNOWLEDGEMENTS

Acme::Skynet::DumbDown is currently a wrapper around
Lingua::EN::Stem::Porter adding support for sentences.

=end pod

module Acme::Skynet::DumbDown {
  sub deContract(Str $word)
  {
    my $dumbWord = $word;
    $dumbWord ~~ s:g/can\'t/cannot/;
    $dumbWord ~~ s:g/won\'t/will not/;
    $dumbWord ~~ s:g/n\'t/ not/;
    $dumbWord ~~ s:g/\'re/ are/;
    $dumbWord ~~ s:g/\'ll/ will/;
    $dumbWord ~~ s:g/\'ve/ have/;
    $dumbWord ~~ s:g/\'d/ would/;
    $dumbWord ~~ s:g/\'s/ is/;
    $dumbWord ~~ s:g/o\'clock/of the clock/;
    return $dumbWord;
  }

  sub dumber(Str $phrase) is export
  {
    $phrase.split(/\s+/).map({ porter($^word) }).join(' ');
  }

  sub dumbdown(Str $phrase) is export {
    dumber($phrase);
  }

  sub labeledDumbdown(Str $phrase) is export {
    my @original;
    my @dumbed;
    for $phrase.split(/\s+/) -> $word {
      @original.push($word);
      @dumbed.push(dumbdown($word));
    }

    return @original, @dumbed;
  }

  sub extraDumber(Str $phrase) is export {
    my $dumbPhrase = $phrase;
    $dumbPhrase ~~ s:g/in\s+to/into/;
    $dumbPhrase.split(/\s+/).map({ dumber(deContract($^word)) }).join(' ');
  }

  sub extraDumbedDown(Str $phrase) is export {
    extraDumber($phrase);
  }

  sub labeledExtraDumbedDown(Str $phrase) is export {
    my @original;
    my @dumbed;
    my $dumbPhrase = $phrase;
    $dumbPhrase ~~ s:g/in\s+to/into/;
    for $dumbPhrase.split(/\s+/) -> $word {
      @original.push($word);
      @dumbed.push(extraDumber($word));
    }

    return @original, @dumbed;
  }
}
