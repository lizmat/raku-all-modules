use Cro::ZeroMQ::Message;
use Test;

my $m;

$m = Cro::ZeroMQ::Message.new(parts => ('hello '.encode, 'world'.encode));
is $m.parts, ('hello '.encode, 'world'.encode);
is $m.body-text, 'world';

$m = Cro::ZeroMQ::Message.new("hello world");
is $m.parts, ('hello world'.encode);
is $m.body-text, 'hello world';

$m = Cro::ZeroMQ::Message.new("goodbye cruel world".encode('ascii'));
is Buf.new($m.parts[0]), [Buf.new('goodbye cruel world'.encode)][0];
is $m.body-text, 'goodbye cruel world';

$m = Cro::ZeroMQ::Message.new("EventName", "MyData".encode('ascii'));
# say $m.parts;
is Buf.new($m.parts[0]), Buf.new('EventName'.encode);
is Buf.new($m.parts[1]), Buf.new('MyData'.encode);
is $m.body-text, 'MyData';

done-testing;
