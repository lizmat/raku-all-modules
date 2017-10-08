use Test;
use Pod::To::HTML;
plan 1;

=begin pod
X<|behavior> L<http://www.doesnt.get.rendered.com>
=end pod

my $r = pod2html $=pod, :url({ $_ });
ok $r ~~ m/'href="http://www.doesnt.get.rendered.com"'/;

