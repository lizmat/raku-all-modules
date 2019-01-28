unit module ENIGMA::Machine::Error is export;

class X::Error is Exception {
	has $.source;
	has $.reason;
    has $.suggestion = Nil;

	method message { 
        my $msg = "==> $!reason: $!source\n";
        $msg ~= "==> $!suggestion\n" with $!suggestion;
        return $msg;
    }
}
