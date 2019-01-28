NAME
====

IP::Addr - dealing with IPv4/IPv6 addresses

SYNOPSIS
========

    my $cidr = IP::Addr.new( "192.0.2.2/27" );
    say $cidr;
    say $cidr.ip;
    for $cidr.network.each -> $ip {
        say $ip;
    }

    my $cidr6 = IP::Addr.new( "600d::f00d/123" );
    say $cidr6;
    say $cidr6.ip;

DESCRIPTION
===========

This module provides functionality for working with IPv4/IPv6 addresses.

Module Structure
----------------

The main interface is provided by `IP::Addr` class. Typical class usage is demonstrated in the synopsis. The class is a frontend which tries to determine version of the IP address provided to its constructor and creates corresponding handler object available on its `handler` attribute. All methods of the handler are available on `IP::Addr` object via `handles` trait.

For example, for an arbitrary `$ip` object of the class `$ip.ip` call is actually same as calling `$ip.handler.ip`. Method `ip` is a universal one for both v4 and v6 addresses and therefore it is not necessary to care about what exact kind of object we're currently dealing with.

Similarly, version-dependant methods are available too but only when corresponding handler is active. For example:

    say IP::Addr.new( "192.0.2.2/27" ).broadcast;

is a valid call; while

    say IP::Addr.new( "2001:db8::/123" ).broadcast;

will fail with "no method" exception because `broadcast` is not available for IPv6 addresses.

Glossary
--------

### Address forms

Besides of its version each IP address has one more characteristic property: form. It is defined by handler's attribute of the same name: `$!form`. Particular forms are defined by IP-FORM enum defined in `IP::Addr::Common`:

  * *ip*

    Simple IP address. It has prefix length of 32 bits.

  * *cidr*

    CIDR form is an IP address with *prefix* defined.

        192.0.2.3/24
        192.0.2.3/255.255.255.0
        2001::/64

  * *range*

    A range is defined by its first and last IP addresses. It has a *selected* or *current* IP address which could be changed as a result of increase, decrease, or iteration operations.

        192.0.2.3-192.0.2.20
        2001::1-2001::1f

### Ranged forms

CIDR and ranges are *ranged forms* contrary to a single IP form.

### N-tets

As it is known IP addresses are represented by groups of integers called *octets* for IPv4 and *hextets* for IPv6 (there are variantions but I chose these). *N-tets* is used as a general term for both of them.

METHODS
=======

Constructor
-----------

Class constructor `new` simply re-dispatches its arguments to method `set`.

`set`
-----

  * *`$ip.set( Str $source )` / `$ip.set( Str :$source! )`*

    `$source` is a string representation of an IP address in either plain or CIDR notation, or of a range of addresses in a form *<first ip>-<last ip> *. Formats of valid IP addresses are defined by corresponding standards.

  * *`$ip.set( [ :v4 | :v6 ], *%params )`*

    Creates a handler object of specified version of handler (v4 or v6) by passing named `%params` to its constructor.

    For example, the following statement:

        $ip.set( :v4, ip => 3221225986, prefix-len => 24 )

    Is equivalent to:

        $ip.set( "192.0.2.2/24" )

    **Note:** all calls to `set` method result in creation of a new handler object. I.e.:

        my $old-handler = $ip.handler;
        $ip.set( ... );
        say $old-handler === $ip.handler; # False

`Str`
-----

Returns a valid string representation of the IP object.

`gist`
------

Same as `Str` method.

`each`
------

Returns an iterable object which would iterate over IPs contained in the current object starting with selected address (i.e. the one returned by `ip` method). For ranged forms to iterate over the whole range (from the `first-ip` to the `last-ip`) use of method `first` is recommended:

    .say for IP::Addr.new( "192.0.2.3/29" ).each;           # 192.0.2.3/29\n192.0.2.4/29 ...
    .say for IP::Addr.new( "192.0.2.3/29" ).first.each;     # 192.0.2.0/29\n192.0.2.1/29 ...

`Supply`
--------

Similar to `each` method but returns a `Supply` object. Same rule about starting with selected IP and use of `first` method apply.

HANDLER METHODS
===============

This sections documents methods common for both IPv4 and IPv6 handlers.

Notes
-----

For all methods accepting another IP address as a parameter and where descriptions has a statement *"same version only"* `X::IPAddr::TypeCheck` exception would be thrown if object with a handler of different version is passed.

Address method parameters could either be `IP::Addr` instances or string representations.

`set`
-----

Configures the handler object.

