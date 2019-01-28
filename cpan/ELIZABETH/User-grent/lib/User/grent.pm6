use v6.c;

our $gr_name    is export(:FIELDS);
our $gr_passwd  is export(:FIELDS);
our $gr_gid     is export(:FIELDS);
our @gr_members is export(:FIELDS);

class User::grent:ver<0.0.1>:auth<cpan:ELIZABETH> {
    has Str $.name;
    has Str $.passwd;
    has Int $.gid;
    has @.members;
}

sub populate(@fields) {
    if @fields {
        User::grent.new(
          name    => ($gr_name    = @fields[0]),
          passwd  => ($gr_passwd  = @fields[1]),
          gid     => ($gr_gid     = @fields[2]),
          members => (@gr_members = @fields[3].split(" ")),
        )
    }
    else {
          $gr_name    = Str;
          $gr_passwd  = Str;
          $gr_gid     = Int;
          @gr_members = ();
          Nil
    }
}

my sub getgrnam(Str() $name) is export(:DEFAULT:FIELDS) {
    use P5getgrnam; populate(getgrnam($name))
}

my sub getgrgid(Int() $gid) is export(:DEFAULT:FIELDS) {
    use P5getgrnam; populate(getgrgid($gid))
}

my sub getgrent() is export(:DEFAULT:FIELDS) {
    use P5getgrnam; populate(getgrent)
}

my proto sub getgr(|) is export(:DEFAULT:FIELDS) {*}
my multi sub getgr(Int:D $gid) is export(:DEFAULT:FIELDS) { getgrgid($gid) }
my multi sub getgr(Str:D $nam) is export(:DEFAULT:FIELDS) { getgrnam($nam) }

my constant &setgrent is export(:DEFAULT:FIELDS) = do {
    use P5getgrnam; &setgrent
}
my constant &endgrent is export(:DEFAULT:FIELDS) = do {
    use P5getgrnam; &endgrent
}

=begin pod

=head1 NAME

User::grent - Port of Perl 5's User::grent

=head1 SYNOPSIS

    use User::grent;
    $gr = getgrgid(0) or die "No group zero";
    if $gr.name eq 'wheel' && $gr.members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    use User::grent qw(:FIELDS);
    getgrgid(0) or die "No group zero";
    if $gr_name eq 'wheel' && @gr_members > 1 {
        print "gid zero name wheel, with other members";
    } 
     
    $gr = getgr($whoever);

=head1 DESCRIPTION

This module's default exports C<getgrent>, C<getgrgid>, and C<getgrnam>
functions, replacing them with versions that return C<User::grent> objects.
This object has methods that return the similarly named structure field name
from the C's passwd structure from grp.h; namely name, passwd, gid, and members
(not mem). The first three return scalars, the last an array.

You may also import all the structure fields directly into your namespace as
regular variables using the :FIELDS import tag. (Note that this still exports
the functions.) Access these fields as variables named with a preceding gr_.
Thus, C<$group_obj.gid> corresponds to C<$gr_gid> if you import the fields.

The C<getgr> function is a simple front-end that forwards a numeric argumenti
to C<getgrgid> and the rest to C<getgrnam>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/User-grent . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
