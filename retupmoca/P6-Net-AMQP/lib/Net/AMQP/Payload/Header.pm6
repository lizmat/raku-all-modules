use Net::AMQP::Payload::ArgumentSerialization;

unit class Net::AMQP::Payload::Header does Net::AMQP::Payload::ArgumentSerialization;

use experimental :pack;

has $.class-id;
has $.weight = 0;
has $.body-size;

has $.content-type;
has $.content-encoding;
has $.headers;
has $.delivery-mode;
has $.priority;
has $.correlation-id;
has $.reply-to;
has $.expiration;
has $.message-id;
has $.timestamp;
has $.type;
has $.user-id;
has $.app-id;

my @FIELDS = (
    [ 15, 'content-type',       'shortstring'   ],
    [ 14, 'content-encoding',   'shortstring'   ],
    [ 13, 'headers',            'table'         ],
    [ 12, 'delivery-mode',      'octet'         ],
    [ 11, 'priority',           'octet'         ],
    [ 10, 'correlation-id',     'shortstring'   ],
    [  9, 'reply-to',           'shortstring'   ],
    [  8, 'expiration',         'shortstring'   ],
    [  7, 'message-id',         'shortstring'   ],
    [  6, 'timestamp',          'timestamp'     ],
    [  5, 'type',               'shortstring'   ],
    [  4, 'user-id',            'shortstring'   ],
    [  3, 'app-id',             'shortstring'   ],
);


multi method new($data is copy) {
    my $class-id = $data.unpack('n');
    my $weight = $data.subbuf(2).unpack('n');
    my $body-size = ($data.subbuf(4).unpack('N') +< 32) +| $data.subbuf(8).unpack('N');

    my $flags = $data.subbuf(12).unpack('n');

    $data .= subbuf(14);
    my %opts;
    for @FIELDS -> [ $bit, $var, $type ] {
        if $flags +& (1 +< $bit) {
            (%opts{$var}, my $len) = self.deserialize-arg($type, $data);
            $data .= subbuf($len);
        }
    }

    self.bless(:$class-id, :$weight, :$body-size, |%opts );
}

multi method new(*%args) {
    self.bless(|%args);
}

method Buf {
    my $buf = buf8.new;

    $buf ~= pack('n', $.class-id);
    $buf ~= pack('n', $.weight);
    $buf ~= pack('N', $.body-size +> 32);
    $buf ~= pack('N', $.body-size +& 0xFFFF);

    my $flags = 0;
    my $args = buf8.new;

    for @FIELDS -> [ $bit, $var, $type ] {
        if self."$var"().defined {
            $args ~= self.serialize-arg($type, self."$var"());
            $flags = $flags +| (1 +< $bit);
        }
    }

    $buf ~= pack('n', $flags);
    $buf ~= $args;

    return $buf;
}
