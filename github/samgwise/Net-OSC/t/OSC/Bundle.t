#! /usr/bin/env per6
use v6;
use Test;

plan 5;

use-ok 'Net::OSC::Bundle';
use Net::OSC::Bundle;
use Net::OSC::Message;
use Numeric::Pack :ALL;

my Net::OSC::Bundle $bundle .= new;
ok $bundle.so, "Bundle initialised OK";

my $now = now;
is-approx $bundle.time-stamp-to-instant( $bundle.time-stamper($now) ), $now, "Round trip time-stamp packing.";
$bundle.time-stamp = $now;

my Net::OSC::Message $message .= new( :args<Hey 123 45.67> );
$bundle.push: $message;

is $bundle.package[].map( { sprintf("%02x", $_) } ).join(" "),
  '23 62 75 6e 64 6c 65 00 '                                                      # '#bundle' ~ 0x00
  ~ ($bundle.time-stamper($now)[].map( { sprintf("%02x", $_) } ).join: " ") ~ ' ' # time tag
  ~ '00 00 00 1c '                                                                # bytes of next message
  ~ '2f 00 00 00 2c 73 69 64 00 00 00 00 '                                        # /,sid
  ~ '48 65 79 00 '                                                                # 'Hey' ~ 0x00
  ~ '00 00 00 7b '                                                                # 123
  ~ '40 46 d5 c2 8f 5c 28 f6',                                                    # 45.67
  "Bundle package correctly";

is $bundle.unpackage($bundle.package).head.args, <Hey 123 45.67>, "Round trip pack -> unpack";
