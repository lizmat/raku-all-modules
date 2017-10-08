unit module Locale::Language;

use Locale::Codes::Language_Codes;

constant LOCALE_LANG_ALPHA_2 is export = 'alpha-2';
constant LOCALE_LANG_ALPHA_3 is export = 'alpha-3';
constant LOCALE_LANG_TERM    is export = 'term';

sub data {
    return %Locale::Codes::Language_Codes::data;
}

our sub code2language($code, $codeset='alpha-3') is export {
    if $code.chars == 2 {
        return data()<code><alpha-2>{uc $code};
    } elsif $code.chars == 3 {
        if $codeset == 'term' {
            return data()<code><term>{uc $code};
        } else {
            return data()<code><alpha-3>{uc $code};
        }
    }
}

our sub language2code($name, $codeset='alpha-2') is export {
    return data()<name>{$codeset}{lc $name};
}

our sub all_language_codes($codeset='alpha-2') is export {
    return data()<code>{$codeset}.keys.sort;
}

our sub all_language_names() is export {
    return data()<code><alpha-2>.values.sort;
}