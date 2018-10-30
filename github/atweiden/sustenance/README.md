# Sustenance

Calorie tracker


## Synopsis

In `sustenance.toml`:

```toml
# pantry
[[food]]
name = 'oats'
serving-size = '1 cup'
calories = 360
protein = 14
carbs = 58
fat = 6

# meals
[[meal]]
date = 2018-05-31
time = 10:15:00

  [[meal.portion]]
  food = 'oats'
  servings = 1.5
```

**cli**:

```sh
export PERL6LIB=lib
bin/sustenance --date=2018-05-31 gen-macros sustenance.toml
```

**perl6**:

```perl6
use Sustenance;
Sustenance.new(:file<sustenance.toml>).gen-macros;
```


## Description

Analyzes caloric intake from Sustenance TOML log.

Sustenance TOML log should be formatted per the synopsis. Sustenance
TOML log must consist of at least one *food* entry and at least one
*meal* entry.

Each *food* entry must have:

key            | type
---            | ---
`name`         | string
`serving-size` | string
`calories`     | number
`protein`      | number
`carbs`        | number
`fat`          | number

Each *meal* entry must have:

key       | type
---       | ---
`date`    | date
`time`    | time
`portion` | array of hashes

Each meal *portion* must have:

key        | type
---        | ---
`food`     | string
`servings` | number


## Installation

### Dependencies

- Rakudo Perl6
- [Config::TOML](https://github.com/atweiden/config-toml)


## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
