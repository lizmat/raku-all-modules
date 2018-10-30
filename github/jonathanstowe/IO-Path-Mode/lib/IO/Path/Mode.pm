use v6.c;

use nqp;

=begin pod

=head1 NAME

IO::Path::Mode - Augment Perl 6's IO::Path with a .mode() method to get the file mode

=head1 SYNOPSIS

=begin code

use IO::Path::Mode;

my $mode = "some-file".IO.mode;

say $mode.set-user-id ?? 'setuid' !! 'not setuid';

say $mode.user.execute ?? 'executable' !! 'not executable';

say $mode.file-type == IO::Path::Mode::File ?? 'plain file' !! 'something else';

...


=end code

Or part of "ls -al" :

=begin code

use IO::Path::Mode; 

for ".".IO.dir -> $f { 
    say $f.mode.Str, "   ", $f.Str; 
}

=end code

=head1 DESCRIPTION

This augments the type L<IO::Path> to provide a C<mode> method that allows
you to get at the file permissions (or mode.)  It follows the POSIX model pf
user, group and other permissions and consequently may not make a meaningful 
result on e.g. Windows (although the underlying calls appear to return something
approximating the correct answer.)

If you have a more recent rakudo that provides a C<mode> method, it will replace
that method with one that returns an C<IO::Path::Mode> object rather than an
C<IntStr>, this is a transitional arrangement and will be deprecated in a future
release in favour of a different method name.

It relies on some non-specified functionality in the VM so may probably only work
with Rakudo on MoarVM.

Loading this module will augment L<IO::Path> with a C<mode> method which returns
an L<IO::Path::Mode> object representing the mode of the C<file>. The methods
documented below are those of the L<IO::Path::Mode>.

This is mostly provided as some relief for not having the functionality directly
exposed in Rakudo and as a discussion board for the best way of implementing the
functionality going forward. 

=head1 METHODS

=head2 method mode

    method mode() returns IO::Path::Mode

This returns the numeric mode of the file as would be returned by C<stat>

=head2 method gist

    method gist() returns Str

This returns the mode of the file as an octal string (e.g 100755 )

=head2 method Int

    method Int()

Returns the mode as an C<Int>, for the convenience of programmers.
That is to say it can be coerced to an Int.

=head2 method Numeric

    method Numeric()

This returns the mode as an C<Int> it may be useful if a smart match
against a numeric value is required.

=head2 method Str

    method Str()

This returns the file mode as a string representing the file permissions
as described by POSIX C<ls>.

=head2 method file-type

    method file-type() returns FileType

This returns the file type part of the C<mode> as returned by C<stat>.
An C<enum> is provided for the documented types:

=item Socket

=item SymbolicLink

=item File

=item Block

=item Directory

=item Character

=item FIFO

Some systems may document other types than POSIX of course.

=head2 method set-user-id

    method set-user-id() returns Bool

returns a L<Bool> to indicate whether the C<setuid> bit is set for the
file, the exact meaning may differ if the C<file-type> is not C<File>.

=head2 method set-group-id

    method set-group-id() returns Bool

returns a L<Bool> to indicate whether the C<setguid> is set for the file.
The meaning may differ if the C<file-type> is not C<File>.

=head2 method sticky

    method sticky() returns Bool

This is a C<Bool> that indicates whether the "sticky bit" is
set on the file, traditionally this would indicate that the
text segment of an executable should be kept in memory but it
may be used for different purposes on different platforms and
file types.

=head2 method user

    method user() returns Permissions

This returns the set of permissions that the "owner" of the file
has, represented as an L<Int> with the role C<Permissions> that has
the following methods:

=head3 method execute

Returns a C<Bool> to indicate the execute permission

=head3 method write

Returns a C<Bool> to indicate the write permission

=head3 method read

Returns a C<Bool> to indicate the read permission

=head2 method group

    method group() returns Permissions

This provides the permissions of the "group" of the file in the
same manner as C<user>.

=head2 method other

    method other() returns Permissions 

This provides the permissions of all other users to the file in
the same manner as C<user>.

=end pod


class IO::Path::Mode:ver<0.0.6>:auth<github:jonathanstowe> {

    my constant S_IFMT  = 0o170000;

