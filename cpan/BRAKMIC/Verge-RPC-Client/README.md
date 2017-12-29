# Perl6 Verge Client

This is a client for accessing the Verge [REST API](https://vergecurrency.com/langs/en/#developers)

More info about available API calls can be found [here](https://chainquery.com/bitcoin-api).

## Installation

`zef install .`

## Usage

```perl6
#!/usr/bin/env perl6

use v6;
use Verge::RPC::Client;
use Data::Dump;
use JSON::Tiny;

# Instantiate API client (set secure to True when accessing via HTTPS)
my $client = Verge::RPC::Client.new(url => 'localhost', secure => False);

# call execute method by providing API name + optional parameters.
my $result = $client.execute('gettransaction', 'bfecd267306825a2fe24fcb266a316385491533ed1f2528ff77392fda6966ca9');
# a JSON will be returned
say Dump from-json($result);
```

## LICENSE

[Artistic License 2.0](https://github.com/brakmic/Perl6-Verge-Client/blob/master/LICENSE)
