# Config::Clever

A clever, heirarchical config loader for perl6.

[![Build Status](https://travis-ci.org/ShaneKilkelly/perl6-config-clever.svg?branch=master)](https://travis-ci.org/ShaneKilkelly/perl6-config-clever)

## Config files

`Config::Clever.load` takes a String `environment` parameter and loads json files from the `config/` directory. The json objects are loaded and merged together in the following order:

- `default.json`
- `<environment>.json`
- `local-<environment>.json`

Calling `Config::Clever.load` without any parameters will use `default` as the environment. You can also supply a path to another config directory:
```perl6
my %config = Config::Clever.load(:environment("staging"), :config-dir("./my/weird/path"));
```

## Example

Imagine we have a directory `config`, with two files: `default.json` and `development.json`.

```json
// default.json
{
    "db": {
        "host": "localhost",
        "port": 27017,
        "user": null,
        "password": null,
        "auth": false
    },
    "logLevel": "DEBUG"
}

// development.json
{
    "db": {
        "user": "apprunner",
        "password": "a_terrible_password",
        "auth": true
    }
}
```

If we call `Config::Clever.load`, we'll get a hash which consists of the data from
`development.json` merged on top of the data in `default.json`.

```perl6
use v6;
use Config::Clever;

my %config = Config::Clever.load(:environment('development'));
say %config
# %config is a hash equivalent to:
#   {
#       "db": {
#           "host": "localhost",
#           "port": 27017,
#           "user": "apprunner",
#           "password": "a_terrible_password",
#           "auth": true
#       },
#       "logLevel": "DEBUG"
#   }
```


## Todo

- more tests
