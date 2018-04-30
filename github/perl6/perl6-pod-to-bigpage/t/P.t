use v6;

use lib <lib ../lib>;

use Test;
use Test::When <online>;
use Pod::To::BigPage;

plan 1;

=begin pod
=head1 This is the head
P<./t/hello-camelia.txt>
P<http://http.perl6.org/robots.txt>
=end pod

my $ok-result = q:to/EOH/;
 <h1 id="_routine_test.pod6-This_is_the_head_./t/hello-camelia.txt_http://http.perl6.org/robots.txt">This is the head <pre>Hello Camelia!
</pre> <pre>User-Agent: *
Disallow: /page-stats
</pre></h1>
EOH

is $=pod>>.&handle(pod-name => 'test.pod6', toc-counter => TOC-Counter.new , part-number => 1), $ok-result, 'relative path'
