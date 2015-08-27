use v6;
use PSGI;
use FastCGI::NativeCall;

class FastCGI::NativeCall::PSGI {
	has FastCGI::NativeCall $.fcgi;
	has $!body;
	has %!env;
	has $!app;

	method new(FastCGI::NativeCall $fcgi) {
		return self.bless(:$fcgi);
	}

	method run {
		while ($.fcgi.Accept() >= 0) {
			%!env = $.fcgi.env;
			if %!env<CONTENT_LENGTH> {
				$!body = $.fcgi.Read(%!env<CONTENT_LENGTH>.Int).encode;
			}
			my $res = self.handler;
			$.fcgi.Print($res);
		}
	}

	method app($app) {
		$!app = $app;
	}

	method handler {
		%!env<psgi.version>			= [1,0];
		%!env<psgi.url_scheme>		= 'http';
		%!env<psgi.multithread> 	= False;
		%!env<psgi.multiprocess> 	= False;
		%!env<psgi.input>			= $!body;
		%!env<psgi.errors>			= $*ERR;
		%!env<psgi.run_once>		= False;
		%!env<psgi.nonblocking>		= False;
		%!env<psgi.streaming>		= False;

		my $result;
		if $!app ~~ Callable {
			$result = $!app(%!env);
		}
		elsif $!app.can('handle') {
			$result = $!app.handle(%!env);
		}
		else {
			die "invalid application";
		}
		my $output = encode-psgi-response($result);
		return $output;
	}
}

# vim: ft=perl6
