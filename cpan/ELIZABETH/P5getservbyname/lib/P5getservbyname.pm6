use v6.c;

unit module P5getservbyname:ver<0.0.3>:auth<cpan:ELIZABETH>;

use NativeCall;

my class ServStruct is repr<CStruct> {
    has Str         $.s_name;
    has CArray[Str] $.s_aliases;
    has uint32      $.s_port;
    has Str         $.s_proto;

    sub HLLizeCArrayStr(\list) {
        my @members;
        with list -> $members {
            for ^Inf {
                with $members[$_] -> $member {
                    @members.push($member)
                }
                else {
                    last
                }
            }
        }
        @members
    }

    sub be2le16(uint32 $value) {  # feels hacky, but appears to do the trick
        ($value +> 8) +| (($value +& 0xff) +< 8)
    }

    multi method result(ServStruct:U: :$scalar) {
        $scalar ?? Nil !! ()
    }
    multi method result(ServStruct:D: :$scalar, :$port) {
        $scalar
          ?? $port
            ?? be2le16($.s_port)
            !! $.s_name
          !! ($.s_name,HLLizeCArrayStr($.s_aliases).join(" "),
              be2le16($.s_port),$.s_proto)
    }
}

my sub getservbyname(Str() $name, Str() $proto, :$scalar) is export {
    sub _getservbyname(Str, Str --> ServStruct)
      is native is symbol<getservbyname> {*}
    _getservbyname($name,$proto).result(:$scalar, :port($scalar))
}

my sub getservbyport(Int:D $port, Str() $proto, :$scalar) is export {
    sub _getservbyport(int32, Str --> ServStruct)
      is native is symbol<getservbyport> {*}
    my int32 $nport = ($port +> 8) +| (($port +& 0xff) +< 8);
    _getservbyport($nport,$proto).result(:$scalar)
}

my sub getservent(:$scalar) is export {
    sub _getservent(--> ServStruct) is native is symbol<getservent> {*}
    _getservent.result(:$scalar)
}

my sub setservent($stayopen, :$scalar) is export {
    sub _setservent(int32) is native is symbol<setservent> {*}
    my int32 $nstayopen = ?$stayopen;
    _setservent($nstayopen);
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endservent(:$scalar) is export {
    sub _endservent() is native is symbol<endservent> {*}
    _endservent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getservbyname - Implement Perl 5's getservbyname() and associated built-ins

=head1 SYNOPSIS

    use P5getservbyname;
    # exports getservbyname, getservbyport, getservent, setservent, endservent

    say getservbyport(25, "tcp", :scalar);   # "smtp"

    my @result_byname = getservbyname("smtp");

    my @result_byport = getservbyport(|@result_byname[3,4]);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getservbyname> and associated
functions of Perl 5 as closely as possible.  It exports by default:

    endservent getservbyname getservbyport getservent setservent

=head1 ORIGINAL PERL 5 DOCUMENTATION

    getservbyname NAME,PROTO
    getservbyport PORT,PROTO
    getservent
    setservent STAYOPEN
    endservent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $aliases,  $port,      $proto    ) = getserv*

            (If the entry doesn't exist you get an empty list.)

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.)

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getservbyname . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
