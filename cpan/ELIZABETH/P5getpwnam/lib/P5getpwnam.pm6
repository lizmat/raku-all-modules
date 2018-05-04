use v6.c;
unit module P5getpwnam:ver<0.0.3>:auth<cpan:ELIZABETH>;

use NativeCall;

my class PwStructDarwin is repr<CStruct> {  # MacOS appears to have its own
    has Str    $.pw_name;
    has Str    $.pw_passwd;
    has uint32 $.pw_uid;
    has uint32 $.pw_gid;
    has long   $.pw_change;
    has Str    $.pw_class;
    has Str    $.pw_gecos;
    has Str    $.pw_dir;
    has Str    $.pw_shell;
    has long   $.pw_expire;
    has int32  $.pw_fields;

    multi method result(::?CLASS:U: :$scalar) {         # call failed
        $scalar ?? Nil !! ()
    }
    multi method result(::?CLASS:D: :$scalar, :$uid) {  # call successful
        $scalar
          ?? $uid
            ?? $.pw_uid
            !! $.pw_name
          !! ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
              0,'',$.pw_gecos,$.pw_dir,$.pw_shell,$.pw_expire)
    }
}

my class PwStructLinux is repr<CStruct> {   # as has Linux
    has Str    $.pw_name;
    has Str    $.pw_passwd;
    has uint32 $.pw_uid;
    has uint32 $.pw_gid;
    has Str    $.pw_gecos;
    has Str    $.pw_dir;
    has Str    $.pw_shell;

    multi method result(::?CLASS:U: :$scalar) {         # call failed
        $scalar ?? Nil !! ()
    }
    multi method result(::?CLASS:D: :$scalar, :$uid) {  # call successful
        $scalar
          ?? $uid
            ?? $.pw_uid
            !! $.pw_name
          !! ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
              0,'',$.pw_gecos,$.pw_dir,$.pw_shell)
    }
}

my class PwStructUnix is repr<CStruct> {
    has Str    $.pw_name;
    has Str    $.pw_passwd;
    has uint32 $.pw_uid;
    has uint32 $.pw_gid;
    has Str    $.pw_dir;
    has Str    $.pw_shell;

    multi method result(::?CLASS:U: :$scalar) {         # call failed
        $scalar ?? Nil !! ()
    }
    multi method result(::?CLASS:D: :$scalar, :$uid) {  # call successful
        $scalar
          ?? $uid
            ?? $.pw_uid
            !! $.pw_name
          !! ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
              0,'','',$.pw_dir,$.pw_shell)
    }
}

my constant PwStruct =
  $*KERNEL.name eq 'darwin' ?? PwStructDarwin !!
  $*KERNEL.name eq 'linux'  ?? PwStructLinux  !! PwStructUnix;

my sub getlogin(--> Str) is native is export {*}

my sub getpwnam(Str() $name, :$scalar) is export {
    sub _getpwnam(Str --> PwStruct) is native is symbol<getpwnam> {*}
    _getpwnam($name).result(:$scalar, :uid($scalar))
}

my sub getpwuid(Int() $uid, :$scalar) is export {
    sub _getpwuid(uint32 $uid --> PwStruct) is native is symbol<getpwuid> {*}
    my uint32 $nuid = $uid;
    _getpwuid($nuid).result(:$scalar)
}

my sub getpwent(:$scalar) is export {
    sub _getpwent(--> PwStruct) is native is symbol<getpwent> {*}
    _getpwent.result(:$scalar)
}

my sub setpwent(:$scalar) is export {
    sub _setpwent() is native is symbol<setpwent> {*}
    _setpwent;
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endpwent(:$scalar) is export {
    sub _endpwent() is native is symbol<endpwent> {*}
    _endpwent;
    1;  # this is apparently what Perl 5 does, although not documented
}

=begin pod

=head1 NAME

P5getpwnam - Implement Perl 5's getpwnam() and associated built-ins

=head1 SYNOPSIS

    use P5getpwnam;

    say "logged in as {getlogin || '(unknown)'}";

    my @result = getpwnam(~$*USER);

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<getpwnam> and associated
functions of Perl 5 as closely as possible.  It exports:

    endpwent getlogin getpwent getpwnam getpwuid setpwent

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpwnam . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
