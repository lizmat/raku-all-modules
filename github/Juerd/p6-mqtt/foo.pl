#!perl6
use v6;
use lib 'lib';
use MQTT::Client;

my $m = MQTT::Client.new: server => 'test.mosquitto.org';

await $m.connect;

$m.publish: "hello-world", "$*PID says hi";

react {
    whenever $m.subscribe("revspace/#") {
        say "REVSPACE: { .<topic> } => { .<message>.decode("utf8-c8")}";
    }

    whenever $m.subscribe("typing-speed-test.aoeu.eu") {
        say "Typing test completed at { .<message>.decode("utf8-c8") }";
    }

    whenever Supply.interval(10) {
        $m.publish: "hello-world", "$*PID is still here :-)";
    }

    whenever Promise.in(4) {
        $m.publish: "hello-world", "Single message after 4 seconds from $*PID";
    }
}
