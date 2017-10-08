unit module Locale::Country;

use Locale::Codes::Country_Codes;

constant LOCALE_CODE_ALPHA_2 is export = 'alpha-2';
constant LOCALE_CODE_ALPHA_3 is export = 'alpha-3';
constant LOCALE_CODE_NUMERIC is export = 'numeric';

sub data {
    return %Locale::Codes::Country_Codes::data;
}

our sub code2country($code) is export {
    if $code.chars == 2 {
        return data()<code><alpha-2>{uc $code};
    } elsif $code ~~ /^\d+$/ {
        return data()<code><numeric>{$code};
    } elsif $code.chars == 3 {
        return data()<code><alpha-3>{uc $code};
    }
}

our sub country2code($name, $codeset='alpha-2') is export {
    return data()<name>{$codeset}{lc $name};
}

our sub all_country_codes($codeset='alpha-2') is export {
    return data()<code>{$codeset}.keys.sort;
}

our sub all_country_names() is export {
    return data()<code><alpha-2>.values.sort;
}