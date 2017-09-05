use v6;
use Test;

use Number::More :ALL;

$Number::More::LENGHT-HANDLING = 'waRn';

plan 32;

my $prefix = True;
my $LC     = True;

my $msg1 = ":\$prefix arg not allowed for conversion to decimal";
my $msg2 = ":\$LC arg not allowed for conversion to anything but hexadecimal";

# error conditions
dies-ok { hex2dec('ff', :$prefix), 255; }, $msg1;
dies-ok { hex2dec('ff', 2, :$prefix), '255'; }, $msg1;
dies-ok { bin2dec('11', :$prefix), 3; }, $msg1;
dies-ok { rebase('Z', 2, 3), 2; }, "invalid base number for input";
dies-ok { rebase('Z', 16, 37), 2; }, "invalid base number for input";
lives-ok { rebase('Z', 36, 3), 2; }, "valid base number for input";
lives-ok { rebase('Z', 37, 3), 2; }, "valid base number for input";

# various features
is hex2dec('ff', 5), '00255';
is hex2dec('ff', 2), '255';
is bin2dec('11', 4), '0003';
is bin2hex('00001010', :$prefix), '0xA';
is bin2hex('00001010', :$LC), 'a';
is bin2hex('00001010', :$LC, :$prefix), '0xa';
is bin2hex('11', 4), '0003';
is bin2hex('11', 4, :$prefix), '0x03';
is dec2hex(10, 3), '00A';
is dec2hex(10, :$LC, :$prefix), '0xa';
is dec2hex(10, 4, :$prefix), '0x0A';
is hex2bin('ff', 11), '00011111111';
is hex2bin('ff', :$prefix), '0b11111111';
is hex2bin('ff', 11, :$prefix), '0b011111111';
is dec2bin(10, 5), '01010';
is dec2bin(10, 5, :$prefix), '0b1010';
is dec2bin(10, :$prefix), '0b1010';
is bin2oct('111111', :$prefix), '0o77';
is hex2oct('3f', :$prefix), '0o77';
is dec2oct(63, :$prefix), '0o77';
is oct2bin('77', :$prefix), '0b111111';
is oct2hex('77', :$prefix), '0x3F';
is oct2hex('77', :$prefix, :$LC), '0x3f';

my $suffix = True;
is rebase('Z', 36, 3, :$suffix), '1022_base-3', "test suffix";
is rebase('z', 62, 3, :$suffix), '2021_base-3', "test suffix";
