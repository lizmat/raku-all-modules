use v6;

sub channelify(Positional:D \list, :$no-thread) {
    if $no-thread {
        return channelify-no-thread(list)
    } else {
        my $channel = Channel.new;
        start {
            for list {
                last if $channel.closed;
                $channel.send($_)
            }
            LEAVE $channel.close unless $channel.closed;
        }
        return $channel.list but role :: { method channel { $channel }; method no-thread { False } }
    }
}

sub channelify-no-thread(\l, :$no-thread){
    my $channel = Channel.new;
    
    (gather for l {
        .take unless $channel.closed;
        LAST $channel.close unless $channel.closed;
    }) but role :: { method channel { $channel }; method no-thread { True } }
}

sub EXPORT {
    {
        '&channelify' => (%*ENV<RAKUDO_MAX_THREADS>:!exists || %*ENV<RAKUDO_MAX_THREADS>.Int > 1) ?? &channelify !! &channelify-no-thread,
        '&postfix:<⇒>' => (%*ENV<RAKUDO_MAX_THREADS>:!exists || %*ENV<RAKUDO_MAX_THREADS>.Int > 1) ?? &channelify !! &channelify-no-thread
    }
}
