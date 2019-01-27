#!/usr/bin/env perl6

use Cro::HTTP::Client;
use CroX::HTTP::Auth::Munge::Header;

my %secure = a => 1, b => 2;

my $response = await Cro::HTTP::Client.get: "http://localhost:10000/",
    headers => [ munge(%secure) ];

put await $response.body-text;

CATCH
{
    default { put .response.get-response-phrase }
}
