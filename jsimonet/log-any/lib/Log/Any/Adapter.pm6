use v6.c;

=begin pod
The Adapter have to handle a log. Its actions can vary from logging the information
into STDOUT, into a File, or even sending the information into a external database.
=end pod

class Log::Any::Adapter {

=begin pod
=head1 handle
	Prototype method for handling the $msg.
=end pod

	method handle( $msg ) {
		...
	}

}

class Log::Any::Adapter::BlackHole is Log::Any::Adapter {
	method handle( $msg ) {
		# Do nothing with log
	}
}
