use Cro::ZeroMQ::Internal;
use Net::ZMQ4;
use Net::ZMQ4::Constants;

class Cro::ZeroMQ::Socket::Sub does Cro::ZeroMQ::Source::Pure {
    has $.subscribe;
    has $.unsubscribe;

    method !type() { ZMQ_SUB }
    method new(:$connect = Nil, :$bind = Nil,
               :$high-water-mark,
               :$subscribe = Nil, :$unsubscribe) {
        die "You need to specify subscribe parameter for a SUB socket" if $subscribe ~~ Nil;
        die Cro::ZeroMQ::IllegalBind.new(:reason<you need to specify connect or bind>) unless so $connect^$bind;
        self.bless(:$connect, :$bind, :$high-water-mark, :$subscribe, :$unsubscribe);
    }

    method incoming(--> Supply:D) {
        my ($ctx, $socket) = self!initial;
        given $!subscribe {
            when Blob { $socket.setopt(ZMQ_SUBSCRIBE, $_) }
            when Str  { $socket.setopt(ZMQ_SUBSCRIBE, Blob.new: $_.encode) }
            when Iterable {
                for @$_ {
                    $_ ~~ Blob ??
                    $socket.setopt(ZMQ_SUBSCRIBE, $_) !!
                        $_ ~~ Str ??
                        $socket.setopt(ZMQ_SUBSCRIBE, Blob.new: $_.encode) !!
                        die "Envelope part must be a Str or a Blob, {$_.WHAT} passed";
                }
            }
            when Whatever { $socket.setopt(ZMQ_SUBSCRIBE, Blob.new) }
            when Supply {
                $_.tap: -> $_ {
                    die "Envelope part must be a Str or a Blob, {$_.WHAT} passed" if $_ !~~ Blob|Str;
                    $socket.setopt(
                        ZMQ_SUBSCRIBE,
                        $_ ~~ Blob ?? $_ !! Blob.new: $_.encode
                    )
                }
            }
        }

        if $!unsubscribe {
            $!unsubscribe.tap: -> $_ {
                my $topic = $_ ~~ Blob ?? $_ !! $_.encode;
                $socket.setopt(ZMQ_UNSUBSCRIBE, $topic);
            }
        }

        self!source-supply(:$ctx, :$socket);
    }
}
