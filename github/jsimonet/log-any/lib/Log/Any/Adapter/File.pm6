use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::File is Log::Any::Adapter {
	has IO::Handle $!fh;

	method BUILD( Str:D :$path ) {
		$!fh = open $path, :a;
	}

	method handle( $msg ) {
		$!fh.say( $msg );
		return True;
	}

}
