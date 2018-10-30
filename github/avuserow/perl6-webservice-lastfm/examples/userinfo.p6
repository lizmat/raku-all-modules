#!/usr/bin/env perl6

use lib <../lib lib>;
use WebService::Lastfm;

sub MAIN(Str $api-key, Str $user='avuserow') {
	my $lastfm = WebService::Lastfm.new(:$api-key);
	say $lastfm.request('user.getInfo', :$user);
}
