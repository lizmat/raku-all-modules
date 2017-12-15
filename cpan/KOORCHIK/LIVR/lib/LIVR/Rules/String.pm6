unit module LIVR::Rules::String;
use LIVR::Utils;

our sub one_of(@args is copy, %builders) {
    my @allowed-values;
    if (@args[0] ~~ Array) {
        @allowed-values = |@args[0];
    } else {
        @allowed-values = @args;
    }

    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        for @allowed-values -> $allowed-value {
            if $value eq $allowed-value {
                $output = $allowed-value;
                return;
            }
        }

        return 'NOT_ALLOWED_VALUE';
    }
}


our sub max_length([Int $max-length], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'TOO_LONG' if $value.chars > $max-length;
        
        $output = $value.Str;
        return;
    };
}

our sub min_length([Int $min-length], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'TOO_SHORT' if $value.chars < $min-length;
        
        $output = $value.Str;
        return;
    };
}

our sub length_equal([Int $length], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'TOO_SHORT' if $value.chars < $length;
        return 'TOO_LONG'  if $value.chars > $length;
        
        $output = $value.Str;
        return;
    };
}

our sub length_between([Int $min-length, $max-length], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'TOO_SHORT' if $value.chars < $min-length;
        return 'TOO_LONG'  if $value.chars > $max-length;
        
        $output = $value.Str;
        return;
    };
}

our sub like([$re, $flags = ''], %builders) {
    my $is-ignore-case = $flags.match('i');
    my $flagged-re;

    if $re ~~ Regex {
        # By livr-spec we expect  regex string (compatible cross languages). 
        # But if you want to use perl6 Regex than it will work too. 
        $flagged-re = $re;
    } else {
        die 'Use Perl6 Regex objects with "like" rule. String regexes are not supported yet';
        # TODO: I do not know how to build Perl5 regex from string in Perl6
        
        # This will not work.
        # $flagged-re = $is-ignore-case ?? rx:i:P5/$re/ !! rx:P5/$re/;
        
        # It is possibe to done this with EVAL, but I would like to avoid implicit EVALs.
    }

    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'WRONG_FORMAT' unless $value.match($flagged-re);
        
        $output = $value.Str;
        return;
    };
}

our sub string([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        
        $output = $value.Str;
        return;
    };
}

our sub equal([Cool $allowed-value], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        

        if $value eq $allowed-value {
            $output = $allowed-value;
            return;
        }
        
        return 'NOT_ALLOWED_VALUE';
    };
}
