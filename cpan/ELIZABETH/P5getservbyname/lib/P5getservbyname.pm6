use v6.c;

unit module P5getservbyname:ver<0.0.4>:auth<cpan:ELIZABETH>;

use NativeCall;

sub be2le16(uint32 $value) { ($value +> 8) +| (($value +& 0xff) +< 8) }

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

    multi method scalar(ServStruct:U: --> Nil) { }
    multi method scalar(ServStruct:D: :$port) {
        $port ?? be2le16($.s_port) !! $.s_name
    }

    multi method list(ServStruct:U:) { () }
    multi method list(ServStruct:D:) {
        ($.s_name,HLLizeCArrayStr($.s_aliases).join(" "),
          be2le16($.s_port),$.s_proto)
    }
}

# actual NativeCall interfaces
sub _getservbyname(Str, Str --> ServStruct)
  is native is symbol<getservbyname> {*}
sub _getservbyport(int32, Str --> ServStruct)
  is native is symbol<getservbyport> {*}
sub _getservent(--> ServStruct) is native is symbol<getservent> {*}
sub _setservent(int32) is native is symbol<setservent> {*}
sub _endservent() is native is symbol<endservent> {*}

# actual exported subs
my proto sub getservbyname(|) is export {*}
multi sub getservbyname(Scalar:U, Str() $name, Str() $proto) {
    _getservbyname($name,$proto).scalar(:port)
}
multi sub getservbyname(Str() $name, Str() $proto, :$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    _getservbyname($name,$proto).scalar(:port)
}
multi sub getservbyname(Str() $name, Str() $proto) {
    _getservbyname($name,$proto).list
}

my proto sub getservbyport(|) is export {*}
multi sub getservbyport(Scalar:U, Int:D $port, Str() $proto) {
    my int32 $nport = be2le16($port);
    _getservbyport($nport,$proto).scalar
}
multi sub getservbyport(Int:D $port, Str() $proto, :$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    my int32 $nport = be2le16($port);
    _getservbyport($nport,$proto).scalar
}
multi sub getservbyport(Int:D $port, Str() $proto) {
    my int32 $nport = be2le16($port);
    _getservbyport($nport,$proto).list
}

my proto sub getservent(|) is export {*}
multi sub getservent(Scalar:U) { _getservent.scalar }
multi sub getservent(:$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    _getservent.scalar
}
multi sub getservent() { _getservent.list }

my sub setservent($stayopen) is export {
    my int32 $nstayopen = ?$stayopen;
    _setservent($nstayopen);
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endservent() is export {
    _endservent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getservbyname - Implement Perl 5's getservbyname() and associated built-ins

=head1 SYNOPSIS

    use P5getservbyname;
    # exports getservbyname, getservbyport, getservent, setservent, endservent

    say getservbyport(Scalar, 25, "tcp");   # "smtp"

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

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