**Note** In the following subsection `$handler` notation is used instead of `$ip.handler`.

  * *`$handler.set( Str:D $source )` / `$handler.set( Str:D :$source! )`*

    Handler attributes are set by parsing a string representation of IP address.

  * *`$handler.set( Int:D :$ip!, Int:D :$!prefix-len )`*

    Configures handler object as *CIDR* form.

  * *`$handler.set( Int:D :$first!, Int:D :$!last, Int :$ip? )`*

    Configures handler object as *range* form. Optional named parameter `:ip` defines selected IP within range (i.e. the one returned by `ip` method). If omitted then range initial selected IP is its first address.

  * *`$handler.set( Int:D $ip! )`*

    Configures a single IP form.

  * *`$handler.set( Int:D @n-tets )`*

    Configures a single IP form from integer octets for IPv4 or hextets for IPv6. Number of elements in @n-tets array is defined by the method of the same name.

`addr-len`
----------

Returns number of bits for correponding IP version (*32* for IPv4 and *128* for IPv6).

`n-tets`
--------

Returns number of n-tets for the current handler (*4* for IPv4 and *8* for IPv6).

`version`
---------

Returns integer version of the IP object (*4* or *6*).

`ip-classes`
------------

Returns list of hashes of reserved IP ranges. Each hash has two keys:

  * *net*

    `IP::Addr` object representing the reserved range.

  * *info*

    Another hash containing information about the scope of the reserved range in very brief text description:

      * *scope*

        Scopes are defined by `SCOPE` enum in `IP::Addr::Common`. Currently the following scopes are known:

          * `undetermined`

          * `mpublic`

          * `software`

          * `private`

          * `host`

          * `subnet`

          * `documentation`

          * `internet`

          * `routing`

          * `link`

        Of those `routing` and `link` are specific to IPv6. `public` isn't officially recognized but used to represent anything not been reserved. `undetermined` is also a special value to be returned if a requested range of IP addresses overlaps with a reserved range but isn't fully contained in it.

      * *description*

        Textual information about the reserved block.

`ip`
----

Returns a new `IP::Addr` object representing just an IP address of the current `IP::Addr` object.

    my $ip = IP::Addr.new( "192.0.2.3/24" );
    say $ip;            # 192.0.2.3/24
    say $ip.ip;         # 192.0.2.3
    say $ip.ip.WHO;     # IP::Addr

`prefix`
--------

Returns CIDR representation of any form of IP address. For example:

    say IP::Addr.new( "192.0.2.3" ).prefix;     # 192.0.2.3/32

For IPv4 handler additional named parameter `:mask` can be used to use network mask instead of prefix length:

    say IP::Addr.new( "192.0.2.3/24" ).prefix( :mask );     # 192.0.2.3/255.255.255.0

`first-ip`
----------

`IP::Addr` object for the first IP address in the range. For single IP will be the same as `ip` method.

`last-ip`
---------

`IP::Addr` object for the last IP address in the range. For single IP will be the same as `ip` method.

`network`
---------

`IP::Addr` object of the network current IP object belongs to. Makes real sense for CIDR form only though can be used with any other form too.

`mask`
------

Returns string representation of the current IP object mask. Doesn't make much sense for IPv6 addresses because there is officially no such thing for them.

`wildcard`
----------

Returns string representation of current IP object wildcard. Doesn't make much sense for IPv6 addresses because there is officially no such thing for them.

`size` 
-------

Returns number of IP addresses contained in the current `IP::Addr` object. For example:

    say IP::Addr.new( "192.0.0.0/13" ).size;            # 524288
    say IP::Addr.new( "192.0.2.3-192.0.2.23" );         # 21

`int-ip`
--------

Returns integer value of the IP address.

`int-first-ip`
--------------

Returns integer value of the first IP address in the current IP object.

`int-last-ip`
-------------

Returns integer value of the last IP address in the current IP object.

`int-mask`
----------

Returns integer value of current IP object mask. Though not defined as such for IPv6 addresses but could be useful in some address arithmetics.

`int-wildcard`
--------------

Returns integer value of current IP object wildcard. Though not defined as such for IPv6 addresses but could be useful in some address arithmetics.

`inc` / `succ`
--------------

Increments IP address by *1*. For ranged IP forms result of this operation won't be greater than the last IP of the range:

    my $ip = IP::Addr.new( "192.0.2.255/24" );
    say $ip.inc;                # 192.0.2.255/24

Rerturns current `IP::Addr` object.

`dec` / `pred`
--------------

Decrements IP address by *1*. For ranged IP forms result of this operation won't be less than the first IP of the range:

    my $ip = IP::Addr.new( "192.0.2.0/24" );
    say $ip.dec;                # 192.0.2.0/24

Returns current `IP::Addr` object.

`add( Int:D $count )`
---------------------

Shifts IP of the current object by `$count` positions higher. `$count` could be negative. For ranged IP form the result of the operation won't leave the range boundaries:

    my $ip = IP::Addr.new( "192.0.2.255/24" );
    say $ip.add( 10 );              # 192.0.2.255/24
    say $ip.add( -300 );            # 192.0.2.0/24

Returns current `IP::Addr` object.

`eq( $addr )`
-------------

Same version only.

