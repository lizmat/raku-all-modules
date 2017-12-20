#!/usr/bin/env perl6

use v6;
use Bitcoin::RPC::Client;

my $client = Bitcoin::RPC::Client.new(url => '192.168.192.8', port => '8332');

# supported formats: json (default), hex, and bin (converted into utf8)

my $result = $client.getTx('5668d651db2794aa9542e2935f9dc7330d4f86870cfbd20e7ff1ff31ed26d0f4', 'json');
# my $result = $client.getBlock('000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f');
# my $result = $client.getHeaders(1, '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f');
# my $result = $client.getChainInfo();
# my $result = $client.getMemPool();

# my %utxos = ('2157b554dcfda405233906e461ee593875ae4b1b97615872db6a25130ecc1dd6' => 0,
#              'fe6c48bbfdc025670f4db0340650ba5a50f9307b091d9aaa19aa44291961c69f' => 1,
#              '1024cb12a576b69defa67dbc2f1899700ab58e5ad3d5e058edefb907f59865bc' => 2,
#              '83eeaecaf531e5239ffc3ba7ff583c696f7dbe3610f0d672d41e0b9443632c82' => 3);
# my $result = $client.getUtxos(%utxos);

say $result;