    # masks
    my constant S_ISUID = 0o004000; # set user id bit
    my constant S_ISGID = 0o002000; # set group id bit;
    my constant S_ISVTX = 0o001000; # sticky bit

    my constant S_IRWXU = 0o000700; # user perms
    my constant S_IRWXG = 0o000070; # group perms
    my constant S_IRWXO = 0o000007; # other perms


    enum FileType ( Socket          => 0o140000, 
                    SymbolicLink    => 0o120000, 
                    File            => 0o100000, 
                    Block           => 0o060000,
                    Directory       => 0o040000,
                    Character       => 0o020000,
                    FIFO            => 0o010000);

    enum Perms ( Execute => 0o00001, Write => 0o00002, Read => 0o00004);

    role Permissions {
        method execute() returns Bool {
            Bool(self.Int +& Execute.Int);
        }
        method write() returns Bool {
            Bool(self.Int +& Write.Int);
        }
        method read() returns Bool {
            Bool(self.Int +& Read.Int);
        }
        method bits() {
             self.read ?? 'r' !! '-' ,
             self.write ?? 'w' !! '-',
             self.execute ?? 'x' !! '-' ;
        }
    }

    has Int $.mode;
    multi method new(IO::Path:D :$path) {
        self.new(file => $path.Str);
    }
    multi method new(Str:D :$file) {
        my Int $mode = nqp::p6box_i(nqp::lstat(nqp::unbox_s($file), nqp::const::STAT_PLATFORM_MODE));
        self.new(:$mode);
    }

    method gist() {
        $!mode.base(8).Str;
    }

    method Int() {
        $!mode;
    }

    method Numeric() {
        self.Int;
    }

    method file-type() returns FileType {
        my $ft = $!mode +& S_IFMT;
        return FileType($ft);
    }

    method set-user-id() returns Bool {
        return Bool($!mode +& S_ISUID);
    }

    method set-group-id() returns Bool {
        return Bool($!mode +& S_ISGID);
    }

    method sticky() returns Bool {
        return Bool($!mode +& S_ISVTX);
    }

    method user() returns Permissions {
        my Int $perms = ($!mode +& S_IRWXU) +> 6;
        return $perms but Permissions;
    }
    method group() returns Permissions {
        my Int $perms = ($!mode +& S_IRWXG) +> 3;
        return $perms but Permissions;
    }
    method other() returns Permissions {
        my Int $perms = ($!mode +& S_IRWXO);
        return $perms but Permissions;
    }

    method type-char() {
        given self.file-type() {
            when Socket {
                's'
            }
            when SymbolicLink {
                'l'
            }
            when File {
                '-'
            }
            when Block {
                'b'
            }
            when Directory {
                'd'
            }
            when Character {
                'c'
            }
            when FIFO {
                'p'
            }
            default {
                ' '
            }
        }
    }

    method user-bits() {
        my @bits = self.user.bits;
        if self.set-user-id {
            @bits[2] = self.user.execute ?? 's' !! 'S'
        }
        @bits;
    }
    method group-bits() {
        my @bits = self.group.bits;
        if self.set-group-id {
            @bits[2] = self.group.execute ?? 's' !! 'S'
        }
        @bits;
    }
    method other-bits() {
        my @bits = self.other.bits;
        if self.sticky {
            @bits[2] = self.other.execute ?? 't' !! 'T'
        }
        @bits;
    }

    method bits() {
        my @bits = self.type-char;
        @bits.append: self.user-bits.flat;
        @bits.append: self.group-bits.flat;
        @bits.append: self.other-bits.flat;
        @bits.flat;
    }

    method Str() returns Str {
        self.bits.join('');
    }
}

# This can theoretically deal with a rakudo that has .mode or doesn't
# but not well tested against the latter case
sub EXPORT()
{
    my $old-method = IO::Path.^lookup('mode');

    if $old-method.defined {
        $old-method.wrap(method () {
            IO::Path::Mode.new(path => self);
        });
    }
    else {
        IO::Path.^add_method('mode', method () {
            IO::Path::Mode.new(path => self);
        });
    }

    %();
}

# vim: expandtab shiftwidth=4 ft=perl6
