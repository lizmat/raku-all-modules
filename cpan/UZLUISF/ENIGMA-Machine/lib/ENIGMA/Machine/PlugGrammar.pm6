unit module ENIGMA::Machine::PlugGrammar;

grammar HK-Syntax is export {
    token TOP     { [ <numpair> * % ' ' ] | [ <alppair> * % ' ' ] | '' } 
    token numpair { (<number>) <sep> (<number>)  }
    token alppair { (<letter>) <sep> (<letter>) }
    token sep     { '/' || '' }
    token letter  { <[A..Z]> }
    token number  { [ 2 <[0..6]> || 1 \d || <[1..9]> ] }
}

grammar ZB-Syntax is HK-Syntax is export {
   token number  { [2 <[0..5]> || 1 \d || \d ] }
}

class PLUGB-actions is export {
    method TOP($/)     { make [
                              $<alppair>.map(*.made) or 
                              $<numpair>.map(*.made)
                              ] 
                       }
    method numpair($/) { make (+$/[0], +$/[1]) }
    method alppair($/) { make ($/[0].Str, $/[1].Str) }
    method number($/)  { make +$/ }
    method letter($/)  { make ~$/ }
}



=begin pod
=NAME ENIGMA::Machine::PlugGrammar

=SYNOPSIS
=begin code
use v6;
use ENIGMA::Machine::PlugGrammar;

my $pb-h-match = HK-Syntax.parse(
    'CO RN IS', :actions(PLUGB-actions.new())
);

my $pb-k-match = HK-Syntax.parse(
    '1/2 3/26', actions => PLUGB-actions.new()
);
=end code

=DESCRIPTION

C<ENIGMA::Machine::PlugGrammar> is a very simple Perl 6 grammar to parse
a plugboard setting. 

The C<HK-Syntax> grammar can parse these two styles:
=begin item
Heer/Luftwaffe

A string of uppercase alphabetical pairs separated by space. 
For example, 'CO RN IS GX EA TH'.
=end item

=begin item
Kriegsmarine

A string of numeric pairs (1-26) separated by spaces, where the elements of a given 
pair are separated by '/'. For example, '3/15 18/14 9/19 7/25 5/1 20/8'.
=end item


=begin item
The C<ZB-Syntax> grammar is just a zero-based C<HK-Syntax> grammar used to parse
the wiring connection passed to the C<new> constructor. If 
'[(3, 15), (18, 14), (9, 19), (7, 25), (5, 1), (20, 8)]' is passed, then it must
be expressed in either in the Kriegsmarine or H/L style. The result (for example, 
'2/14 17/13 8/18 6/24 4/0 19/7') can then be parsed with C<ZB-Syntax>.
=end item

=para
The three previous example represents the same setting for a plugboard.
=end pod


