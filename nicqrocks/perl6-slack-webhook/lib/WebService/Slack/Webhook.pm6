#!/usr/bin/env perl6

use Net::HTTP::POST;
use JSON::Fast;

#Make the class.
class WebService::Slack::Webhook {
    #Make some vars.
    has Str $.url is required where {$_ ~~ regex {'https://hooks.slack.com/services/'} };
    has %.defaults;
    has Bool $.debug = False;

    #Using a hash for the info.
    multi method send(%info) {
        #Spit out some debugging stuff.
        if $.debug {
            note "Args passed: ", %info.gist;
            note "Defaults ", %!defaults.gist;
        }

        #Add the defaults.
        %info.append: %!defaults.pairs.grep(-> $p {!%info{$p.key}});

        #Setup the data to be sent.
        my %header = :Content-type("application/json");
        my $body = Buf.new(to-json(%info).ords);

        #Send the request.
        if $.debug { note "Data to send: ", %info.gist; return %info; }
        else { return Net::HTTP::POST($.url, :%header, :$body); }
    }

    #using a string for the info.
    multi method send(Str $msg) {
        note "Calling the Str method" if $.debug;
        self.send: %(:text($msg));
    }
}
