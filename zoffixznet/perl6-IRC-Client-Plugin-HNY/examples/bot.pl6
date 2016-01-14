use lib <lib ../lib /var/www/tmp/perl6-IRC-Client/lib>;
use IRC::Client;
use IRC::Client::Plugin::Debugger;
use IRC::Client::Plugin::HNY;

sub MAIN (
            :$host    = 'localhost',
            :$channel = '#zofbot',
            :$nick    = 'HNYBot',
    Numeric :$time
) {

    $time.defined and %*ENV<CUSTOM-NOW-TIME> = $time;

    IRC::Client.new(
        :$host,
        :$nick,
        :channels($channel),
        :debug,
        plugins => [
            # IRC::Client::Plugin::Debugger.new,
            IRC::Client::Plugin::HNY.new,
        ]
    ).run;

}
