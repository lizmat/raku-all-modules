#!/usr/bin/env perl6

use v6;
use Bitcoin::RPC::Client;
use Data::Dump;
use JSON::Tiny;

my $client = Bitcoin::RPC::Client.new(url => '192.168.192.8', secure => False);
# my $result = $client.execute('getblock', '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f', True);
# my $result = $client.execute('backupwallet', 'C:\\tmp\\wallet.dat');
# my $result = $client.execute('getrawtransaction', "a63519fcbd8555120998df4b33bd009f6ac8d6e69640d15767dce50075c2fa79");
# my $result = $client.execute('getinfo');
# my $result = $client.execute('getbalance', 'MAIN_ACCOUNT');
my $result = $client.execute('gettxout', 'a63519fcbd8555120998df4b33bd009f6ac8d6e69640d15767dce50075c2fa79', 0, False);
say Dump from-json($result);
