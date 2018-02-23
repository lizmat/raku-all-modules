[![Build Status](https://travis-ci.org/zoffixznet/perl6-p6lert.svg)](https://travis-ci.org/zoffixznet/perl6-p6lert)

# NAME

`p6lert` - Alerts from [alerts.perl6.org](https://alerts.perl6.org) on your command line

# SYNOPSIS

```bash
$ p6lert
Creating new config file /home/zoffix/.p6lert.conf

ID#5 | 2017-12-28T23:45:28Z | severity: high
affects: foos and meows | posted by: Zoffix Znet
testing5

ID#3 | 2017-12-28T23:42:14Z | severity: info
affects: foos and meows | posted by: Anonymous
testing3


$ p6lert
No new alerts

$ p6lert 5
ID#5 | 2017-12-28T23:45:28Z | severity: high
affects: foos and meows | posted by: Zoffix Znet
testing5
```

# DESCRIPTION

Fetch alerts from [alerts.perl6.org](https://alerts.perl6.org) on your
command line

# ARGUMENTS

## `--no-color`

`Bool`. If optional [`Terminal::ANSIColor`
module](https://modules.perl6.org/repo/Terminal::ANSIColor) is installed,
the program will add a splash of colour to its output. Passing `--no-color`
disables the colours, regardless of whether the module is installed.

```bash
$ p6lert --no-color
```

## alert ID

`UInt` positional argument. Can only be combined with `--no-color` argument.
Fetches alert whose id is the one given.

```bash
$ p6lert 42
```

## `--block-on`

`Str` where valid values are `info`, `low`,  `normal`, `high`, and  `critical`.
Defaults to `critical`. Specifies the minimum severity of alerts to watch for.
`info` is the lowest severity and `critical` is highest. Thus, if you specify
`--block-on=normal`, the program will watch for `normal`, `high`, and `critical`
alerts, but not for `low` or `info` (they latter would still be displayed, but
program won't block exit).

If the alert for wanted severity is seen, the program will block exit and wait
for user input. It will be a yes/no prompt and if the user enters "no", the
program will exit with a exit code `1`. This is handy for inclusion of this
program in, for example, compiler upgrade scripts, where you can block the
upgrade if you see some critical alert.

```bash
$ p6lert --block-on=high
```

## `--config`

`Str`. Specifies the path to the configuration file to use. The file will be
created if it does not exist. The default config file location is
`~/.p6lert.conf` or, if `$*HOME` is `Nil`, then in `./.p6lert.conf`

```bash
$ p6lert --config=/home/meows/p6alerter
```

The config file contains a JSON object that currently only has
`last-fetch-time` property. This property stores information about the time
the program last fetched any alerts. Only fresh alerts since that time will
be displayed when program is executed.

Passing value of `/dev/null` (or `nul` on
Windows) as `--config` will make the program ignore the config file loading
and it won't store `last-fetch-time`, giving full list of alerts on each load.

```bash
$ p6lert --config=/dev/null
```

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-p6lert

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-p6lert/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
