use v6;
use Panda::Builder;

class Build is Panda::Builder {
	method build ($where) {
		mkdir "$where/lib/XHTML";
		my $out-file = open "$where/lib/XHTML/Writer.pm6", :w, :bin;
		die "Build.pm: could not write to $where/lib/XHTML/Writer.pm6" unless $out-file;
		my $proc = run 'perl6', "-I $where/lib", "$where/bin/generate-function-definition.p6", "$where/3rd-party/xhtml1-strict.xsd", out => $out-file, :bin;
		die "Build.pm: bin/generate-function-definition.p6 failed with {$proc.exitcode}" if $proc.exitcode;
	}
}

# sub MAIN($where  = '.') {
# 	Build.new.build($where);
# }
