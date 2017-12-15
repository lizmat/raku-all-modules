unit module LIVR::Rules::Numeric;
use LIVR::Utils;

our sub integer([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'NOT_INTEGER' unless looks-like-number($value) && $value.Int eq $value;
        $output = $value.Int;
        return;
    };
}

our sub positive_integer([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'NOT_POSITIVE_INTEGER' unless looks-like-number($value)
                                          && $value.Int eq $value
                                          && $value > 0;

        $output = $value.Int;
        return;
    };
}

our sub decimal([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'NOT_DECIMAL' unless looks-like-number($value);

        $output = $value.Numeric;
        return;
    };
}

our sub positive_decimal([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;


        return 'NOT_POSITIVE_DECIMAL' unless looks-like-number($value)
                                          && $value > 0;
                                 
        $output = $value.Numeric;
        return;
    };
}

our sub max_number([Numeric $max-number], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        return 'NOT_NUMBER' unless looks-like-number($value);

        return 'TOO_HIGH' if $value > $max-number;

        $output = $value.Numeric;
        return;
    };
}

our sub min_number([Numeric $min-number], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        return 'NOT_NUMBER' unless looks-like-number($value);

        return 'TOO_LOW' if $value < $min-number;
        
        $output = $value.Numeric;
        return;
    };
}

our sub number_between([Numeric $min-number, Numeric $max-number], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        return 'NOT_NUMBER' unless looks-like-number($value);

        return 'TOO_LOW' if $value < $min-number;
        return 'TOO_HIGH' if $value > $max-number;
        
        $output = $value.Numeric;
        return;
    };
}
