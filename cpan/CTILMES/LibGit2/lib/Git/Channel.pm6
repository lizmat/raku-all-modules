use NativeCall;

class Git::Channel
{
    my %channels;
    my Int $i = 0;
    my $lock = Lock.new;

    method new
    {
        my $channel = Channel.new;
        my Int $id;
        $lock.protect: { %channels{$id = $i++} = $channel }
        $channel but $id
    }

    method channel(Int $id)
    {
        %channels{$id}
    }

    method done(Int $id)
    {
        $lock.protect: { %channels{$id}:delete.close }
    }
}
