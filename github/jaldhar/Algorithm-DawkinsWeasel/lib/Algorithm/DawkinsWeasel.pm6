use v6.c;

unit class Algorithm::DawkinsWeasel:ver<0.1.1>;

has Str @.target-phrase;
has Rat $.mutation-threshold;
has Int $.copies;

has Str @!charset;
has Int $!count;
has Str @!current-phrase;
has Int $!hi-score;

submethod BUILD(Str :$target-phrase = 'METHINKS IT IS LIKE A WEASEL',
Rat :$mutation-threshold = 0.05, Int :$copies = 100) {
    @!target-phrase = $target-phrase.comb;
    $!mutation-threshold = $mutation-threshold;
    $!copies = $copies;
}

submethod TWEAK {
    @!charset  = | ['A' .. 'Z'] , ' ';
    @!current-phrase = @!charset.roll: @!target-phrase.elems;
    $!hi-score = 0;
    $!count = 0;
}

method !evolve {
    $!count++;

    for (1 .. $!copies) {
        my @trial = @!current-phrase.map: {
            rand < $!mutation-threshold ?? @!charset.roll !! $_;
        };

        my Int $score = [+] @!target-phrase Zeq @trial;

        if $score > $!hi-score {
            $!hi-score = $score;
            @!current-phrase = @trial;
        }
    }

    return $!hi-score == @!target-phrase.elems;
}

method evolution {
    return gather {
        repeat {
            take self;
        } until self!evolve;
        take self;  # for the last round
    };
}

method count {
    return $!count;
}

method current-phrase {
    return @!current-phrase.join('');
}

method hi-score {
    return $!hi-score;
}

method target-phrase {
    return @!target-phrase.join('');
}

=begin pod

=head1 NAME

Algorithm::DawkinsWeasel - An Illustration of Cumulative Selection

=head1 SYNOPSIS

  use Algorithm::DawkinsWeasel;

  my $weasel = Algorithm::DawkinsWeasel.new(
    target-phrase      => 'METHINKS IT IS LIKE A WEASEL',
    mutation-threshold => 0.05,
    copies             => 100,
  );
    
  for $weasel.evolution {
    say .count.fmt('%04d '), .current-phrase, ' [', .hi-score, ']';
  }

=head1 DESCRIPTION

Algorithm::DawkinsWeasel is a simple model illustrating the idea of cumulative
selection in evolution.

The original form of it looked like this:

  1. Start with a random string of 28 characters.
  2. Make 100 copies of this string, with a 5% chance per character of that
     character being replaced with a random character.
  3. Compare each new string with "METHINKS IT IS LIKE A WEASEL", and give
     each a score (the number of letters in the string that are correct and
     in the correct position).
  4. If any of the new strings has a perfect score (== 28), halt.
  5. Otherwise, take the highest scoring string, and go to step 2

This module parametrizes the target string, mutation threshold, and number of
copies per round.

=head1 METHODS

=head2 new(target-phrase => Str, mutation-threshold => Rat, copies => Int)

  Creates a new Algorithm::DawkinsWeasel object.

=item target-phrase

  A string of characters in the set A-Z plus spaces.  This defaults to
  "METHINKS IT IS LIKE A WEASEL"

=item mutation-threshold

  The percentage chance per round that a character in the phrase will "mutate",
  i.e will change to another random character, expressed as a rational number
  between 0 and 1.  This defaults to 0.05 (5%).

=item copies

  The amount of copies of the phrase which will be made in each round.  This
  defaults to 100.

=head2 Seq evolution()

  This is the main method in this class.  Each iteration of the returned
  sequence represents one round of the algorithm until the target phrase is
  reached.

=head2 Int copies()

  Returns the number of copies of the phrase made in each round as set in the
  constructor.

=head2 Int count()

  Returns the number of rounds of the algorithm which have taken place.

=head2 Str current-phrase()

  Returns the current state of the phrase including any mutations that have
  taken place.

=head2 Int hi-score()

  During each round of the algorithm, each copy of the current phrase will be
  given a score of +1 for every letter which is the same as the similarly
  placed letter in the target phrase.  This method will return the value of
  the highest score.  When the high score equals the length of the target
  phrase, you will know the algorithm has ended successfully.

=head2 Rat mutation-threshold()

  Returns the percentage chance of a letter mutating per round as set in the
  constructor.

=head2 Str target-phrase()

  Returns the phrase the algorithm is trying to evolve towards as set in the
  constructor.

=head1 SEE ALSO

L<Weasel Program at Wikipedia|https://en.wikipedia.org/wiki/Weasel_program>

=head1 AUTHOR

Jaldhar H. Vyas <jaldhar@braincells.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017, Consolidated Braincells Inc.  All rights reserved.

This distribution is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 2, or (at your option) any later version, or

b) the Artistic License version 2.0.

The full text of the license can be found in the LICENSE file included
with this distribution.

=end pod
