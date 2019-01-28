use v6.c;

our $pw_name    is export(:FIELDS);
our $pw_passwd  is export(:FIELDS);
our $pw_uid     is export(:FIELDS);
our $pw_gid     is export(:FIELDS);
our $pw_change  is export(:FIELDS);
our $pw_comment is export(:FIELDS);
our $pw_gecos   is export(:FIELDS);
our $pw_dir     is export(:FIELDS);
our $pw_shell   is export(:FIELDS);
our $pw_expire  is export(:FIELDS);

# add aliases for variables
our $pw_age   is export(:FIELDS) := $pw_change;
our $pw_quota is export(:FIELDS) := $pw_change;
our $pw_class is export(:FIELDS) := $pw_comment;

class User::pwent:ver<0.0.1>:auth<cpan:ELIZABETH> {
    has Str $.name;
    has Str $.passwd;
    has Int $.uid;
    has Int $.gid;
    has     $.change;
    has Str $.comment;
    has Str $.gecos;
    has Str $.dir;
    has Str $.shell;
    has     $.expire;
}

BEGIN {  # add aliases for methods
    User::pwent.^add_method('age',   User::pwent.^find_method('change'));
    User::pwent.^add_method('quota', User::pwent.^find_method('change'));
    User::pwent.^add_method('class', User::pwent.^find_method('comment'));
}

sub populate(@fields) {
    if @fields {
        User::pwent.new(
          name    => ($pw_name    = @fields[0]),
          passwd  => ($pw_passwd  = @fields[1]),
          uid     => ($pw_uid     = @fields[2]),
          gid     => ($pw_gid     = @fields[3]),
          change  => ($pw_change  = @fields[4]),
          comment => ($pw_comment = @fields[5]),
          gecos   => ($pw_gecos   = @fields[6]),
          dir     => ($pw_dir     = @fields[7]),
          shell   => ($pw_shell   = @fields[8]),
          expire  => ($pw_expire  = @fields[9]),
        )
    }
    else {
          $pw_name    = Str;
          $pw_passwd  = Str;
          $pw_uid     = Int;
          $pw_gid     = Int;
          $pw_change  = Any;
          $pw_comment = Str;
          $pw_gecos   = Str;
          $pw_dir     = Str;
          $pw_shell   = Str;
          $pw_expire  = Any;
          Nil
    }
}

my sub getpwnam(Str() $name) is export(:DEFAULT:FIELDS) {
    use P5getpwnam; populate(getpwnam($name))
}

my sub getpwuid(Int() $uid) is export(:DEFAULT:FIELDS) {
    use P5getpwnam; populate(getpwuid($uid))
}

my sub getpwent() is export(:DEFAULT:FIELDS) {
    use P5getpwnam; populate(getpwent)
}

my proto sub getpw(|) is export(:DEFAULT:FIELDS) {*}
my multi sub getpw(Int:D $uid) is export(:DEFAULT:FIELDS) { getpwuid($uid) }
my multi sub getpw(Str:D $nam) is export(:DEFAULT:FIELDS) { getpwnam($nam) }

my constant &setpwent is export(:DEFAULT:FIELDS) = do {
    use P5getpwnam; &setpwent
}
my constant &endpwent is export(:DEFAULT:FIELDS) = do {
    use P5getpwnam; &endpwent
}

=begin pod

=head1 NAME

User::pwent - Port of Perl 5's User::pwent

=head1 SYNOPSIS

    use User::pwent;
    $pw = getpwnam('daemon')       || die "No daemon user";
    if $pw.uid == 1 && $pw.dir ~~ m/ ^ '/' [bin|tmp]? $ / {
        print "gid 1 on root dir";
    }
     
    $real_shell = $pw.shell || '/bin/sh';
     
    use User::pwent qw(:FIELDS);
    getpwnam('daemon')             || die "No daemon user";
    if $pw_uid == 1 && $pw_dir ~~ m/ ^ '/' [bin|tmp]? $ / {
        print "gid 1 on root dir";
    }
     
    $pw = getpw($whoever);

=head1 DESCRIPTION

This module's exports C<getpwent>, C<getpwuid>, and C<getpwnam> functions
that return C<User::pwent> objects. This object has methods that return the
similarly named structure field name from the C's passwd structure from pwd.h,
stripped of their leading "pw_" parts, namely name, passwd, uid, gid, change,
age, quota, comment, class, gecos, dir, shell, and expire.

You may also import all the structure fields directly into your namespace as
regular variables using the :FIELDS import tag.  Access these fields as
variables named with a preceding pw_ in front their method names. Thus,
$passwd_obj.shell corresponds to $pw_shell if you import the fields.

The C<getpw> function is a simple front-end that forwards a numeric argument
to C<getpwuid> and the rest to C<getpwnam>.

=head1 PORTING CAVEATS

The C<pw_has> function has not been ported because there's currently no way
to find the needed information in the Perl 6 equivalent of C<Config>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/User-pwent . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
