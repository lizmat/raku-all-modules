use Injector;
use Service;

class Client {
	has Service $!service is injected;


	method greet {
		"Hello {$!service.name}"
	}
}

