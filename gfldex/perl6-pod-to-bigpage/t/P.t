use v6;
use Test;
use Pod::To::BigPage;

plan 1;

=begin pod
P<./t/hello-camelia.txt>
P<http://perl6.org/robots.txt>
=end pod

my $ok-result = q:to/EOH/;
<p><pre>Hello Camelia!
</pre> <pre>User-Agent: *
Disallow: /page-stats
</pre></p>
EOH

is $=pod>>.&handle(part-number => 1), $ok-result, 'relative path'
