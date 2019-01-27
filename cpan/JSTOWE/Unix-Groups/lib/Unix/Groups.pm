use v6;

=begin pod

=head1 NAME

Unix::Groups - access to details from C</etc/group>

=head1 SYNOPSIS

=begin code
use Unix::Groups;

my $groups = Unix::Groups.new;

say "The logged in user is member of these groups:";

for $groups.groups-for-user($*USER.Str) -> $group {
    say $group.name;
}
=end code

=head1 DESCRIPTION

This module provides access to the group details from C</etc/group>, with
similar to C<getgrent()>, C<getgrnam> and C<getgrgid> in the Unix standard
C library.

The methods either return a L<Unix::Groups::Group|#Unix::Groups::Group> object
or an array of those objects.

Because this module goes directly to the group file, if your system is
configured to retrieve its group information from e.g. C<NIS> or C<LDAP>
it may not necessarily reflect all the groups present, just the local ones.

=head1 METHODS

=head2 method groups

    method groups() returns Array[User::Groups::Group]

Returns the full list of groups, sorted in order of group id.

=head2 method group-by-name

    method group-by-name(Str $name) returns User::Groups::Group

Returns the group specified by C<$name> or the type object if none exists.

=head2 method group-by-id

    method group-by-id(Int $id) returns User::Groups::Group

Returns the group specified by the integer group id of the type object if
none exists.

=head2 method groups-for-user

    method groups-for-user(Str() $user) returns Array[User::Groups::Group]

This returns a list of the groups that the specified user is a member of
or an empty list if the user isn't in any groups.

=head1 Unix::Groups::Group

This is the class that represents the groups returned by the above methods.
It stringifies to the group name and numifies to the group id.

It has attributes that reflect the fields in C</etc/group>

=head2 gid

The L<Int> id of the group.

=head2 name

The name of the group.

=head2 password

The password for the group if set, most modern systems place this in a
shadow file so this may be empty or some other meaningless value.

=head2 users

This is a list of the names of the users that are members of the group.

=end pod

class Unix::Groups:ver<0.0.4>:auth<github:jonathanstowe>:api<1.0> {

    constant GROUPFILE = '/etc/group';

    class Group {
        has Int $.gid;
        has Str $.name;
        has Str $.password;
        has Str @.users;

        multi submethod BUILD(Str :$line!) {
            my ( $name, $pass, $id, $users ) = $line.split(':');
            $!gid = $id.Int;
            $!name = $name;
            $!password = $pass;
            @!users = $users.split(',');
        }

        method Str( --> Str ) {
            $!name;
        }

        method Numeric( --> Numeric ) {
            $!gid;
        }
    }

    has IO::Handle $!handle handles <lines>;

    has Group @.groups;
    has Group %!group-by-id;
    has Group %!group-by-name;

    submethod BUILD() {
        $!handle = GROUPFILE.IO.open();
    }

    method groups( --> Array[Group] ) {
        if !?@!groups.elems {
            for self.lines.map({Group.new(line => $_)}).sort({$^a.gid}) -> $g {
                @!groups.push($g);
                %!group-by-id{$g.gid} = $g;
                %!group-by-name{$g.name} = $g;
            }
        }
        @!groups;
    }

    method group-by-name(Str $name --> Group ) {
        %!group-by-name{$name};
    }

    method group-by-id(Int $id --> Group ) {
        %!group-by-id{$id};
    }

    method groups-for-user(Str() $user --> Array[Group] ) {
        my Group @groups;

        for self.groups -> $group {
            if ?$group.users.grep($user) {
                @groups.push($group);
            }
        }

        @groups;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
