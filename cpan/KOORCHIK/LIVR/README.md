[![Build Status](https://travis-ci.org/koorchik/perl6-livr.svg?branch=master)](https://travis-ci.org/koorchik/perl6-livr)

# LIVR::Validator

Lightweight and powerfull Perl6 validator supporting Language Independent Validation Rules Specification (LIVR)

## SYNOPSIS

```perl6
### Common usage
use LIVR;

LIVR::Validator.default-auto-trim(True);

my $validator = LIVR::Validator.new(livr-rules => {
    name      => 'required',
    email     => [ 'required', 'email' ],
    gender    => { one_of => ['male', 'female'] },
    phone     => { max_length => 10 },
    password  => [ 'required', {min_length => 10} ],
    password2 => { equal_to_field => 'password' }
});

my $user-data = {
    name      => 'Viktor',
    email     => 'viktor@mail.com ',
    gender    => 'male',
    password  => 'mypassword123',
    password2 => 'mypassword123'
}

if my $valid-data = $validator.validate($user-data) {
    #  $valid-data is clean and does contain only fields which have validation and have passed it
    $valid-data.say;
} else {
    my $errors = $validator.errors();
    $errors.say;
}

### You can use modifiers separately or can combine them with validation:
my $validator = LIVR::Validator.new(livr-rules => {
    email => [ 'required', 'trim', 'email', 'to_lc' ]
});

### Feel free to register your own rules
# You can use aliases(prefferable, syntax covered by the specification) for a lot of cases:

my $validator = LIVR::Validator.new(livr-rules => {
    password => ['required', 'strong_password']
});

$validator.register-aliased-rule({
    name  => 'strong_password',
    rules => {min_length => 6},
    error => 'WEAK_PASSWORD'
});

# or you can write more sophisticated rules directly

my $validator = LIVR::Validator.new(livr-rules => {
    password => ['required', 'strong_password']
});

$validator.register-rules( 'strong_password' =>  sub ([], %builders) {
    return sub ($value, $all-values, $output is rw) {
        # We already have "required" rule to check that the value is present
        return if LIVR::Utils::is-no-value($value); # so we skip empty values
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;

        # Return error in case of failed validation
        return 'WEAK_PASSWORD' if $value.chars < 6;
        
        # Change output value. We want always return value be a string
        $output = $value.Str; 
        return;
    };
});

### If you want to stop on the first error
# you can overwrite all rules with your own which use exceptions
my $default-rules = LIVR::Validator.get-default-rules();

for %$default-rules.kv -> $rule-name, $rule-builder {
    LIVR::Validator.register-default-rules($rule-name => sub (@args, %builders) {
        my $value-validator = $rule-builder(@args, %builders);
        
        return sub ($value, $all-values, $output is rw)  {        
            my $error = $value-validator($value, $all-values, $output);

            die "ERROR: $error" if $error;
            return;
        }
    });
}
```

## DESCRIPTION

LIVR::Validator lightweight validator supporting Language Independent Validation Rules Specification (LIVR)

See ['LIVR Specification'](http://livr-spec.org) for rules documentation.

Features:

* Rules are declarative and language independent
* Any number of rules for each field
* Return together errors for all fields
* Excludes all fields that do not have validation rules described
* Has possibility to validatate complex hierarchical structures
* Easy to describe and undersand rules
* Returns understandable error codes(not error messages)
* Easy to add own rules
* Multipurpose (user input validation, configs validation, contracts programming etc)

## CLASS METHODS

### LIVR::Validator.new(livr-rules =>  $LIVR, is-auto-trim => $IS-AUTO-TRIM)

Contructor creates validator objects.

$LIVR - validations rules. Rules description is available here - ['LIVR Specification'](http://livr-spec.org)

$IS-AUTO-TRIM - asks validator to trim all values before validation. Output will be also trimmed.
if $IS-AUTO-TRIM is undef then default-auto-trim value will be used.

### LIVR::Validator.register-aliased-default-rule( $ALIAS )

$ALIAS - is a hash that contains: name, rules, error (optional).

```perl6
LIVR::Validator.register-aliased-default-rule({
    name  => 'valid_address',
    rules => { nested_object => {
        country => 'required',
        city    => 'required',
        zip     => 'positive_integer'
    }}
});
```

Then you can use "valid\_address" for validation:

```perl6
{
    address => 'valid_address'
}
```


You can register aliases with own errors:

```perl6
LIVR::Validator.register-aliased-default-rule({
    name  => 'adult_age'
    rules => [ 'positive_integer', { min_number => 18 } ],
    error => 'WRONG_AGE'
});
```

All rules/aliases for the validator are equal. The validator does not distinguish "required", "list\_of\_different\_objects" and "trim" rules. So, you can extend validator with any rules/alias you like.


### LIVR::Validator.register-default-rules( RULE_NAME => &RULE_BUILDER, ... )

&RULE_BUILDER - is a subroutine reference which will be called for building single value validator.

```perl6
LIVR::Validator.register-default-rules( my_rule => sub (@rule-args, %builders) {
    # %builders - are rules from original validator
    # to allow you create new validator with all supported rules
    # my $validator = LIVR::Validator.new(livr-rules => $livr).register-rules(%builders).prepare();

    return sub ($value, $all-values, $output is rw) {
        # We already have "required" rule to check that the value is present
        # return if LIVR::Utils::is-no-value($value); # so it makes sense to skip empty values


        if ($not_valid) {
            return "SOME_ERROR_CODE"
        }
        else {
            # Do nothing 
            $ or change output. Just assign a new value to $output
        }
    };
});
```

Then you can use "my_rule" for validation:

```perl6
{
    name1 => 'my_rule' # Call without parameters
    name2 => { 'my_rule' => $arg1 } # Call with one parameter.
    name3 => { 'my_rule' => [$arg1] } # Call with one parameter.
    name4 => { 'my_rule' => [ $arg1, $arg2, $arg3 ] } # Call with many parameters.
}
```

Here is "max_number" implemenation:

```perl6
sub max-number([Numeric $max-number], %builders) {
    return sub ($value, %all-values, $output is rw) {
        return if LIVR::Util::is-no-value($value);
        return 'FORMAT_ERROR' if $value !~~ Str && $value !~~ Numeric;
        return 'NOT_NUMBER' unless looks-like-number($value);

        return 'TOO_HIGH' if $value > $max-number;

        $output = $value.Numeric;
        return;
    };
}

LIVR::Validator.register-default-rules( max_number => &max-number );
```

All rules for the validator are equal. The validator does not distinguish "required", "list_of_different_objects" and "trim" rules.
So, you can extend validator with any rules you like.

Just look at the existing rules implementation:

* LIVR::Validator::Rules::Common
* LIVR::Validator::Rules::String;
* LIVR::Validator::Rules::Numeric;
* LIVR::Validator::Rules::Special;
* LIVR::Validator::Rules::Meta;
* LIVR::Validator::Rules::Modifiers;

All rules description is available here - ['LIVR Specification'](http://livr-spec.org)


### LIVR::Validator.get-default-rules( )

returns hashref containing all default rule_builders for the validator.
You can register new rule or update existing one with "register-rules" method.

### LIVR::Validator.default-auto-trim($IS-AUTO-TRIM)

Enables or disables automatic trim for input data. If is on then every new validator instance will have auto trim option enabled

## OBJECT METHODS

### $VALIDATOR.validate(%INPUT)

Validates user input. On success returns $VALID-DATA (contains only data that has described validation rules). On error return false.

```perl6
my $VALID-DATA = $VALIDATOR.validate(%INPUT)

if ($VALID-DATA) {

} else {
    my $errors = $VALIDATOR.errors();
}
```

### $VALIDATOR.errors( )

Returns errors hash.

```perl6
{
    "field1" => "ERROR_CODE",
    "field2" => "ERROR_CODE",
    ...
}
```

For example:

```perl6
{
    "country"  => "NOT_ALLOWED_VALUE",
    "zip"      => "NOT_POSITIVE_INTEGER",
    "street"   => "REQUIRED",
    "building" => "NOT_POSITIVE_INTEGER"
}
```

### $VALIDATOR.register-rules( RULE_NAME => &RULE\_BUILDER, ... )

&RULE_BUILDER - is a subtorutine reference which will be called for building single rule validator.

See "LIVR::Validator.register-default-rules" for rules examples.

### $VALIDATOR.register-aliased-rule( $ALIAS )

$ALIAS - is a composite validation rule.

See "LIVR::Validator.register-aliased-default-rule" for rules examples.

### $VALIDATOR.get-rules( )

returns hashref containing all rule_builders for the validator. You can register new rule or update existing one with "register-rules" method.

## AUTHOR

Viktor Turskyi, @koorchik

## BUGS

Please report any bugs or feature requests to Github 

* Perl6 specific issues https://github.com/koorchik/perl6-livr/issues
* The spec specific issues https://github.com/koorchik/livr/issues

## SUPPORT

See https://github.com/koorchik/perl6-livr

## LICENSE AND COPYRIGHT

Copyright 2017 Viktor Turskyi.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

http://www.perlfoundation.org/artistic_license_2_0

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
