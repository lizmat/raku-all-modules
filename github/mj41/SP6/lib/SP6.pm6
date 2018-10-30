unit class SP6;

use MONKEY-SEE-NO-EVAL;

has $.templ_dir = '.';
has $.debug = 0;

class X::SP6::Error is Exception {
     has $.reason;
     method message() { return $.reason };
}

method full_tfpath(Str $tfpath) {
	return $.templ_dir ~ '/' ~ $tfpath;
}

method tstr2tcode(Str $str) {
	return 'Qc ｢' ~ $str ~ '｣;';
}

method slurp_tcode(Str $tfpath) {
	my $full_tfpath = self.full_tfpath($tfpath);

	die X::SP6::Error.new(
		reason => "Template file $tfpath (path '$full_tfpath') not found."
	) unless $full_tfpath.IO ~~ :e;
	say "Template fpath: '$full_tfpath'" if $.debug;

	my $tcode = self.tstr2tcode( slurp($full_tfpath) );
	say "code: {$tcode.perl}" if $.debug;
	return $tcode;
}

multi method process_include(Str $tfpath, %v is copy) {
	use SP6::ProcessMethods;

	sub include($inc_tfpath) {
		return self.process_include($inc_tfpath, %v);
	}

	my $tcode = self.slurp_tcode($tfpath);
	my $out = EVAL $tcode;
	return $out;

	CATCH {
		when X::SP6::Error { die $_ }
		when X::Comp { die "Error while compiling included template '$tfpath':\n$_" }
		default { die "Error running included template '$tfpath':\n$_" }
	}
}

multi method process_tstr(Str $tstr) {
	my %v;
	use SP6::ProcessMethods;

	sub include($inc_tfpath) {
		return self.process_include($inc_tfpath, %v);
	}

	my $tcode = self.tstr2tcode( $tstr );
	say "code: {$tcode.perl}" if $.debug;
	my $out = EVAL $tcode;
	return $out;

	CATCH {
		when X::Comp { die "Error while compiling template string '$tstr':\n$_" }
		default { die "Error running template string '$tstr':\n$_" }
	}
}

multi method process_tstr_inside(Str $tstr, Str :$inside_tfpath!) {
	my %v;
	use SP6::ProcessMethods;

	sub main_part {
		return self.process_tstr($tstr);
	}

	sub include($inc_tfpath) {
		return self.process_include($inc_tfpath, %v);
	}

	my $inside_tcode = self.slurp_tcode($inside_tfpath);
	my $out = EVAL $inside_tcode;
	return $out;

	CATCH {
		when X::Comp { die "Error while compiling template string '$tstr' inside '$inside_tfpath':\n$_" }
		default { die "Error running template string '$tstr' inside '$inside_tfpath':\n$_" }
	}
}

multi method process_file(Str $tfpath) {
	my %v;
	use SP6::ProcessMethods;

	sub include($inc_tfpath) {
		return self.process_include($inc_tfpath, %v);
	}

	my $tcode = self.slurp_tcode($tfpath);
	my $out = EVAL $tcode;
	return $out;

	CATCH {
		when X::SP6::Error { die $_ }
		when X::Comp { die "Error while compiling template '$tfpath':\n$_" }
		default { die "Error running template '$tfpath':\n$_" }
	}
}

multi method process_file_inside(Str $tfpath, Str :$inside_tfpath!) {
	my %v;
	use SP6::ProcessMethods;

	sub main_part {
		return self.process_file($tfpath);
	}

	sub include($inc_tfpath) {
		return self.process_include($inc_tfpath, %v);
	}

	my $inside_tcode = self.slurp_tcode($inside_tfpath);
	my $out = EVAL $inside_tcode;
	return $out;

	CATCH {
		when X::SP6::Error { die $_ }
		when X::Comp { die "Error while compiling template '$tfpath' inside '$inside_tfpath':\n$_" }
		default { die "Error while running template '$tfpath' inside '$inside_tfpath':\n$_" }
	}
}

multi method process(Str :$tfpath!, Str :$inside_tfpath, Bool :$debug) {
	return self.process_file($tfpath) unless defined $inside_tfpath;
	return self.process_file_inside($tfpath, :$inside_tfpath);
}

multi method process(Str :$tstr!, Str :$inside_tfpath, Bool :$debug) {
	return self.process_tstr($tstr) unless defined $inside_tfpath;
	return self.process_tstr_inside($tstr, :$inside_tfpath);
}
