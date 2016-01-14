use lib <lib ../lib>;
use IRC::Client;
use IRC::Client::Plugin::Debugger;
use IRC::Client::Plugin::Factoid;

sub MAIN (
    :$host    = 'localhost',
    :$channel = '#zofbot',
    :$nick    = 'huggable',
) {
    IRC::Client.new(
        :$host,
        :$nick,
        :channels($channel.comb: /<-[,]>+/),
        :debug,
        plugins => [
            IRC::Client::Plugin::Debugger.new,
            IRC::Client::Plugin::Factoid.new,
        ]
    ).run;

}
