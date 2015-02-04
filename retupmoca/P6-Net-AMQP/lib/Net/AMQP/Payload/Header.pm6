use Net::AMQP::Payload::ArgumentSerialization;

class Net::AMQP::Payload::Header does Net::AMQP::Payload::ArgumentSerialization;

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

multi method new($data is copy) {
    my $class-id = $data.unpack('n');
    my $weight = $data.subbuf(2).unpack('n');
    my $body-size = ($data.subbuf(4).unpack('N') +< 32) +| $data.subbuf(8).unpack('N');

    my $flags = $data.subbuf(12).unpack('n');

    $data .= subbuf(14);

    my $len;

    my $content-type;
    if $flags +& (1 +< 15) {
        ($content-type, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $content-encoding;
    if $flags +& (1 +< 14) {
        ($content-encoding, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $headers;
    if $flags +& (1 +< 13) {
        ($headers, $len) = self.deserialize-arg('table', $data);
        $data .= subbuf($len);
    }

    my $delivery-mode;
    if $flags +& (1 +< 12) {
        ($delivery-mode, $len) = self.deserialize-arg('octet', $data);
        $data .= subbuf($len);
    }

    my $priority;
    if $flags +& (1 +< 11) {
        ($priority, $len) = self.deserialize-arg('octet', $data);
        $data .= subbuf($len);
    }

    my $correlation-id;
    if $flags +& (1 +< 10) {
        ($correlation-id, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }
    my $reply-to;
    if $flags +& (1 +< 9) {
        ($reply-to, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $expiration;
    if $flags +& (1 +< 8) {
        ($expiration, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $message-id;
    if $flags +& (1 +< 7) {
        ($message-id, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $timestamp;
    if $flags +& (1 +< 6) {
        ($timestamp, $len) = self.deserialize-arg('timestamp', $data);
        $data .= subbuf($len);
    }

    my $type;
    if $flags +& (1 +< 5) {
        ($type, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $user-id;
    if $flags +& (1 +< 4) {
        ($user-id, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    my $app-id;
    if $flags +& (1 +< 3) {
        ($app-id, $len) = self.deserialize-arg('shortstring', $data);
        $data .= subbuf($len);
    }

    self.bless(:$class-id, :$weight, :$body-size, :$content-type, :$content-encoding, :$headers,
               :$delivery-mode, :$priority, :$correlation-id, :$reply-to, :$expiration, :$message-id,
               :$timestamp, :$type, :$user-id, :$app-id);
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

    if $.content-type.defined {
        $args ~= self.serialize-arg('shortstring', $.content-type);
        $flags = $flags +| (1 +< 15);
    }

    if $.content-encoding.defined {
        $args ~= self.serialize-arg('shortstring', $.content-encoding);
        $flags = $flags +| (1 +< 14);
    }

    if $.headers.defined {
        $args ~= self.serialize-arg('table', $.headers);
        $flags = $flags +| (1 +< 13);
    }

    if $.delivery-mode.defined {
        $args ~= self.serialize-arg('octet', $.delivery-mode);
        $flags = $flags +| (1 +< 12);
    }

    if $.priority.defined {
        $args ~= self.serialize-arg('octet', $.priority);
        $flags = $flags +| (1 +< 11);
    }

    if $.correlation-id.defined {
        $args ~= self.serialize-arg('shortstring', $.correlation-id);
        $flags = $flags +| (1 +< 10);
    }

    if $.reply-to.defined {
        $args ~= self.serialize-arg('shortstring', $.reply-to);
        $flags = $flags +| (1 +< 9);
    }

    if $.expiration.defined {
        $args ~= self.serialize-arg('shortstring', $.expiration);
        $flags = $flags +| (1 +< 8);
    }

    if $.message-id.defined {
        $args ~= self.serialize-arg('shortstring', $.message-id);
        $flags = $flags +| (1 +< 7);
    }

    if $.timestamp.defined {
        $args ~= self.serialize-arg('timestamp', $.timestamp);
        $flags = $flags +| (1 +< 6);
    }

    if $.type.defined {
        $args ~= self.serialize-arg('shortstring', $.type);
        $flags = $flags +| (1 +< 5);
    }
    if $.user-id.defined {
        $args ~= self.serialize-arg('shortstring', $.user-id);
        $flags = $flags +| (1 +< 4);
    }

    if $.app-id.defined {
        $args ~= self.serialize-arg('shortstring', $.app-id);
        $flags = $flags +| (1 +< 3);
    }

    $buf ~= pack('n', $flags);
    $buf ~= $args;

    return $buf;
}
