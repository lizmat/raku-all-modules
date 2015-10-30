unit module Locale::Script;

use Locale::Codes::Script_Codes;

constant LOCALE_SCRIPT_ALPHA   is export = 'alpha';
constant LOCALE_SCRIPT_NUMERIC is export = 'num';

sub data {
    return %Locale::Codes::Script_Codes::data;
}

our sub code2script($code) is export {
    if $code ~~ /^\d+$/ {
        return data()<code><num>{$code};
    } else {
        return data()<code><alpha>{tc $code};
    }
}

our sub script2code($name, $codeset='alpha') is export {
    return data()<name>{$codeset}{lc $name};
}

our sub all_script_codes($codeset='alpha') is export {
    return data()<code>{$codeset}.keys.sort;
}

our sub all_script_names() is export {
    return data()<code><alpha>.values.sort;
}