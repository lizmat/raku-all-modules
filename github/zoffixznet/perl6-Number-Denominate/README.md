[![Build Status](https://travis-ci.org/zoffixznet/perl6-Number-Denominate.svg)](https://travis-ci.org/zoffixznet/perl6-Number-Denominate)

# NAME

Number::Denominate - Break up numbers into preset or arbitrary denominations

# SYNOPSIS

```perl6
    use Number::Denominate;

    # 2 weeks, 6 hours, 56 minutes, and 7 seconds
    say denominate 1234567;

    # 1 day
    say denominate 23*3600 + 54*60 + 50, :1precision;

    # 21 tonnes, 212 kilograms, and 121 grams
    say denominate 21212121, :set<weight>;

    # This script's size is 284 bytes
    say "This script's size is " ~ denominate $*PROGRAM-NAME.IO.s, :set<info>;

    # 4 foos, 2 boors, and 1 ber
    say denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );

    # {:hours(6), :minutes(56), :seconds(7), :weeks(2)}
    say (denominate 1234567, :hash).perl;

    # [
    #   {:denomination(7),  :plural("weeks"),   :singular("week"),   :value(2) },
    #   {:denomination(24), :plural("days"),    :singular("day"),    :value(0) },
    #   {:denomination(60), :plural("hours"),   :singular("hour"),   :value(6) },
    #   {:denomination(60), :plural("minutes"), :singular("minute"), :value(56)},
    #   {:denomination(1),  :plural("seconds"), :singular("second"), :value(7) }
    #]
    say (denominate 1234567, :array).perl;
```

# TABLE OF CONTENTS
- [NAME](#name)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
- [EXPORTED SUBROUTINES](#exported-subroutines)
    - [`denominate`](#denominate)
        - [`array`](#array)
            - [`denomination`](#denomination)
            - [`plural`](#plural)
            - [`singular`](#singular)
            - [`value`](#value)
        - [`hash`](#hash)
        - [`precision`](#precision)
        - [`set`](#set)
            - [`info`](#info)
            - [`info-1024`](#info-1024)
            - [`length`](#length)
            - [`length-imperial`](#length-imperial)
            - [`length-mm`](#length-mm)
            - [`time`](#time)
            - [`volume`](#volume)
            - [`volume-imperial`](#volume-imperial)
            - [`weight`](#weight)
            - [`weight-imperial`](#weight-imperial)
        - [`string`](#string)
        - [`units`](#units)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# DESCRIPTION

Define arbitrary set of units and split up a number into those units. The
module includes preset sets of units for some measures

# EXPORTED SUBROUTINES

## `denominate`

```perl6
    say denominate 1234567;
    say denominate 23*3600 + 54*60 + 50, :1precision;
    denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );
    denominate 1234567, :hash;
    denominate 1234567, :array;

    # Valid unit sets: info info-1024 length length-imperial length-mm time
    # volume volume-imperial weight weight-imperial
    denominate 21212121, :set<weight>;
```

**Takes** one mandatory positional argument—the number to denominate—and
several optional named arguments that affect how the number is denominated
and what format the denomination is returned in. See [`hash`](#hash)
and [`array`](#array) arguments to modify the default [`string`](#string)
return value. The named arguments are as follows:

### `array`

```perl6
    # [
    #   {:denomination(7),  :plural("weeks"),   :singular("week"),   :value(2) },
    #   {:denomination(24), :plural("days"),    :singular("day"),    :value(0) },
    #   {:denomination(60), :plural("hours"),   :singular("hour"),   :value(6) },
    #   {:denomination(60), :plural("minutes"), :singular("minute"), :value(56)},
    #   {:denomination(1),  :plural("seconds"), :singular("second"), :value(7) }
    #]
    say (denominate 1234567, :array).perl;
```
Boolean. **Defaults to** `False`. When `True`, [`denominate`](#denominate)
will return denominations as an array of hashes. Each hash represents a single
unit and has the following keys. The array will always contain each
[`unit`](#units), ordered from largest to smallest.

#### `denomination`

How many of the next smaller unit fits into this unit. This value is `1` for
the smallest unit in the set.

#### `plural`

The plural name of the unit.

#### `singular`

The singular name of the unit.

#### `value`

The actual value of this unit.

### `hash`

```perl6
    # {:hours(6), :minutes(56), :seconds(7), :weeks(2)}
    say (denominate 1234567, :hash).perl;
```
Boolen. **Defaults to** `False`. When `True`, [`denominate`](#denominate)
will return denominations as a hash. The keys will be the **singular** names of
units and values will be the values of those units. **Note:** units whose values
are zero will not be included.

### `precision`

```perl6
    # 23 hours, 54 minutes, and 50 seconds
    say denominate 23*3600 + 54*60 + 50;

    # 1 day
    say denominate 23*3600 + 54*60 + 50, :1precision;

    # 23 hours and 55 minutes
    say denominate 23*3600 + 54*60 + 50, :2precision;
```
**Takes** positive integers as the value. **Defaults to** the number of
[`units`](#units) given (or the number of units in the [`set`](#set)).
Specifies how many, at most, units to include in the output. Rounding will
be performed if needed. When output mode is set to [`array`](#array), all units
will be present, but at most [`precision`](#precision) units will have non-zero
values.

### `set`

```perl6
    # 2 weeks, 6 hours, 56 minutes, and 7 seconds
    say denominate 1234567;

    # 21 tonnes, 212 kilograms, and 121 grams
    say denominate 21212121, :set<weight>;

    # This script's size is 284 bytes
    say "This script's size is " ~ denominate $*PROGRAM-NAME.IO.s, :set<info>;
```

Loads a pre-defined set of [`units`](#units) to use for denominations.
Has effect only when[`units`](#units) argument is not specified.
**Defaults to** [`time`](#time). **Takes** the name of one of the predefined
unit sets, which are as follows (see description of [`units`](#units) argument,
if the meaning of values is not clear):

#### `info`

```perl6
    yottabyte => 1000, zettabyte => 1000, exabyte => 1000, petabyte => 1000,
    terabyte  => 1000, gigabyte => 1000, megabyte => 1000, kilobyte => 1000,
    'byte'
```
Units of information.

#### `info-1024`

```perl6
    yobibyte => 1024, zebibyte => 1024, exbibyte => 1024, pebibyte => 1024,
    tebibyte => 1024, gibibyte => 1024, mebibyte => 1024, kibibyte => 1024,
    'byte'
```
Units of information (multiples of 1024).

#### `length`

```perl6
    'light year' => 9_460_730_472.5808,
        kilometer => 1000,
            'meter'
```
Units of length (large only).

#### `length-imperial`

```perl6
    mile => 1760,
        yard => 3,
            <foot feet> => 12,
                <inch inches>
```
Units of length (Imperial).

#### `length-mm`

```perl6
    'light year' => 9_460_730_472.5808,
        kilometer => 1000,
            meter => 100,
                centimeter => 10,
                    'millimeter'
```
Units of length (includes smaller units).

#### `time`

```perl6
    week => 7,
        day => 24,
            hour => 60,
                minute => 60,
                    'second'
```
Units of time.

#### `volume`

```perl6
    Liter => 1000,
        'milliliter'
```
Units of volume.

#### `volume-imperial`

```perl6
    gallon => 4,
        quart => 2,
            pint => 20,
                'fluid ounce'
```
Units of volume (Imperial).

#### `weight`

```perl6
    tonne => 1000,
        kilogram => 1000,
            'gram'
```
Units of weight.

#### `weight-imperial`

```perl6
    ton => 160,
        stone => 14,
            pound => 16,
                'ounce'
```
Units of weight (Imperial).

### `string`

```perl6
    # 2 weeks, 6 hours, 56 minutes, and 7 seconds
    say denominate 1234567;
```
Boolean. Has effect only when [`hash`](#hash) and [`array`](#array) arguments
are `False` (that's the default). **Defaults to** `True`. When `True`,
[`denominate`](#denominate) will return its output as a string. Units
whose values are zero won't be included, unless the number to denominate is
`0`, in which case the smallest available unit will be present in the
string (set to `0`).

### `units`

```perl6
    # 4 foos, 2 boors, and 1 ber
    say denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );

    # These two are the same:
    denominate 42, :units( day => 24, hour => 60,  minute => 60, 'second' );
    denominate 42, :units(
        <day days>       => 24,
        <hour hours>     => 60,
        <minute minutes> => 60,
        <second seconds>
    );
```
Specifies units to use for denominations. These can be set to one of the
presets using the [`set`](#set) argument. Takes a list of pairs where the
key is the name of the unit and the value is the number of the next smaller
unit that fits into this unit. The name is a list of singular and plural name
of the unit. If the name is set to a string, the plural name will be derived
by appending `s` to the singular unit name. The smallest unit is specified
simply as a string indicating its name (or as a list of singular/plural
strings).

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Number-Denominate

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Number-Denominate/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
