use v6;
use Test;

use lib 'lib';

plan 7;

use Email::MIME;

my $mail-text = slurp 't/test-mails/nested-parts';

my $eml = Email::MIME.new($mail-text);
ok $eml.parts.isa('Array'), 'Got an array (has parts)';
is +$eml.parts, 1, 'outer part';

my @outer-parts = $eml.parts;
is +@outer-parts[0].parts, 1, 'middle part';

my @middle-parts = @outer-parts[0].parts;
ok +@middle-parts[0].parts > 1, 'inner part';

ok @middle-parts[0].parts[0].body-str ~~ /HELLO/, 'found the hello';

$eml.walk-parts({
        if $_.body-str ~~ /HELLO/ {
            ok True, 'Found a HELLO in walk-parts (should be 2 of these)';
        }
    });
