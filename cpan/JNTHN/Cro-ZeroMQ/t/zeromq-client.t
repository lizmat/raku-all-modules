use Cro::ZeroMQ::Message;
use Cro::ZeroMQ::Client;
use Cro::ZeroMQ::Service;
use Test;

# Echo socket
my Cro::Service $service = Cro::ZeroMQ::Service.rep(
    bind => 'tcp://127.0.0.1:5432'
);

$service.start;

my $client = Cro::ZeroMQ::Client.req(
    connect => 'tcp://127.0.0.1:5432'
);

my $reply = await $client.send(Cro::ZeroMQ::Message.new('test'));

ok $reply.body-text eq 'test', 'Client works';

$client = Cro::ZeroMQ::Client.req(
    connect => 'tcp://127.0.0.1:5431'
);

dies-ok {
    $client.send(Cro::ZeroMQ::Message.new('test'));
    $client.send(Cro::ZeroMQ::Message.new('test'));
}, 'Req client roundtrip cannot be interracted';

$service.stop;

# Dealer part

class Replier does Cro::Transform {
    method consumes() { Cro::ZeroMQ::Message }
    method produces() { Cro::ZeroMQ::Message }
    method transformer(Supply $messages --> Supply) {
        supply {
            whenever $messages {
                emit Cro::ZeroMQ::Message.new(.body-text);
            }
        }
    }
}

$service = Cro::ZeroMQ::Service.rep(
    bind => 'tcp://127.0.0.1:5431',
    Replier
);

$service.start;

$client = Cro::ZeroMQ::Client.dealer(
    connect => 'tcp://127.0.0.1:5431'
);

my %h = :!a, :!b, :!c;

my $completion = Promise.new;

for <a b c>.pick(*).list {
    start {
        my $reply = await $client.send(Cro::ZeroMQ::Message.new($_));
        %h{$reply.body-text} = True;
        $completion.keep if %h<a> && %h<b> && %h<c>;
    }
}

await Promise.anyof($completion, Promise.in(2));

is $completion.status, Kept, "Dealer client is working";;

$service.stop;

done-testing;
