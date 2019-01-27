use Cro::Sink;
use Cro::ZeroMQ::Socket::Req;
use Cro::ZeroMQ::Service;
use Test;

my Cro::Service $service = Cro::ZeroMQ::Service.rep(
    bind => 'tcp://127.0.0.1:5555'
);

# REQ
$service.start;

my $req = Cro.compose(Cro::ZeroMQ::Socket::Req);
my $input = Supplier::Preserving.new;
my $responses = $req.establish($input.Supply, connect => "tcp://127.0.0.1:5555");
my $completion = Promise.new;
$responses.tap: -> $_ {
    $completion.keep if $_.body-text eq 'test';
}
$input.emit(Cro::ZeroMQ::Message.new('test'));

await Promise.anyof($completion, Promise.in(2));

is $completion.status, Kept, "REP service works";

$service.stop;
$completion = Promise.new;

# PULL

class PullAggregator does Cro::Sink {
    method consumes() { Cro::ZeroMQ::Message }
    method sinker(Supply $messages --> Supply) {
        supply {
            whenever $messages {
                $completion.keep if .body-text eq 'test';
            }
        }
    }
};

$service = Cro::ZeroMQ::Service.pull(
    bind => 'tcp://127.0.0.1:5556',
    PullAggregator
);

$service.start;

my $pusher = Cro::ZeroMQ::Socket::Push.new(connect => 'tcp://127.0.0.1:5556');
$pusher.sinker(
    supply {
        emit Cro::ZeroMQ::Message.new('test');
    }
).tap;

await Promise.anyof($completion, Promise.in(2));

is $completion.status, Kept, "PULL service works";

$service.stop;

done-testing;
