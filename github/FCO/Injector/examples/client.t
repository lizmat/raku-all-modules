use lib ".";
use lib "../lib";
use Client;
use Binder;
use Service;
use Test;
use Injector;
plan 1;

class TestService does Service {
	has $.name = "TESTING";
}

bind TestService, :to(Service), :override;

is Client.new.greet, ｢Hello TESTING｣, ｢The injector is working \o/｣
