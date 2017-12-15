unit module LIVR;

use LIVR::Validator;
use LIVR::Rules::Common;
use LIVR::Rules::Numeric;
use LIVR::Rules::String;
use LIVR::Rules::Special;
use LIVR::Rules::Modifiers;
use LIVR::Rules::Meta;

my %DEFAULT_RULES = (
    required         => &LIVR::Rules::Common::required,
    not_empty        => &LIVR::Rules::Common::not_empty,
    not_empty_list   => &LIVR::Rules::Common::not_empty_list,
    any_object       => &LIVR::Rules::Common::any_object,

    integer          => &LIVR::Rules::Numeric::integer,
    positive_integer => &LIVR::Rules::Numeric::positive_integer,
    decimal          => &LIVR::Rules::Numeric::decimal,
    positive_decimal => &LIVR::Rules::Numeric::positive_decimal,
    min_number       => &LIVR::Rules::Numeric::min_number,
    max_number       => &LIVR::Rules::Numeric::max_number,
    number_between   => &LIVR::Rules::Numeric::number_between,

    one_of           => &LIVR::Rules::String::one_of,
    min_length       => &LIVR::Rules::String::min_length,
    max_length       => &LIVR::Rules::String::max_length,
    length_between   => &LIVR::Rules::String::length_between,
    length_equal     => &LIVR::Rules::String::length_equal,
    like             => &LIVR::Rules::String::like,
    string           => &LIVR::Rules::String::string,
    eq               => &LIVR::Rules::String::equal,

    email            => &LIVR::Rules::Special::email,
    url              => &LIVR::Rules::Special::url,
    iso_date         => &LIVR::Rules::Special::iso_date,
    equal_to_field   => &LIVR::Rules::Special::equal_to_field,

    trim             => &LIVR::Rules::Modifiers::trim,
    to_lc            => &LIVR::Rules::Modifiers::to_lc,
    to_uc            => &LIVR::Rules::Modifiers::to_uc,
    remove           => &LIVR::Rules::Modifiers::remove,
    leave_only       => &LIVR::Rules::Modifiers::leave_only,
    default          => &LIVR::Rules::Modifiers::default,

    nested_object    => &LIVR::Rules::Meta::nested_object,
    variable_object  => &LIVR::Rules::Meta::variable_object,
    or               => &LIVR::Rules::Meta::livr_or,
    list_of          => &LIVR::Rules::Meta::list_of,
    list_of_objects  => &LIVR::Rules::Meta::list_of_objects,
    list_of_different_objects  => &LIVR::Rules::Meta::list_of_different_objects,
);

LIVR::Validator.register-default-rules(%DEFAULT_RULES);
