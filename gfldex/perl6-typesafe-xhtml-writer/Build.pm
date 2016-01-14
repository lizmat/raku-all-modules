use v6;
use Panda::Builder;

class Build is Panda::Builder {
	method build ($where) {
		mkdir "$where/lib/Typesafe/XHTML";
		my $out-file = open "$where/lib/Typesafe/XHTML/Writer.pm6", :w, :bin;
		die "Build.pm: could not write to $where/lib/Typesafe/XHTML/Writer.pm6" unless $out-file;
		my $proc = run 'perl6', "-I $where/lib/Typesafe", "$where/bin/generate-function-definition.p6", "$where/3rd-party/xhtml1-strict.xsd", out => $out-file, :bin;
		die "Build.pm: bin/generate-function-definition.p6 failed with {$proc.exitcode}" if $proc.exitcode;
	}
}

# sub MAIN($where  = '.') {
# 	Build.new.build($where);
# }
