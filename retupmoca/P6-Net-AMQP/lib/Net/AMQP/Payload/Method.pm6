use Net::AMQP::Payload::ArgumentSerialization;

class Net::AMQP::Payload::Method does Net::AMQP::Payload::ArgumentSerialization;

my %standard = (
    connection =>
        { id => 10,
          methods =>
              { start     => { id => 10, signature => ('octet', 'octet', 'table', 'longstring', 'longstring') },
                start-ok  => { id => 11, signature => ('table', 'shortstring', 'longstring', 'shortstring') },
                secure    => { id => 20, signature => ('longstring') },
                secure-ok => { id => 21, signature => ('longstring') },
                tune      => { id => 30, signature => ('short', 'long', 'short') },
                tune-ok   => { id => 31, signature => ('short', 'long', 'short') },
                open      => { id => 40, signature => ('shortstring', 'shortstring', 'bit') },
                open-ok   => { id => 41, signature => ('shortstring') },
                close     => { id => 50, signature => ('short', 'shortstring', 'short', 'short') },
                close-ok  => { id => 51, signature => () } } },
    channel =>
        { id => 20,
          methods =>
              { open     => { id => 10, signature => ('shortstring') },
                open-ok  => { id => 11, signature => ('longstring') },
                flow     => { id => 20, signature => ('bit') },
                flow-ok  => { id => 21, signature => ('bit') },
                close    => { id => 40, signature => ('short', 'shortstring', 'short', 'short') },
                close-ok => { id => 41, signature => () } } },
    exchange =>
        { id => 40,
          methods =>
              { declare    => { id => 10, signature => ('short', 'shortstring', 'shortstring', 'bit', 'bit', 'bit', 'bit', 'bit', 'table') },
                declare-ok => { id => 11, signature => () },
                delete     => { id => 20, signature => ('short', 'shortstring', 'bit', 'bit') },
                delete-ok  => { id => 21, signature => () } } },
    queue =>
        { id => 50,
          methods =>
              { declare    => { id => 10, signature => ('short', 'shortstring', 'bit', 'bit', 'bit', 'bit', 'bit', 'table') },
                declare-ok => { id => 11, signature => ('shortstring', 'long', 'long') },
                bind       => { id => 20, signature => ('short', 'shortstring', 'shortstring', 'shortstring', 'bit', 'table') },
                bind-ok    => { id => 21, signature => () },
                unbind     => { id => 50, signature => ('short', 'shortstring', 'shortstring', 'shortstring', 'table') },
                unbind-ok  => { id => 51, signature => () },
                purge      => { id => 30, signature => ('short', 'shortstring', 'bit') },
                purge-ok   => { id => 31, signature => ('long') },
                delete     => { id => 40, signature => ('short', 'shortstring', 'bit', 'bit', 'bit') },
                delete-ok  => { id => 41, signature => ('long') },
              } },
    basic =>
        { id => 60,
          methods =>
              { qos           => { id => 10, signature => ('long', 'short', 'bit') },
                qos-ok        => { id => 11, signature => () },
                consume       => { id => 20, signature => ('short', 'shortstring', 'shortstring', 'bit', 'bit', 'bit', 'bit', 'table') },
                consume-ok    => { id => 21, signature => ('shortstring') },
                cancel        => { id => 30, signature => ('shortstring', 'bit') },
                cancel-ok     => { id => 31, signature => ('shortstring') },
                publish       => { id => 40, signature => ('short', 'shortstring', 'shortstring', 'bit', 'bit') },
                return        => { id => 50, signature => ('short', 'shortstring', 'shortstring', 'shortstring') },
                deliver       => { id => 60, signature => ('shortstring', 'longlong', 'bit', 'shortstring', 'shortstring') },
                get           => { id => 70, signature => ('short', 'shortstring', 'bit') },
                get-ok        => { id => 71, signature => ('longlong', 'bit', 'shortstring', 'shortstring', 'long') },
                get-empty     => { id => 72, signature => ('shortstring') },
                ack           => { id => 80, signature => ('longlong', 'bit') },
                reject        => { id => 90, signature => ('longlong', 'bit') },
                recover-async => { id => 100, signature => ('bit') },
                recover       => { id => 110, signature => ('bit') },
                recover-ok    => { id => 111, signature => () },
              } },
    tx =>
        { id => 90,
          methods =>
              { select      => { id => 10, signature => () },
                select-ok   => { id => 11, signature => () },
                commit      => { id => 20, signature => () },
                commit-ok   => { id => 21, signature => () },
                rollback    => { id => 30, signature => () },
                rollback-ok => { id => 31, signature => () },
              } },
);

has $.class-id;
has $.method-id;
has @.arguments;
has @.signature;
has $.method-name;

method Buf {
    my $args = buf8.new();
    my $bitsused = 0;
    my $lastarg = '';
    for @.signature Z @.arguments -> $arg, $value {
        if $arg ne 'bit' {
            $bitsused = 0;
        }
        if $arg eq 'bit' && $bitsused {
            my $tmp = self.serialize-arg($arg, $value, $args.subbuf($args.bytes - 1), $bitsused);
            $args = $args.subbuf(0, $args.bytes - 1) ~ $tmp;
            #$args[*-1] = self.serialize-arg($arg, $value, $args[*-1], $bitsused);
        } else {
            $args ~= self.serialize-arg($arg, $value);
        }
        $lastarg = $arg;
        if $arg eq 'bit' {
            $bitsused++;
        }
        if $bitsused >= 8 {
            $bitsused = 0;
        }
    }
    return pack('nn', ($.class-id, $.method-id)) ~ $args;
}

multi method new(Blob $data is copy) {
    my ($class-id, $method-id) = $data.unpack('nn');
    my $method-name;
    my @signature;
    my @arguments;
    for %standard.kv -> $class, %chash {
        if %chash<id> == $class-id {
            $method-name = $class ~ '.';
            for %standard{$class}<methods>.kv -> $method, %mhash {
                if %mhash<id> == $method-id {
                    $method-name ~= $method;
                    @signature = %mhash<signature>.list;
                }
            }
        }
    }
    $data .= subbuf(4);


    # get args
    my $bitbuf;
    my $bitcount = 0;
    for @signature -> $arg {
        my $value;
        my $size;
        if $arg eq 'bit' && $bitcount {
            ($value, $size) = self.deserialize-arg($arg, $bitbuf, $bitcount);
            $size = 0;
            $bitcount++;
            if $bitcount > 7 {
                $bitcount = 0;
            }
        } else {
            ($value, $size) = self.deserialize-arg($arg, $data);
            if $arg eq 'bit' {
                $bitcount++;
                $bitbuf = $data.subbuf(0, 1);
            }
        }

        @arguments.push($value);
        $data .= subbuf($size);
    }
    
    self.bless(:$class-id, :$method-id, :$method-name, :@signature, :@arguments);
}

multi method new(Str $method-name, *@arguments) {
    my $class-id;
    my $method-id;
    my @signature;

    my ($class, $method) = $method-name.split('.');
    $class-id = %standard{$class}<id>;
    $method-id = %standard{$class}<methods>{$method}<id>;
    @signature = %standard{$class}<methods>{$method}<signature>.list;
    self.bless(:$method-name, :$class-id, :$method-id, :@arguments, :@signature);
}
