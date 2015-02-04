P6-Net-DNS
==========

A simple DNS resolver.

If you need a request type that isn't yet supported, open a github issue and it
will be added (hopefully) quickly.

Note: If you are behind a firewall that blocks Google DNS, you will need to set
DNS_TEST_HOST in your environment to pass the tests.

## Example Usage ##

    my $resolver = Net::DNS.new('8.8.8.8'); # google dns server
    my @addresses = $resolver.lookup('A', 'google.com'); # ("1.2.3.4", "5.6.7.8", ...)

## Methods ##

 -  `new(Str $host, $socket = IO::Socket::INET)`
    
    Creates a new DNS resolver using the specified DNS server.

    The `$socket` parameter lets you inject your own socket class to use for the
    query (so you can do a proxy negotiation or somesuch first).

 -  `lookup(Str $type, Str $name)`

    Looks up the specified $name, looking for records of $type. Returns a list of
    response classes, specified below. A failed lookup returns an empty list.

## Supported DNS Types ##

The return of a lookup is a list of classes. Which class depends on the request
type.

The object returned will stringify to something useful, and will also provide
attributes to access each piece of information that was returned.

Note that all of these classes also have a `@.owner-name` attribute. Normally this
is the same as the domain name you did the lookup on.

 -  `A`

    Returns a class with attribute `@.octets`, which will have 4 elements.

    Stringifies to an ip address ("192.168.0.1")

 -  `AAAA`

    Returns a class with attribute `@.octets`, which will have 16 elements.

    Stringifies to an ipv6 address ("2607:f8b0:…")

 -  `CNAME`

    Returns a class with attribute `@.name`, which is a domain name split on '.'.
    To get the full domain name, call $object.name.join('.');

    Stringifies to a domain name.

 -  `MX`

    Returns a class with attributes `$.priority`, `@.name`.

    Stringifies to a domain name.

 -  `NS`

    Returns a class with attribute `@.name`

    Stringifies to a domain name.

 -  `PTR`

    Returns a class with attribute `@.name`

    Stringifies to a domain name.

 -  `SRV`

    Returns a class with the attributes `$.priority`, `$.weight`, `$.port`, `@.name`.

    Stringifies to "the.server:port".

 -  `SPF`

    Returns a class with the attribute `$.text`

    Stringifies to the text

 -  `TXT`

    Returns a class with the attribute `$.text`

    Stringifies to the text

 -  `SOA`

    Returns a class with the attributes `@.mname`, `@.rname`, `$.serial`, `$.refresh`,
    `$.retry`, `$.expire`, `$.minimum`

    Stringifies to a format similar to nslookup

 -  `AXFR`

    Zone transfer request.

    This is a special case - it returns a list of the above objects instead of it's
    own response type.
