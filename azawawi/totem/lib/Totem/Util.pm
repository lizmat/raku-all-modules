use v6;

use URI::Escape;

module Totem::Util
{

	our sub get-parameter(Str $input, Str $name) {
		# TODO more generic parameter parsing
		my $value = $input;
		$value ~~ s/^$name\=//;
		uri_unescape($value);
	}

	#TODO refactor into Totem::Types (like Mojo::Types)
	our sub find-mime-type(Str $filename) {
		my %mime-types = ( 
			'html' => 'text/html',
			'css'  => 'text/css',
			'js'   => 'text/javascript',
			'png'  => 'image/png',
			'ico'  => 'image/vnd.microsoft.icon',
			'svg'  => 'image/svg+xml',
		);
		
		my $mime-type;
		if ($filename ~~ /\.(\w+)$/) {
			$mime-type = %mime-types{$0} // 'text/plain';
		} else {
			$mime-type = 'text/plain';
		}

		$mime-type;
	}

	our sub find-perl6-dir(@perl6-dirs) {
		my @dirs = $*SPEC.splitdir($*EXECUTABLE);
		@dirs = @dirs[0..*-3], 'languages', 'perl6', @perl6-dirs;

		return \@dirs, $*SPEC.catdir( @dirs );
	}


}
