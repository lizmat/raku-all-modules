module Algorithm::Elo {
    my $k = 32;

    my sub do-it(Int $delta) {
        return 1 / (1 + (10 ** ($delta / 400)));
    }

    our sub calculate-elo(Int $left, Int $right, Bool :left($left-wins), Bool :right($right-wins), Bool :$draw) is export {
        unless $left-wins^$right-wins^$draw {
            die ':left, :right, and :draw are mutually exclusive';
        }

        unless $left-wins|$right-wins|$draw {
            die 'exactly least one of :left, :right, or :draw must be specified';
        }

        my $expected-left  = do-it($right - $left);
        my $expected-right = do-it($left - $right);

        my $left-multiplier  = $left-wins ?? 1 !! ($right-wins ?? 0 !! 0.5);
        my $right-multiplier = 1 - $left-multiplier;

        return (
            round($left  + $k * ($left-multiplier  - $expected-left)),
            round($right + $k * ($right-multiplier - $expected-right)),
        );
    }
}

=begin pod

=head1 NAME

Algorithm::Elo

=head1 AUTHOR

Rob Hoelz <rob AT hoelz.ro>

=head1 SYNOPSIS

    use Algorithm::Elo;

    my ( $player-a-score, $player-b-score ) = 1_600, 1_600;

    ( $player-a-score, $player-b-score ) = calculate-elo($player-a-score, $player-b-score, :left);

=head1 DESCRIPTION

This module implements the Elo rating system, commonly used to rate chess players.

=head1 FUNCTIONS

=head2 calculate-elo(Int $left, Int $right, :left, :right, :draw)

Given two current ratings and the result of a match (C<:left> if the left
player wins, C<:right> if the right player wins, C<:draw> for a draw), return
two new ratings for the left and right players.

=head1 SEE-ALSO

L<Elo Rating System|https://en.wikipedia.org/wiki/Elo_rating_system>

=head1 LICENSE

Copyright (c) 2015 <rob AT hoelz.ro>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=end pod
