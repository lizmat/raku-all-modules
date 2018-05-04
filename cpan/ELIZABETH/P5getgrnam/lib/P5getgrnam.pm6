use v6.c;
unit module P5getgrnam:ver<0.0.4>:auth<cpan:ELIZABETH>;

use NativeCall;

my class GrStruct is repr<CStruct> {
    has Str         $.gr_name;
    has Str         $.gr_passwd;
    has uint32      $.gr_gid;
    has CArray[Str] $.gr_mem;

    multi method result(GrStruct:U: :$scalar) {
        $scalar ?? Nil !! ()
    }
    multi method result(GrStruct:D: :$scalar, :$gid) {
        if $scalar {
            $gid ?? $.gr_gid !! $.gr_name
        }
        else {
            my @members;
            with $.gr_mem -> $members {
                for 0..* {
                    with $members[$_] -> $member {
                        @members.push($member)
                    }
                    else {
                        last
                    }
                }
            }
            ($.gr_name,$.gr_passwd,$.gr_gid,@members.join(" "))
        }
    }
}

my sub getgrnam(Str() $name, :$scalar) is export {
    sub _getgrnam(Str --> GrStruct) is native is symbol<getgrnam> {*}
    _getgrnam($name).result(:$scalar, :gid($scalar))
}

my sub getgrgid(Int() $gid, :$scalar) is export {
    sub _getgrgid(uint32 $gid --> GrStruct) is native is symbol<getgrgid> {*}
    my uint32 $ngid = $gid;
    _getgrgid($ngid).result(:$scalar)
}

my sub getgrent(:$scalar) is export {
    sub _getgrent(--> GrStruct) is native is symbol<getgrent> {*}
    _getgrent.result(:$scalar)
}

my sub setgrent(:$scalar) is export {
    sub _setgrent() is native is symbol<setgrent> {*}
    _setgrent;
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endgrent(:$scalar) is export {
    sub _endgrent() is native is symbol<endgrent> {*}
    _endgrent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getgrnam - Implement Perl 5's getgrnam() and associated built-ins

=head1 SYNOPSIS

    use P5getgrnam;

    my @result = getgrnam(~$*USER);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getgrnam> and associated
functions of Perl 5 as closely as possible.  It exports:

    endgrent getgrent getgrgid getgrnam setgrent

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getgrnam . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
