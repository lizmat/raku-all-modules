use v6;
use NativeCall;

class FCGX_Request is Pointer is repr('CPointer') { }

sub library {
	state Str $path;
	unless $path {
		my $libname = 'fcgi.so';
		for @*INC {
			my $inc-path = $_.IO.path.subst(/ ['file#' || 'inst#'] /, '');
			$path = $*SPEC.catfile($inc-path, $libname);
			if $path.IO ~~ :f {
				last;
			}
		}
		unless $path {
			die "Unable to locate library: $libname";
		}
	}
	$path;
}

sub FCGX_OpenSocket(Str $path, int32 $backlog)
is native(&library) returns int32 { ... }

sub XS_Init(int32 $sock)
is native(&library) returns FCGX_Request { ... }

sub XS_Accept(FCGX_Request $request)
is native(&library) returns int32 { ... }

sub XS_Print(Str $str, FCGX_Request $request)
is native(&library) returns int32 { ... }

sub XS_Read(int32 $n, FCGX_Request $request)
is native(&library) returns Pointer { ... }

sub XS_Flush(FCGX_Request $request)
is native(&library) { ... }

sub XS_set_populate_env_callback(&callback (Str, Str))
is native(&library) { ... }

sub XS_Finish(FCGX_Request $request)
is native(&library) { ... }

sub free(Pointer $ptr) is native { ... }

class FastCGI::NativeCall {
	has FCGX_Request $!fcgx_req;
	my %env;

	method env { %env; }

	my sub populate_env(Str $key, Str $value) {
		%env{$key} = $value;
	}

	method new(Int $sock) {
		return self.bless(:$sock);
	}

	submethod BUILD(:$sock) {
		$!fcgx_req = XS_Init($sock);
		XS_set_populate_env_callback(&populate_env);
	}

	our sub OpenSocket(Str $path, Int $backlog) {
		return FCGX_OpenSocket($path, $backlog);
	}

        our sub CloseSocket(Int $socket) {
                sub close(int32 $d) is native { ... }
                close($socket);
        }

	method Accept() {
		%env = ();
		my $ret = XS_Accept($!fcgx_req);
		$ret;
	}

	method Print(Str $content) {
		XS_Print($content, $!fcgx_req);
	}

	method Read(Int $length) {
		my $ptr = XS_Read($length, $!fcgx_req);
		my $ret = nativecast(Str, $ptr);
		free($ptr);
		$ret;
	}

	method Flush() {
		XS_Flush($!fcgx_req);
	}

	method Finish() {
		XS_Finish($!fcgx_req);
	}

	method DESTROY {
		self.Finish();
		free($!fcgx_req);
	}
}

# vim: ft=perl6
