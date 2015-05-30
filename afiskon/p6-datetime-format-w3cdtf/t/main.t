use v6;
use lib 'lib';
use Test;
use DateTime::Format::W3CDTF;

my $w3c = DateTime::Format::W3CDTF.new;

dies-ok({ $w3c.parse('bebebe') });
dies-ok({ $w3c.parse('999') });

ok($w3c.parse('2012').Str eq '2012-01-01T00:00:00Z');
ok($w3c.parse('0001').Str eq '0001-01-01T00:00:00Z');
dies-ok({ $w3c.parse('2012Z') });
dies-ok({ $w3c.parse('2012+1234') });

ok($w3c.parse('2012-02').Str eq '2012-02-01T00:00:00Z');
dies-ok({ $w3c.parse('2012-13') });
dies-ok({ $w3c.parse('2012-1') });
dies-ok({ $w3c.parse('2012-12Z') });
dies-ok({ $w3c.parse('2012-12+1234') });

ok($w3c.parse('2012-02-03').Str eq '2012-02-03T00:00:00Z');
dies-ok({ $w3c.parse('2012-1-01') });
dies-ok({ $w3c.parse('2012-01-2') });
dies-ok({ $w3c.parse('2012-13-01') });
dies-ok({ $w3c.parse('2012-01-32') });
dies-ok({ $w3c.parse('2012-02-03Z') });
dies-ok({ $w3c.parse('2012-02-03+1234') });

dies-ok({ $w3c.parse('1988-12-13:14') });
dies-ok({ $w3c.parse('1988-12-13:14Z') });
dies-ok({ $w3c.parse('1988-12-13:14+1234') });

ok($w3c.parse('1988-12-13T14:15Z').Str eq '1988-12-13T14:15:00Z');
ok($w3c.parse('1988-12-13T14:15+04:30').Str eq '1988-12-13T14:15:00+04:30');
ok($w3c.parse('1988-12-13T14:15-02:20').Str eq '1988-12-13T14:15:00-02:20');
dies-ok({ $w3c.parse('1988-12-13:14:15') });
dies-ok({ $w3c.parse('1988-12-13:14:15+1234') });
dies-ok({ $w3c.parse('1988-1-13:14:15Z') });
dies-ok({ $w3c.parse('1988-12-1:14:15Z') });
dies-ok({ $w3c.parse('1988-12-13:1:15Z') });
dies-ok({ $w3c.parse('1988-12-13:14:1Z') });
dies-ok({ $w3c.parse('1988-13-13:14:15Z') });
dies-ok({ $w3c.parse('1988-12-32:14:15Z') });
dies-ok({ $w3c.parse('1988-12-13:25:15Z') });
dies-ok({ $w3c.parse('1988-12-13:14:61Z') });

ok($w3c.parse('1988-12-13T14:15:16Z').Str eq '1988-12-13T14:15:16Z');
ok($w3c.parse('1988-12-13T14:15:16+01:00').Str eq '1988-12-13T14:15:16+01:00');
ok($w3c.parse('1988-12-13T14:15:16-02:30').Str eq '1988-12-13T14:15:16-02:30');
dies-ok({ $w3c.parse('1988-12-13T14:15:16') });
dies-ok({ $w3c.parse('1988-12-13T14:15:16+1234') });
dies-ok({ $w3c.parse('1988-13-13T14:15:16Z') });
dies-ok({ $w3c.parse('1988-12-32T14:15:16Z') });
dies-ok({ $w3c.parse('1988-12-13T25:15:16Z') });
dies-ok({ $w3c.parse('1988-12-13T14:61:16Z') });
dies-ok({ $w3c.parse('1988-12-13T14:15:61Z') });

ok($w3c.parse('1988-12-13T14:15:16.1Z').Str eq '1988-12-13T14:15:16Z');
ok($w3c.parse('1988-12-13T14:15:16.123456789+01:30').Str eq '1988-12-13T14:15:16+01:30');
ok($w3c.parse('1988-12-13T14:15:16.123456789-02:40').Str eq '1988-12-13T14:15:16-02:40');
dies-ok({ $w3c.parse('1988-12-13T14:15:16.123456789') });
dies-ok({ $w3c.parse('1988-12-13T14:15:16.123456789+0130') });

ok($w3c.format(DateTime.new('2012-04-05T06:07:08+1234')) eq '2012-04-05T06:07:08+12:34');
ok($w3c.format(DateTime.new('2012-04-05T06:07:08-1234')) eq '2012-04-05T06:07:08-12:34');
ok($w3c.format(DateTime.new('2012-04-05T06:07:08+0000')) eq '2012-04-05T06:07:08Z');

done;

