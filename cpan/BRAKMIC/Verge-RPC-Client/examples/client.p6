#!/usr/bin/env perl6

use v6;
use Verge::RPC::Client;
use Data::Dump;
use JSON::Tiny;

my $client = Verge::RPC::Client.new(url => 'localhost', secure => False);

#m y $result = $client.execute('gettransaction', 'bfecd267306825a2fe24fcb266a316385491533ed1f2528ff77392fda6966ca9');
# my $result = $client.execute('backupwallet', 'C:\\tmp\\wallet.dat');
# my $result = $client.execute('getblock', "5e82506dc3d0f13d9c9a864a23b40f2d15ac1b8e0f227e3d26a9ef7b2be31522", True);
# # my $result = $client.execute('getinfo');
# my $result = $client.execute('getaccount', 'D6gCFt34rpLGLpsi6uUF9ECP2g4gNy3psr');
# my $result = $client.execute('getbalance', 'MAIN_ACCOUNT');
my $result = $client.execute('getblockbynumber', 1);
say Dump from-json($result);
