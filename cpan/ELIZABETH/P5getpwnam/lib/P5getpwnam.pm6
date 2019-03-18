use v6.c;

unit module P5getpwnam:ver<0.0.5>:auth<cpan:ELIZABETH>;

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

    multi method scalar(::?CLASS:U: --> Nil) { }
    multi method scalar(::?CLASS:D: :$uid) {
        $uid ?? $.pw_uid !! $.pw_name
    }
    multi method list(::?CLASS:U:) { () }
    multi method list(::?CLASS:D:) {
        ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
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

    multi method scalar(::?CLASS:U: --> Nil) { }
    multi method scalar(::?CLASS:D: :$uid) {
        $uid ?? $.pw_uid !! $.pw_name
    }
    multi method list(::?CLASS:U:) { () }
    multi method list(::?CLASS:D:) {
        ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
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

    multi method scalar(::?CLASS:U: --> Nil) { }
    multi method scalar(::?CLASS:D: :$uid) {
        $uid ?? $.pw_uid !! $.pw_name
    }
    multi method list(::?CLASS:U:) { () }
    multi method list(::?CLASS:D:) {
        ($.pw_name,$.pw_passwd,$.pw_uid,$.pw_gid,
          0,'','',$.pw_dir,$.pw_shell)
    }
}

my constant PwStruct =
  $*KERNEL.name eq 'darwin' ?? PwStructDarwin !!
  $*KERNEL.name eq 'linux'  ?? PwStructLinux  !! PwStructUnix;

# actual NativeCall interfaces
sub _getpwnam(Str --> PwStruct) is native is symbol<getpwnam> {*}
sub _getpwuid(uint32 $uid --> PwStruct) is native is symbol<getpwuid> {*}
sub _getpwent(--> PwStruct) is native is symbol<getpwent> {*}
sub _setpwent() is native is symbol<setpwent> {*}
sub _endpwent() is native is symbol<endpwent> {*}

# actual exported subs
my sub getlogin(--> Str) is native is export {*}

my proto sub getpwnam(|) is export {*}
multi sub getpwnam(Scalar:U, Str() $name) { _getpwnam($name).scalar(:uid) }
multi sub getpwnam(Str() $name, :$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    _getpwnam($name).scalar(:uid)
}
multi sub getpwnam(Str() $name) { _getpwnam($name).list }

my proto sub getpwuid(|) is export {*}
multi sub getpwuid(Scalar:U, Int() $uid) {
    my uint32 $nuid = $uid;
    _getpwuid($nuid).scalar
}
multi sub getpwuid(Int() $uid, :$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    my uint32 $nuid = $uid;
    _getpwuid($nuid).scalar
}
multi sub getpwuid(Int() $uid) {
    my uint32 $nuid = $uid;
    _getpwuid($nuid).list
}

my proto sub getpwent(|) is export {*}
multi sub getpwent(Scalar:U) { _getpwent.scalar }
multi sub getpwent(:$scalar!)
  is DEPRECATED('Scalar as first positional')
{
    _getpwent.scalar
}
multi sub getpwent() { _getpwent.list }

my sub setpwent() is export {
    _setpwent;
    1;  # this is apparently what Perl 5 does, although not documented
}

my sub endpwent() is export {
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

=head1 ORIGINAL PERL 5 DOCUMENTATION

    getpwnam NAME
    getpwuid UID
    getpwent
    setpwent
    endpwent
            These routines are the same as their counterparts in the system C
            library. In list context, the return values from the various get
            routines are as follows:

             # 0        1          2           3         4
             ( $name,   $passwd,   $uid,       $gid,     $quota,
             $comment,  $gcos,     $dir,       $shell,   $expire ) = getpw*
             # 5        6          7           8         9

            (If the entry doesn't exist you get an empty list.)

            The exact meaning of the $gcos field varies but it usually
            contains the real name of the user (as opposed to the login name)
            and other information pertaining to the user. Beware, however,
            that in many system users are able to change this information and
            therefore it cannot be trusted and therefore the $gcos is tainted
            (see perlsec). The $passwd and $shell, user's encrypted password
            and login shell, are also tainted, for the same reason.

            In scalar context, you get the name, unless the function was a
            lookup by name, in which case you get the other thing, whatever it
            is. (If the entry doesn't exist you get the undefined value.) For
            example:

                $uid   = getpwnam($name);
                $name  = getpwuid($num);

            In getpw*() the fields $quota, $comment, and $expire are special
            in that they are unsupported on many systems. If the $quota is
            unsupported, it is an empty scalar. If it is supported, it usually
            encodes the disk quota. If the $comment field is unsupported, it
            is an empty scalar. If it is supported it usually encodes some
            administrative comment about the user. In some systems the $quota
            field may be $change or $age, fields that have to do with password
            aging. In some systems the $comment field may be $class. The
            $expire field, if present, encodes the expiration period of the
            account or the password. For the availability and the exact
            meaning of these fields in your system, please consult getpwnam(3)
            and your system's pwd.h file. You can also find out from within
            Perl what your $quota and $comment fields mean and whether you
            have the $expire field by using the "Config" module and the values
            "d_pwquota", "d_pwage", "d_pwchange", "d_pwcomment", and
            "d_pwexpire". Shadow password files are supported only if your
            vendor has implemented them in the intuitive fashion that calling
            the regular C library routines gets the shadow versions if you're
            running under privilege or if there exists the shadow(3) functions
            as found in System V (this includes Solaris and Linux). Those
            systems that implement a proprietary shadow password facility are
            unlikely to be supported.

    getlogin
            This implements the C library function of the same name, which on
            most systems returns the current login from /etc/utmp, if any. If
            it returns the empty string, use "getpwuid".

                $login = getlogin || getpwuid($<) || "Kilroy";

            Do not consider "getlogin" for authentication: it is not as secure
            as "getpwuid".

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5getpwnam . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
