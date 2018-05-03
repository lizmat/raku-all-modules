use v6.c;
unit module P5getnetbyname:ver<0.0.1>:auth<cpan:ELIZABETH>;

use NativeCall;

my class NetStruct is repr<CStruct> {
    has Str            $.n_name;
    has CArray[Str]    $.n_aliases;
    has uint32         $.n_addrtype;
    has uint32         $.n_net;

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

    multi method result(NetStruct:U: :$scalar) {
        $scalar ?? Nil !! ()
    }
    multi method result(NetStruct:D: :$scalar) {
        $scalar
          ?? $.n_name
          !! ($.n_name,HLLizeCArrayStr($.n_aliases),$.n_addrtype,$.n_net)
    }
}

my sub getnetbyname(Str() $name, :$scalar) is export {
    sub _getnetbyname(Str --> NetStruct) is native is symbol<getnetbyname> {*}
    _getnetbyname($name).result(:$scalar)
}

my sub getnetbyaddr(Int:D $addrtype, Int:D $net, :$scalar) is export {
    sub _getnetbyaddr(int32, uint32 --> NetStruct)
      is native is symbol<getnetbyaddr> {*}
    my int32 $naddrtype = $addrtype;
    my uint32 $nnet = $net;
    _getnetbyaddr($naddrtype,$nnet).result(:$scalar)
}

my sub getnetent(:$scalar) is export {
    sub _getnetent(--> NetStruct) is native is symbol<getnetent> {*}
    _getnetent().result(:$scalar)
}

my sub setnetent($stayopen, :$scalar) is export {
    sub _setnetent(int32) is native is symbol<setnetent> {*}
    my int32 $nstayopen = ?$stayopen;
    _setnetent($nstayopen);
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endnetent(:$scalar) is export {
    sub _endnetent() is native is symbol<endnetent> {*}
    _endnetent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getnetbyname - Implement Perl 5's getnetbyname() and associated built-ins

=head1 SYNOPSIS

    use P5getnetbyname;
    # exports getnetbyname, getnetbyaddr, getnetent, setnetent, endnetent

    say getnetbyaddr(127, 2, :scalar);   # something akin to loopback

    my @result_byname = getnetbyname("loopback");

    my @result_byaddr = getnetbyaddr(|@result_byname[4,3]);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getnetbyname> and associated
functions of Perl 5 as closely as possible.  It exports by default:

    endnetent getnetbyname getnetbyaddr getnetent setnetent

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getnetbyname . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
