
use Duo;

unit module Duo::Util;

sub       duo(|c) is export { Duo.new(|c) }
sub infix:<→>(|c) is export { Duo.new(|c) }

# vim: ft=perl6
