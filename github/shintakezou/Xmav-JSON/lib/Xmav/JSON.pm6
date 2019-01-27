use v6.c;
unit module Xmav::JSON;

use Xmav::JSON::Grammar;
use Xmav::JSON::Actions;

sub from-json(Str $input) is export {
    my $match = Xmav::JSON::Grammar.parse($input,
					  :actions(Xmav::JSON::Actions))
    or die "malformed JSON?";

    return $match.made;
}
