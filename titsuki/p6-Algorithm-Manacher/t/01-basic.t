use v6;
use Test;
use Algorithm::Manacher;

lives-ok { my $manacher = Algorithm::Manacher.new(text => "") };
lives-ok { my $manacher = Algorithm::Manacher.new(text => "aaa") };
dies-ok { my $manacher = Algorithm::Manacher.new(text => 1234) };

done-testing;
