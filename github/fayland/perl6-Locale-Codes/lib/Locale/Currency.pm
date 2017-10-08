unit module Locale::Currency;

use Locale::Codes::Currency_Codes;

constant LOCALE_CURR_ALPHA   is export = 'alpha';
constant LOCALE_CURR_NUMERIC is export = 'num';

sub data {
    return %Locale::Codes::Currency_Codes::data;
}

our sub code2currency($code) is export {
    if $code ~~ /^\d+$/ {
        return data()<code><num>{$code};
    } else {
        return data()<code><alpha>{uc $code};
    }
}

our sub currency2code($name, $codeset='alpha') is export {
    return data()<name>{$codeset}{lc $name};
}

our sub all_currency_codes($codeset='alpha') is export {
    return data()<code>{$codeset}.keys.sort;
}

our sub all_currency_names() is export {
    return data()<code><alpha>.values.sort;
}