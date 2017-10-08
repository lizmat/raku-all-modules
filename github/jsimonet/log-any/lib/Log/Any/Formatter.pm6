use v6.c;

class Log::Any::Formatter {
	proto method format( :$date-time, :$msg!, :$category!, :$severity!, :%extra-fields ) { ... }
}

class Log::Any::FormatterBuiltIN is Log::Any::Formatter {
	has Str $.format = '\m';

	method format( :$date-time, :$msg!, :$category!, :$severity!, :%extra-fields ) {
		my $format = $!format;
		# Replace every tag by his value

		$format.subst-mutate( '\d', $date-time, :g );
		$format.subst-mutate( '\s', $severity, :g );
		$format.subst-mutate( '\c', $category, :g );
		$format.subst-mutate( '\m', $msg, :g );

		for %extra-fields.kv -> $k, $v {
			$format.subst-mutate( '\e{'~$k~'}', $v, :g );
		}

		return $format;
	}

}
