use v6.c;

class Log::Any::Formatter {
	proto method format( :$date-time, :$msg!, :$category!, :$severity! ) { ... }
}

class Log::Any::FormatterBuiltIN is Log::Any::Formatter {
	has Str $.format = '\m';

	method format( :$date-time, :$msg!, :$category!, :$severity! ) {
		my $format = $!format;
		# Replace every tag by his value

		$format.subst-mutate( '\d', $date-time, :g );
		$format.subst-mutate( '\s', $severity, :g );
		$format.subst-mutate( '\c', $category, :g );
		$format.subst-mutate( '\m', $msg, :g );

		return $format;
	}

}
