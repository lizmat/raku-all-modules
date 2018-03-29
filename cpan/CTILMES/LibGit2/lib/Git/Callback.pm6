use NativeCall;
use nqp;

sub callback-pointer(&callback) is export
{
    my &sprintf := sub {};
    &trait_mod:<is>(&sprintf, :native);
    &trait_mod:<is>(&sprintf, symbol => 'sprintf');
    my $sig := :(Blob, Str, &cb --> int32);
    nqp::bindattr($sig.params[2], Parameter, '$!sub_signature',
                  &callback.signature);
    nqp::bindattr(&sprintf, Code, '$!signature', $sig);
    my $buf = buf8.allocate(20);
    my $len = &sprintf($buf, "%lld", &callback);
    Pointer.new($buf.subbuf(^$len).decode.Int);
}
