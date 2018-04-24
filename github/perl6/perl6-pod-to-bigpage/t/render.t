use v6;

use lib <lib ../lib>;

use Test;
use Test::When <online>;
use Pod::To::BigPage;

# Test the rendering of a full page
plan 3;

=begin pod

=head1 This is the head

=head2 More stuff here

And just your average text.
=end pod

setup();

# Tests start here
like compose-before-content($=pod), /This\s+is\s+the\s+head/, "Head inserted";
like compose-before-content($=pod, 'x'), /xml \s+ version/, "Head with xml inserted";
like compose-before-content($=pod, ''), /DOCTYPE \s+ html/, "Head with html inserted";

