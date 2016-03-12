use v6;

unit class MQTT::Client;

use MQTT::Client::MyPack;

has Int      $.keepalive-interval    is rw = 60;
has Int      $.maximum-length        is rw = 2097152;  # 2 MB
has Str      $.client-identifier     is rw = "perl6";
has Str      $.server                is rw;
has Int      $.port                  is rw = 1883;
has Supply   $!messages;
has IO::Socket::Async $!connection;

sub _quotemeta ($str is copy) {
    $str ~~ s:g[\W+] = "'$/'";
    return $str;
}

our sub filter-as-regex ($filter) {
    return /^ <!before '$'>/ if $filter eq '#';
    return /^ '/'          / if $filter eq '/#';

    my $regex = '^';
    my $anchor = True;
    $regex ~= "<!before '\$'>" if $filter ~~ /^\+/;

    my @parts = $filter.comb(/ '/#' | '/' | <-[/]>+ /);
    for @parts {
        when '/#' { $anchor = False; last }
        when '/'  { $regex ~= '\\/' }
        when '+'  { $regex ~= '<-[/]>*' }
        default   { $regex ~= _quotemeta $_ }
    }
    $regex ~= '$' if $anchor;

    return /<$regex>/;
}

method connect () {
    return start {
        use experimental :pack;

        $!connection = await IO::Socket::Async.connect: $!server, $!port;
        my $packets = self!incoming-packets($!connection.Supply(:bin)).share;

        $!messages = supply {
            whenever $packets.grep(*.<type> == 3) {
                my $topic-length = .<data>.unpack("n");
                my $topic   = .<data>.subbuf(2, $topic-length)
                                .decode("utf8-c8");
                my $message = .<data>.subbuf(2 + $topic-length);
                my $retain  = .<retain>;
                emit { :$topic, :$message, :$retain };
            }
        }

        my $initialized = $packets.grep(*.<type> == 2).head(1).Promise;

        $!connection.write: mypack "C m/(n/a* C C n n/a*)", 0x10,
            "MQIsdp", 3, 2, $!keepalive-interval, $!client-identifier;

        await $initialized;

        Supply.interval( $!keepalive-interval ).tap: {
            $!connection.write: pack "C x", 0xc0;
        };

        True;
    }
}

method !parse (Buf $buf is rw) {
    my $offset = 1;

    my $multiplier = 1;
    my $length = 0;
    my $d = 0;

    repeat {
        return False if $offset >= $buf.elems;
        $d = $buf[$offset++];
        $length += ($d +& 0x7f) * $multiplier;
        $multiplier *= 128;
    } while $d +& 0x80;

    return False if $length > $buf.elems + $offset;

    my $first_byte = $buf[0];
    my %packet := {
        type   => ($first_byte +& 0xf0) +> 4,
        dup    => ($first_byte +& 0x08) +> 3,
        qos    => ($first_byte +& 0x06) +> 1,
        retain => ($first_byte +& 0x01),
        data   => $buf.subbuf($offset, $length);
    };

    $buf .= subbuf($offset + $length);

    return %packet;
}

method !incoming-packets (Supply $binary) {
    my Buf $buf .= new;
    return supply {
        whenever $binary -> $received {
            $buf ~= $received;
            while self!parse($buf) -> %hash {
                emit %hash;
            }
        }
    }

}

multi method publish (Str $topic, Blob $message) {
    $!connection.write: mypack "C m/(n/a* a*)", 0x30, $topic, $message;
}

multi method publish (Str $topic, Str $message) {
    self.publish: $topic, $message.encode;
}

multi method retain (Str $topic, Blob $message) {
    $!connection.write: mypack "C m/(n/a* a*)", 0x31, $topic, $message;
}

multi method retain (Str $topic, Str $message) {
    self.publish: $topic, $message.encode;
}

method subscribe (Str $topic) returns Supply:D {
    $!connection.write: mypack "C m/(C C n/a* C)", 0x82,
        0, 0, $topic, 0;

    my $regex = filter-as-regex($topic);

    return $!messages.grep: { .<topic> ~~ $regex };
}

method messages () returns Supply:D {
    return $!messages.Supply;
}

method connection () returns Promise:D {
    ...
}

=begin pod

=head1 NAME

MQTT::Client - Minimal MQTT v3 client interface for Perl 6

=head1 SYNOPSIS

    use MQTT::Client;

    my $m = MQTT::Client.new('test.mosquitto.org');
    await $m.connect;

    $m.publish("hello-world", "$*PID is still here!");

    react {
        whenever $m.subscribe("typing-speed-test.aoeu.eu") {
            say "Typing test completed at { .<message>.decode("utf8-c8") }";
        }

        whenever Supply.interval(10) {
            $m.publish("hello-world", "$*PID is still here!");
        }
    }

=head1 METHODS

=head2 new($server, $port)

Returns a new MQTT object. Note: it does not automatically connect. Before doing
anything, .connect should be called!

=head2 connect

Attempts to connect to the MQTT broker, and returns a Promise that will be kept
after connection confirmation from the broker.

=head2 connection

Returns a Promise that isn't kept until the connection ends.

=head2 publish(Str $topic, Buf|Str $message)

=head2 retain(Str $topic, Buf|Str $message)

Publish a message to the MQTT broker. If the $message is a Str, it will be
UTF-8 encoded. Topics are always UTF-8 encoded in MQTT.

=head2 subscribe($topic)

Subscribes to the topic, returning a Supply of messages that match the topic.
Note that messages that are matched by multiple subscriptions will be passed
to all of the supplies that match.

Tap the supply to receive, for each message, a hash with the keys C<topic>,
C<message>, and a boolean C<retain>. Note that C<message> is a Buf (binary
buffer), which in most cases you will need to C<.decode> before you can use it.

=head1 FUNCTIONS

=head2 MQTT::Client::filter_as_regex(topic_filter)

Given a valid MQTT topic filter, returns the corresponding regular expression.

=head1 NOT YET IMPLEMENTED

The following features that are present in Net::MQTT::Simple for Perl 5, have
not yet been implemented in MQTT::Client for Perl 6:

=over

=item dropping the connection when a large message is received

=item unsubscribe

=item automatic reconnecting

=item SSL

=item connection timeouts

=item simple functional interface

=back

=head1 NOT SUPPORTED

=over 4

=item QoS (Quality of Service)

Every message is published at QoS level 0, that is, "at most once", also known
as "fire and forget".

=item DUP (Duplicate message)

Since QoS is not supported, no retransmissions are done, and no message will
indicate that it has already been sent before.

=item Authentication

No username and password are sent to the server.

=item Last will

The server won't publish a "last will" message on behalf of us when our
connection's gone.

=item Large data

Because everything is handled in memory and there's no way to indicate to the
server that large messages are not desired, the connection is dropped as soon
as the server announces a packet larger than 2 megabytes.

=item Validation of server-to-client communication

The MQTT spec prescribes mandatory validation of all incoming data, and
disconnecting if anything (really, anything) is wrong with it. However, this
minimal implementation silently ignores anything it doesn't specifically
handle, which may result in weird behaviour if the server sends out bad data.

Most clients do not adhere to this part of the specifications.

=back 

=head1 LICENSE

Pick your favourite OSI approved license :)

http://www.opensource.org/licenses/alphabetical

=head1 AUTHOR

Juerd Waalboer <juerd@tnx.nl>

=head1 SEE ALSO

Net::MQTT::Simple for Perl 5

=end pod
