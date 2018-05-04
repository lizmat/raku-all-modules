use v6.c;
unit module P5getprotobyname:ver<0.0.1>:auth<cpan:ELIZABETH>;

use NativeCall;

my class ProtoStruct is repr<CStruct> {
    has Str         $.p_name;
    has CArray[Str] $.p_aliases;
    has uint32      $.p_proto;

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

    multi method result(ProtoStruct:U: :$scalar) {
        $scalar ?? Nil !! ()
    }
    multi method result(ProtoStruct:D: :$scalar, :$proto) {
        $scalar
          ?? $proto
            ?? $.p_proto
            !! $.p_name
          !! ($.p_name,HLLizeCArrayStr($.p_aliases).join(" "),$.p_proto)
    }
}

my sub getprotobyname(Str() $name, :$scalar) is export {
    sub _getprotobyname(Str --> ProtoStruct)
      is native is symbol<getprotobyname> {*}
    _getprotobyname($name).result(:$scalar, :proto($scalar))
}

my sub getprotobynumber(Int:D $proto, :$scalar) is export {
    sub _getprotobynumber(int32 --> ProtoStruct)
      is native is symbol<getprotobynumber> {*}
    my int32 $nproto = $proto;
    _getprotobynumber($nproto).result(:$scalar)
}

my sub getprotoent(:$scalar) is export {
    sub _getprotoent(--> ProtoStruct) is native is symbol<getprotoent> {*}
    _getprotoent.result(:$scalar)
}

my sub setprotoent($stayopen, :$scalar) is export {
    sub _setprotoent(int32) is native is symbol<setprotoent> {*}
    my int32 $nstayopen = ?$stayopen;
    _setprotoent($nstayopen);
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endprotoent(:$scalar) is export {
    sub _endprotoent() is native is symbol<endprotoent> {*}
    _endprotoent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getprotobyname - Implement Perl 5's getprotobyname() and associated built-ins

=head1 SYNOPSIS

    use P5getprotobyname;
    # exports getprotobyname, getprotobyport, getprotoent, setprotoent, endprotoent

    say getprotobynumber(0, :scalar);   # "ip"

    my @result_byname = getprotobyname("ip");

    my @result_bynumber = getprotobynumber(@result_byname[2]);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getprotobyname> and
associated functions of Perl 5 as closely as possible.  It exports by default:

    endprotoent getprotobyname getprotobynumber getprotoent setprotoent

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getprotobyname .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
