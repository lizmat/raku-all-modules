use v6;
use NativeCall;

class FCGX_Request is Pointer is repr('CPointer') { }

my constant HELPER = %?RESOURCES<libraries/fcgi>.Str;

sub FCGX_OpenSocket(Str $path, int32 $backlog)
is native(HELPER) returns int32 { ... }

sub XS_Init(int32 $sock)
is native(HELPER) returns FCGX_Request { ... }

sub XS_Accept(FCGX_Request $request, &populate_env_callback (Str, Str))
is native(HELPER) returns int32 { ... }

sub XS_Print(Str $str, FCGX_Request $request)
is native(HELPER) returns int32 { ... }

sub XS_Read(int32 $n, FCGX_Request $request)
is native(HELPER) returns Pointer { ... }

sub XS_Flush(FCGX_Request $request)
is native(HELPER) { ... }

sub XS_Finish(FCGX_Request $request)
is native(HELPER) { ... }

sub free(Pointer $ptr) is native { ... }

my Lock $accept_mutex = Lock.new();

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
	}

	our sub OpenSocket(Str $path, Int $backlog) {
		return FCGX_OpenSocket($path, $backlog);
	}

	our sub CloseSocket(Int $socket) {
		sub close(int32 $d) is native { ... }
		close($socket);
	}

	method Accept() {
		self.Finish();
		%env = ();
		$accept_mutex.lock();
		my $ret = XS_Accept($!fcgx_req, &populate_env);
		$accept_mutex.unlock();
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
