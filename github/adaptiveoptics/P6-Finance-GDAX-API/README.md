# NAME

Finance::GDAX::API - Role for GDAX Crypto-currency Exchange API

# SYNOPSIS

This is a role and should not be punted into existence except for
testing. But the methods and attributes are a applied to all
Finance::GDAX::API::* classes, except for Finance::GDAX::API::URL,
(and ::Types) which this role does.

```perl
  $req = Finance::GDAX::API.new(
      key        => 'My API Key',
      secret     => 'My API Secret Key',
      passphrase => 'My API Passphrase');

  $req.path     = 'accounts';
  $account_list = $req.send;

  # Use the more specific classes, for example Account:

  $account = Finance::GDAX::API::Account.new(
      key        => 'My API Key',
      secret     => 'My API Secret Key',
      passphrase => 'My API Passphrase');
  
  $account_list = $account.get-all;
  $account_info = $account.get( id => '89we-wefjbwe-wefwe-woowi');

  # If you use Environment variables to store your secrects, you can
  # omit them in the constructors (see the Attributes below)

  $order = Finance::GDAX::API::Order.new;
  $orders = $order.list( status     => ['open','settled'],
                         product-id => 'BTC-USD' );
```

# DESCRIPTION

Creates a signed GDAX REST request - you need to provide the key,
secret and passphrase attributes, or specify that they be provided by
the external_secret method.

All Finance::GDAX::API::* modules do this role to implement their
particular portion of the GDAX API.

This is a low-level implementation of the GDAX API and complete,
except for supporting result paging.

Return values are generally returned as arrays, hashes, arrays of
hashes, hashes of arrays and all are documented within each method.

All REST requests use https requests.

# ATTRIBUTES

## debug (default: True)

Use debug mode (sandbox) or prouduction. By default requests are done
with debug mode enabled which means connections will be made to the
sandbox API. To do live data, you must set debug to False.

## key

The GDAX API key. This defaults to the environment variable
%*ENV<GDAX_API_KEY>

## secret

The GDAX API secret key. This defaults to the environment variable
%*ENV<GDAX_API_SECRET>

## passphrase

The GDAX API passphrase. This defaults to the environment variable
%*ENV<GDAX_API_PASSPHRASE>

## signed (default: True)

Whether or not to cryptographically sign the REST request, which is
required for all private endpoints. Boolean.

## error

Returns the text of an error message if there were any in the request
after calling the "send" method.

## response_code

Returns the numeric HTTP status code of the request after "send".

## method (default: PUT)

REST method to use when data is submitted. Must be in
upper-case. (POST, PUT, DELETE and GET currently supported).

## path (default: '/')

The base URI path for the REST method, which must be set or errors will
result for anything other than "/". Do not use leading '/'.

## body [array|hash]

An array or hash that will be JSONified and represents the data being
sent in the REST request body. This is optional.

## timestamp (default: current unix epoch)

An integer representing the Unix epoch of the request. This defaults
to the current epoch time and will remain so as long as this object
exists.

## timeout (default: 180)

Integer time in seconds to wait for response to request.

# METHODS

## send

Sends the GDAX API request, returning the JSON response content as a
perl data structure. Each Finance::GDAX::API::* class documents this
structure (what to expect), as does the GDAX API (which will always be
authoritative).

## external_secret (Str :filename, Bool :fork?)

If you want to avoid hard-coding secrets into your code, this
convenience method may be able to help.

The method looks externally, either to a filename (default) or calls
an executable file to provide the secrets via STDIN.

Either way, the source of the secrets should provide key/value pairs
delimited by colons, one per line:

key:ThiSisMybiglongkey
secret:HerEISmYSupeRSecret
passphrase:andTHisiSMypassPhraSE

There can be comments ("#" beginning a line), and blank lines.

In other words, for exmple, if you cryptographically store your API
credentials, you can create a small callable program that will decrypt
them and provide them, so that they never live on disk unencrypted,
and never show up in process listings:

```perl
  my $request = Finance::GDAX::API.new;
  $request.external_secret(filename => '/path/to/my_decryptor --decrypt myfile.aes',
                           fork     => True);
```

This would assign the key, secret and passphrase attributes for you by
forking and running the 'my_decryptor' program. The "fork" boolean
designates a fork of a program rather than just reading from a
filename.

This method will die easily if things aren't right.

## save_secrets_to_environment

Another convenience method that can be used to store your secrets into
the volatile environment in which your perl is running, so that
subsequent GDAX API object instances will not need to have the key,
secret and passphrase set.

You may not want to do this! It stores each attribute, "key", "secret"
and "passphrase" to the environment variables "GDAX_API_KEY",
"GDAX_API_SECRET" and "GDAX_API_PASSPHRASE", respectively.

# METHODS you probably don't need to worry about

## signature

Returns a string, base64-encoded representing the HMAC digest
signature of the request, generated from the secrey key.

## body_json

Returns a string, the JSON-encoded representation of the data
structure referenced by the "body" attribute. You don't normally need
to look at this.

# AUTHOR

Mark Rushing <mark@orbislumen.net>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 6 programming language system itself.
