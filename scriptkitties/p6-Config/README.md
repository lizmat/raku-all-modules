# Config
A perl 6 library for reading and writing configuration files.

[![Build Status](https://travis-ci.org/scriptkitties/p6-Config.svg?branch=master)](https://travis-ci.org/scriptkitties/p6-Config)

## Installation
This module can be installed using `zef`:

```
zef install Config
```

Depending on the type of configuration file you want to work on, you will need a
`Config::Parser::` module as well. If you just want an easy-to-use configuration
object without reading/writing a file, no parser is needed.

## Usage
Include the `Config` module in your script, instantiate it and use it as you
please.

```perl6
use Config;

my $config = Config.new();

# load a simple configuration hash
$config.read({
    keyOne => "value",
    keyTwo => {
        NestedKey => "other value"
    }
});

# load a configuration files
$config.read("/etc/config.yaml");

# load a configuration file with a specific parser
$config.read("/etc/config", "Config::Parser::ini");

# retrieve a simple key
$config.get("keyOne");

# retrieve a nested key
$config.get("keyTwo.NestedKey");

# write out the configuration file
$config.write("/etc/config.yaml");

# write out the configuration in another format
$config.write("/etc/config.json", "Config::Parser::json");
```

### Available parsers
Because there's so many ways to structure your configuration files, the parsers
for these are their own modules. This allows for easy implementing new parsers,
or providing a custom parser for your project's configuration file.

The parser will be loaded during runtime, but you have to make sure it is
installed yourself.

The following parsers are available:

- [`Config::Parser::yaml`](https://github.com/scriptkitties/p6-Config-Parser-yaml)

### Writing your own parser
If you want to make your own parser, simply make a new class in the
`Config::Parser` namespace. This class should extend the `Config::Parser` class,
and implement the `read` and `write` methods. The `read` method *must* return a
`Hash`. The `write` method *must* return a `Bool`, `True` when writing was
successful, `False` if not.

## License
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
