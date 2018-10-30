use v6.c;

use Log::Any::Adapter;

class Log::Any::Adapter::Stderr is Log::Any::Adapter {

	method handle( $msg ) {
		$*ERR.say: $msg;
		return True;
	}

}