Returns *True* if current object is equal to `$addr`.

`lt( $addr )`
-------------

Same version only.

Returns true if the current object is less than `$addr`.

`gt( $addr )`
-------------

Same version only.

Returns true if the current object is greater than `$addr`

`cmp( $addr )`
--------------

Same version only.

Returns one of three `Order` values: `Less`, `Same`, or `More`. For ranges comparison is performed by the selected IP.

`contains( $addr )`
-------------------

Same version only.

Returns *True* if current object contains `$addr`. Wether the `$addr` object is the same (e.g. `eq` method would return *True*) then it is also considered as contained.

`overlaps( $addr )`
-------------------

Same version only.

Returns *True* if the current object and `$addr` have at least one common IP address. Useful for starting iteration:

`first`
-------

Returns a new `IP::Addr` object whose IP address is the first IP of the current object. Useful for starting iteration.

    my $ip = IP::Addr.new( "192.0.2.12/24" );
    for $ip.first.each { say $_ }       # 192.0.2.0\n192.0.2.1\n...

See `each` method.

`next`
------

Returns a new `IP::Addr` object successive to the current object or *Nil* if current is the last IP of the range.

`prev`
------

Returns a new `IP::Addr` object preceding the current object or *Nil* if current is the first IP of the range.

`next-network`
--------------

Returns a new `IP::Addr` object containing network successive to the network of the current object. Valid for CIDR form only. Flips over begining/end of IP range:

    $ip = IP::Addr.new( "255.255.255.13/24" );
    say $ip.next-network;               # 0.0.0.0/24

`prev-network`
--------------

Returns a new `IP::Addr` object containing network preceding the network of the current object. Valid for CIDR form only. Flips over the begining of IP range:

    $ip = IP::Addr.new( "0.0.0.2/24" );
    say $ip.prev-network;               # 255.255.255.0/24

`next-range`
------------

Returns a new `IP::Addr` object containing range of the same length successive to the current object. Valid for range form only.

`prev-range`
------------

Returns a new `IP::Addr` object containing range of the same length preceding the current object. Valid for range form only.

`to-int( @n-tets )`
-------------------

Converts an array of n-tets to integer value corresponding to the current handler's IP version.

`to-n-tets( Int:D $addr )`
--------------------------

Splits integer represnation of IP address into n-tets corresponding to the current handler's IP version.

`info`
------

Returns a hash with information about the current IP object. The hash contains two keys: `scope` and `description`. See `ip-classes` method for more information.

`Str`
-----

Stringifies current IP object with regard to its form.

OPERATORS
=========

For all supported operators where both operands are addresses at least one of them has to be a `IP::Addr` object. The other one could be a string representation of an address.

`prefix/postfix ++` and `prefix/postfix --`
-------------------------------------------

Standard Perl6 operatios working by calling `succ`/`pred` methods on `IP::Addr` object.

`infix + ( $addr, $int )`
-------------------------

Adds an integer value to the address. The resulting address will never get out of network/range boundaries for objects of corresponding forms. A new `IP::Addr` object is returned.

    $ip2 = $ip1 + 3;

`infix - ( $addr, $int )`
-------------------------

Deducts an integer value from the address. The resulting address will never get out of network/range boundaries for objects of corresponding forms. A new `IP::Addr` object is returned.

    $ip2 = $ip1 - 3;

`infix cmp ( $addr1, $addr2 )`
------------------------------

Compares two IP addresses.

    given $ip1 cmp $ip2 {
        when Less { say "smaller" }
        when Same { say "same" }
        when More { say "bigger" }
    }

`infix eqv / infix == ( $addr1, $addr2 )`
-----------------------------------------

Checks if two addresses are equal. See handler's `eq` method.

`infix < ( $addr1, $addr2 )`
----------------------------

*True* if `$addr1` is less than `$addr2`. See handler's `lt` method.

`infix <= / infix ≤ ( $addr1, $addr2 )`
---------------------------------------

*True* if `$addr1` is less than or equal to `$addr2`.

`infix > ( $addr1, $addr2 )`
----------------------------

*True* if `$addr1` is greater than `$addr2`. See handler's `gt` method.

`infix >= / infix ≥ ( $addr1, $addr2 )`
---------------------------------------

*True* `$addr1` greater than or equal to `$addr2`.

`infix (cont) / infix ⊇ ( $addr1, $addr2 )`
-------------------------------------------

*True* if `$addr1` object contains `$addr2`. See handler's `contains` method.

`infix ⊆ ( $addr1, $addr2 )`
----------------------------

*True* if `$addr1` is contained by `$addr2`.

CAVEATS
=======

The author doesn't use IPv6 in his setups. All the functionality provided here is developed using information from corresponding Wikipedia pages. Therefore, "here be dragons"©. Please, report back any issue encountered!

AUTHOR
======

Vadim Belman <vrurg@cpan.org>

