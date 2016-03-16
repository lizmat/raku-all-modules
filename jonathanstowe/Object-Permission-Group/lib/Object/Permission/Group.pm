use v6.c;

=begin pod

=head1 NAME

Object::Permission::Group - Object helper for L<Object::Permission|https://github.com/jonathanstowe/Object-Permission> using unix groups.

=head1 SYNOPSIS

=begin code

    use Object::Permission::Group; # $*AUTH-USER is derived from $*USER

    # Or:

    Use Object::Permission::Group;

    # Set $*AUTH-USER to one for a specified user
    $*AUTH-USER = Object::Permission::Group.new(user => 'wibble');

=end code

=head1 DESCRIPTION

This provides a simple implementation
of L<Object::Permission::User> to be used with
L<Object::Permission|https://github.com/jonathanstowe/Object-Permission>
which derives the permissions for the C<$*AUTH-USER> from the users unix
group membership.

By default C<$*AUTH-USER> is initialised based on the value of C<$*USER>
(i.e. the effective user,) but it can be set manually with the permissions
of an arbitrary user (as in the second example above.)

The C<$*AUTH-USER> is set in the dynamic scope that the module is C<use>d
in.  However this can be over-ridden with the scoping as described in
L<Dynamic Variables|http://doc.perl6.org/language/variables#The_*_Twigil>.

=head1 METHODS

This doesn't really have any methods, just a constructor and the accessor
for C<permissions> defined in L<Object::Permission::User>.

=head2 method new

    method new(:$!user = $*USER.Str)

The constructor for the class.  By default the C<:$!user> argument is set
to the login of the effective user, but can be the name of any existing
user on the system.  If the user doesn't exist no permissions will be set.

The permissions are derived in the constructor from the names of the groups
that user is a member of, it is of course possible to append new permissions
at run time if that is required.

=end pod

use Object::Permission;

class Object::Permission::Group:ver<0.0.2>:auth<github:jonathanstowe> does Object::Permission::User {
    use Unix::Groups;

    has Unix::Groups $!groups;
    has Str $.user;

    submethod BUILD(Str() :$!user = $*USER.Str) {
        $!groups = Unix::Groups.new;

        for $!groups.groups-for-user($!user) -> $group {
            self.permissions.push($group.Str);
        }
    }

}

$*AUTH-USER = Object::Permission::Group.new;

# vim: expandtab shiftwidth=4 ft=perl6
