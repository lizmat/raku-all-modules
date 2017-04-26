#!/usr/bin/env perl6

use lib <../lib lib>;
use WebService::Lastfm;

sub MAIN(Str $api-key, Str $api-secret, Str $sk, Str $artist, Str $track, $duration is copy = 60) {
	my $lastfm = WebService::Lastfm.new(:$api-key, :$api-secret);
	$duration = $duration.Str;
	say $lastfm.write('track.updateNowPlaying', :$artist, :$track, :$sk);
}
