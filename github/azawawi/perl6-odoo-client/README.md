# Odoo::Client [![Build Status](https://travis-ci.org/azawawi/perl6-odoo-client.svg?branch=master)](https://travis-ci.org/azawawi/perl6-odoo-client) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-odoo-client?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-odoo-client/branch/master)

A simple Odoo ERP client that uses JSON RPC.

## Example

```Perl6
use v6;
use Odoo::Client;

my $odoo = Odoo::Client.new(
    hostname => "localhost",
    port     => 8069
);

my $uid = $odoo.login(
    database => "<database>",
    username => '<email>',
    password => "<password>"
);
printf("Logged on with user id '%d'\n", $uid);
```

For more examples, please see the [examples](examples) folder.

## Installation

To install it using zef (a module management tool bundled with Rakudo Star):

```
$ zef install Odoo::Client
```

## Testing

- To run tests:
```
$ prove -ve "perl6 -Ilib"
```

- To run all tests including author tests (Please make sure
[Test::Meta](https://github.com/jonathanstowe/Test-META) is installed):
```
$ zef install Test::META
$ AUTHOR_TESTING=1 prove -e "perl6 -Ilib"
```

## See Also

- [JSON::RPC](https://github.com/bbkr/jsonrpc)
- [Odoo ERP](http://odoo.com)
- [JSON-RPC Library](https://www.odoo.com/documentation/10.0/howtos/backend.html#json-rpc-library)

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
