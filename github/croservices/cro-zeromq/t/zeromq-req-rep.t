use Cro;
use Cro::ZeroMQ::Socket::Rep;
use Cro::ZeroMQ::Socket::Req;
use Test;

my $rep = Cro::ZeroMQ::Socket::Rep.new(bind => "tcp://127.0.0.1:5555");

my $echo = Supplier::Preserving.new;

$rep.incoming.tap: -> $_ {
    $echo.emit: $_
}

$rep.replier.sinker($echo.Supply).tap;

my $req = Cro.compose(Cro::ZeroMQ::Socket::Req);

my $input = Supplier::Preserving.new;
my $responses = $req.establish($input.Supply, connect => "tcp://127.0.0.1:5555");

my %f = :!first, :!second, :!third;
my $completion = Promise.new;

$responses.tap: -> $_ {
    %f{$_.body-text} = True;
    $completion.keep if %f<first> && %f<second> && %f<third>;
}

$input.emit(Cro::ZeroMQ::Message.new('first'));
$input.emit(Cro::ZeroMQ::Message.new('second'));
$input.emit(Cro::ZeroMQ::Message.new('third'));

await Promise.anyof($completion, Promise.in(2));

is $completion.status, Kept, "REQ/REP pair is working";

done-testing;
