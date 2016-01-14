use v6;

role Facter::Debug {
    our $debug = 0;

    multi method debugging {
        return $debug != 0
    }

    # Set debugging on or off (1/0)
    multi method debugging($bit) {
        if $bit {
            $debug = 1;
        }
        else {
            $debug = 0;
        }
    }

    method debug(Str $string) {
        if ! defined $string {
            return
        }
        if self.debugging {
            say $string;
        }
        return;
    }
}
