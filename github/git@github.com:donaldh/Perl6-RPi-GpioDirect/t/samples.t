use v6;
use Test;

plan 6;

my $display = qq:x{$*EXECUTABLE -Ilib samples/display.pl};
is +$display.lines, 29, 'display.pl';
ok $display ~~ /GPIO\.21/, 'display.pl has valid output';

my $write = qq:x{$*EXECUTABLE -Ilib samples/write.pl};
is +$write.lines, 11, 'write.pl';
ok $write ~~ /GPIO\.18/, 'write.pl has valid output';

my $pud = qq:x{$*EXECUTABLE -Ilib samples/pud.pl};
is +$pud.lines, 9, 'pud.pl';
ok $pud ~~ /GPIO\.18/, 'pud.pl has valid output';
