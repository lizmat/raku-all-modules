unit module LIVR::Rules::Special;
use LIVR::Utils;
use Email::Valid;

my $email-validator = Email::Valid.new(:simple(True));

our sub email([], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'WRONG_EMAIL' unless $email-validator.validate($value.Str);

        # issue in Email::Valid https://github.com/Demayl/perl6-Email-Valid/issues/6
        return 'WRONG_EMAIL' if $email-validator.parse($value.Str)<email><domain> ~~ /_/; 
        return;
    };
}

our sub equal_to_field([$field], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        return 'FIELDS_NOT_EQUAL' unless $value eq %all-values{$field};
        return;
    };
}

our sub url([], %builders) {
    my $url-re = rx:P5`^(?:(?:https?)://(?:(?:(?:(?:(?:(?:[a-zA-Z0-9][-a-zA-Z0-9]*)?[a-zA-Z0-9])[.])*(?:[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9]|[a-zA-Z])[.]?)|(?:[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+)))(?::(?:(?:[0-9]*)))?(?:/(?:(?:(?:(?:(?:(?:[a-zA-Z0-9\-_.!~*'():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*'():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*)(?:/(?:(?:(?:[a-zA-Z0-9\-_.!~*'():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)(?:;(?:(?:[a-zA-Z0-9\-_.!~*'():@&=+$,]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*))*))*))(?:[?](?:(?:(?:[;/?:@&=+$,a-zA-Z0-9\-_.!~*'()]+|(?:%[a-fA-F0-9][a-fA-F0-9]))*)))?))?)$`;
    my $anchor-re = rx:P5/#[^#]*$/;

    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        if ($value.chars < 2083 && $value.subst($anchor-re, '').lc.match($url-re)) {
            $output = $value.Str;
            return;
        }

        return 'WRONG_URL';
    };
}

our sub iso_date([], %builders) {
    my $iso-date-re = rx/^
        \d ** 4 \-               # year
        <[0..1]><[0..9]> \-      # month
        <[0..3]><[0..9]>         # day
    $/;

    return sub ($value, %all-values, $output is rw) {
        return if is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        
        if $value ~~ $iso-date-re {
            my Date $date = Date.new($value);
       
            return if $date eq $value;

            CATCH {
                return 'WRONG_DATE';
            }
        }

        return 'WRONG_DATE';
    };
}
