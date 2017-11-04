use Cro::ZeroMQ::Socket::Dealer;
use Cro::ZeroMQ::Socket::Router;
use Cro::ZeroMQ::Message;
use Test;

my $router = Cro::ZeroMQ::Socket::Router.new(bind => 'tcp://127.0.0.1:5678');
my $dealer = Cro.compose(Cro::ZeroMQ::Socket::Dealer);

my $input = Supplier::Preserving.new;
my $responses = $dealer.establish($input.Supply, connect => 'tcp://127.0.0.1:5678');

# Rotuer part
my $echo = Supplier::Preserving.new;
$router.incoming.tap: -> $_ {
    my $identity = .parts[0];
    $echo.emit: Cro::ZeroMQ::Message.new($identity, '', .parts[2]);
};

$router.replier.sinker($echo.Supply).tap;

my %f = :!first, :!second, :!third;
my $completion = Promise.new;

# Dealer part
$responses.tap: -> $_ {
    %f{$_.body-text} = True;
    $completion.keep if %f<first> && %f<second> && %f<third>;
};

$input.emit(Cro::ZeroMQ::Message.new('', 'first'));
$input.emit(Cro::ZeroMQ::Message.new('', 'second'));
$input.emit(Cro::ZeroMQ::Message.new('', 'third'));

await Promise.anyof($completion, Promise.in(2));

is $completion.status, Kept, "ROUTER/DEALER pair is working";

done-testing;
