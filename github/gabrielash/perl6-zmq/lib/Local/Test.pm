
unit module Local::Test;
use v6;
use NativeCall;

sub try-say-rethrow(&f) is export {
    f();
    CATCH {
	default {	    
	    say "### $_.message()  ###";
	    $_.throw(); 
	}
    }
}

