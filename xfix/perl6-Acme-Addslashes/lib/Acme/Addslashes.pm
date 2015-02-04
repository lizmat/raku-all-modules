module Acme::Addslashes;
sub addslashes(Cool $string is copy) is export {
    $string = ~$string;
    $string ~~ s:g/(.)/$0\c[COMBINING LONG SOLIDUS OVERLAY]/;
    $string;
}
