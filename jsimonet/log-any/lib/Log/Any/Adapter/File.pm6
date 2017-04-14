use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::File is Log::Any::Adapter {
	has IO::Handle $!fh;

	method BUILD( :$path ) {
		$!fh = open $path, :a;
		die "File $path is not writable" if $!fh.e && ! $!fh.w;
	}

	method handle( $msg ) {
		$!fh.say( $msg );
		return True;
	}

}
