# Config::TOML

TOML file parser and writer.


## Usage

TOML to Perl6:

```perl6
use Config::TOML;

# parse toml from string
my $toml = Q:to/EOF/;
[server]
host = "192.168.1.1"
ports = [ 8001, 8002, 8003 ]
EOF
my %toml = from-toml($toml);

# parse toml from file
my $file = 'config.toml';
my %toml = from-toml(:$file);
```

Perl6 to TOML:

```perl6
use Config::TOML;
my %h = :a<alpha>, :b<bravo>, :c<charlie>;
to-toml(%h);
```


## Advanced Usage

### Specifying a custom local offset for TOML date values

TOML date values can take three different forms:

1. [RFC 3339](http://tools.ietf.org/html/rfc3339) timestamps
   (`YYYY-MM-ddThh:mm:ss.ffff+zz`)
2. RFC 3339 timestamps with the local offset omitted
   (`YYYY-MM-ddThh:mm:ss.ffff`)
3. Standard calendar dates (`YYYY-MM-dd`)

Config::TOML builds Perl6 `Date`s from standard calendar dates.

By default, Config::TOML builds Perl6 `DateTime`s from TOML datetime
values that do not include a local offset using the host machine's local
offset. To override the default behavior of using the host machine's
local offset for date values where the offset is omitted, pass the
`date-local-offset` parameter (with an integer value) to `from-toml`:

```perl6
my $cfg = slurp 'config.toml';

# assume UTC when local offset unspecified in TOML dates
my %toml = from-toml($cfg, :date-local-offset(0));
```

To calculate a target timezone's local offset for the
`date-local-offset` parameter value, multiply its [UTC
offset](https://en.wikipedia.org/wiki/List_of_UTC_time_offsets) hours
by 60, add to this its UTC offset minutes, and multiply the result by 60.

Timezone            | UTC Offset | Calculation
---                 | ---        | ---
Africa/Johannesburg | UTC+02:00  | `((2 * 60) + 0) * 60 = 7200`
America/Los_Angeles | UTC-07:00  | `((-7 * 60) + 0) * 60 = -25200`
Asia/Seoul          | UTC+09:00  | `((9 * 60) + 0) * 60 = 32400`
Australia/Sydney    | UTC+10:00  | `((10 * 60) + 0) * 60 = 36000`
Europe/Berlin       | UTC+01:00  | `((1 * 60) + 0) * 60 = 3600`
UTC                 | UTC±00:00  | `((0 * 60) + 0) * 60 = 0`

To more easily ascertain your host machine's local offset, open a perl6
repl and print the value of `$*TZ`.


## Installation

### Dependencies

- Rakudo Perl6
- [Crane](https://github.com/atweiden/crane)


## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
