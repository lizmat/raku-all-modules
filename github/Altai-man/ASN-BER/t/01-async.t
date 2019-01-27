use ASN::Types;
use ASN::Parser::Async;
use Test;

enum Fuel <Solid Liquid Gas>;

class SpeedChoice does ASNChoice {
    method ASN-choice() {
        { mph => (1 => Int), kmph => (0 => Int) }
    }
}

class Rocket does ASNSequence {
    has Str $.name is UTF8String;
    has Str $.message is UTF8String is default-value("Hello World") is optional;
    has Fuel $.fuel;
    has SpeedChoice $.speed is optional;
    has Str @.payload is UTF8String;

    method ASN-order() {
        <$!name $!message $!fuel $!speed @!payload>
    }
}

my $rocket-ber = Buf.new(
        0x30, 0x1B,
        0x0C, 0x06, 0x46, 0x61, 0x6C, 0x63, 0x6F, 0x6E,
        0x0A, 0x01, 0x00,
        0x81, 0x02, 0x46, 0x50, 0x30, 0x0A,
        0x0C, 0x03, 0x43, 0x61, 0x72,
        0x0C, 0x03, 0x47, 0x50, 0x53, # First rocket
        0x30, 0x1B,
        0x0C, 0x06, 0x46, 0x61, 0x6C, 0x63, 0x6F, 0x6E,
        0x0A, 0x01, 0x00,
        0x81, 0x02, 0x46, 0x50, 0x30, 0x0A,
        0x0C, 0x03, 0x43, 0x61, 0x72,
        0x0C, 0x03, 0x47, 0x50); # Second one

my $parser = ASN::Parser::Async.new(type => Rocket);

my $counter = 0;
my $p = Promise.new;

$parser.values.tap({ $counter++; $p.keep if $counter ~~ 2 });

$parser.process($rocket-ber);
$parser.process(Buf.new(0x53));

await Promise.anyof([$p, Promise.in(5)]);

$parser.close;
ok $p.status ~~ Kept, "Parsed two rockets";

done-testing;
