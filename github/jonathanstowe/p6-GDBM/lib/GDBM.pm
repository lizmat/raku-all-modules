use v6.c;

=begin pod

=head1 NAME

GDBM - Gnu DBM binding

=head1 SYMOPSIS

=begin code

use GDBM;

my $data = GDBM.new('somefile.db');

$data<foo> = 'bar';

say $data<foo>:exists;

$data.close;

# Then in some time later, possibly in another program

$data = GDBM.new('somefile.db');

say $data<foo>;

$data.close;

=end code

=head1 DESCRIPTION

The L<GNU DBM|http://www.gnu.org.ua/software/gdbm/> stores key/value
pairs in a hashed database file. Its implementation allows for keys
and values of arbitrary length (compared to fairly frugal limits on
some earlier implementations.)

This module allows for the data to be transparently managed as if it
were in an normal Associative container such as a Hash.  The only limitation
currently is that both key and value must be strings (or can be meaningfully
stringified,) so e.g. structured data will need to be serialised to some
format that can be represented as a string.  However it can be used for
persistence or caching if this doesn't need to be shared by processes
on different machines.

=head1 METHODS

As well as the listed methods a L<GDBM> object should support most of
the methods that make sense for an L<Associative>.

=head2 method new

    multi method new(Str $filename)
    multi method new(Str :$filename!, Int :$block-size = 512, Int() :$flags = Create +| Sync +| NoMMap, Int :$mode = 0o644)
    multi method new(GDBM::File :$file)

The first form of the constructor simply takes a database filename and
opens it with the default options as per the second form.  The C<flags>
parameter is some combination of values of the C<enum>s L<GDBM::OpenMode>
and L<GDBM::OpenOptions>, the default being to create the file if it
doesn't exist, automatically sync the data and not use memory mapping of
the data.  C<mode> is the permissions (as an octal value,) that the file
will be created with after the application of the users file creation mask
(umask.) The arguments to this form are identical to those of the
underlying L<GDBM::File>.  The third variant allows you to provide a
pre-constructed and open L<GDBM::File> if the design of your program
might require it.

=head2 method store

    multi method store(Str:D $key, Str:D $value, StoreOptions $flag = Replace --> Bool)
    multi method store(Pair $p, StoreOptions $flag = Replace --> Bool)
    multi method store(*%items --> Bool)

This stores the supplied C<$value> under C<$key>, the default option
is to replace the existing value for a given key, if C<GDBM::Insert>
is supplied for C<$flag> then the value will only be stored if the key
does not already exist in the database, if the key is already present
then an exception will be thrown.  If the file is opened as a Reader
only then an exception will be thrown.  If the storage is successful
then True will be returned. The third variamt is provided for completeness
allowing the pairs to be expressed like named arguments,


=head2 method fetch

    method fetch(Str $key) returns Str

This returns the value associated with the supplied key, or a Str type
object if it is not present in the database.

=head2 method exists

    multi method exists(Str $key) returns Bool

This returns True if the key supplied exists in the database.

=head2 method delete

    method delete(Str $k) returns Bool

This deletes the key (and associated value) from the database. Returning True
if it exists and was successful.  If the key isn't present or if the
database isn't opened for writing it will return false.

=head2 method first-key

    method first-key() returns Str

This returns the first key in the database or an undefined Str type object
if there are no entries in the database,  This is the interface provided
by the C<gdbm> library, but you probably want to use C<keys> as provided
by the Associative interface unless you have special needs.  The keys
aren't returned in a particular order as it is defined by the hashing
algorithm,

=head2 method next-key

    method next-key(Str $prev) returns Str

Returns the next available key from the database or a Str type object
if there are no more entries.  The argument is a defined key that
was previously returned by C<first-key> or C<next-key>.


=head2 method reorganize

    method reorganize() returns Bool

Normally gdbm will reuse the space taken up by deleted items.  This can
be used sparingly to reduce the size of the gdbm file by returning the
space used by deleted items.

=head2 method sync

    method sync()

If you didn't provide L<Sync> in the flags to the constructor then, e.g.
store and delete operations may not be completely written to disk before
they return. Calling this will ensure all pending changes are flushed
to disk.  It does not return until the disk file is completely written.

=end pod

use NativeCall;

class GDBM does Associative {

    my constant HELPER = %?RESOURCES<libraries/gdbmhelper>.Str;

    enum OpenMode ( Reader => 0, Writer => 1, Create => 2, New => 3);
    my constant OpenMask = 7;
    enum OpenOptions ( Fast => 0x010, Sync => 0x020, NoLock => 0x040, NoMMap => 0x080, CloExec => 0x100);

    enum StoreOptions ( Insert => 0, Replace => 1 );

    class X::GDBM is Exception {
        has Str $.message;
    }

    class X::GDBM::Open is X::GDBM {
    }

    sub fail(Str $message ) {
        explicitly-manage($message);
        X::GDBM::Open.new(:$message).throw;
    }

    my class File is repr('CPointer') {
        sub p_gdbm_open(Str $file, uint32 $bs, uint32 $flags, uint32 $mode, &fatal ( Str $message )) returns File is native(HELPER) { * }

        multi method new(Str() :$file!, Int :$block-size = 512, Int() :$flags = Create +| Sync +| NoMMap, Int :$mode = 0o644) returns File {
            explicitly-manage($file);
            p_gdbm_open($file, $block-size, $flags, $mode, &fail);

        }

        sub p_gdbm_close(File:D $f) is native(HELPER) { * };

        method close() {
            p_gdbm_close(self);
        }

        sub p_gdbm_store(File:D $f, Str $k, Str $v, uint32 $m) returns int32 is native(HELPER) { * }

        sub p_gdbm_last_errno_strerror(File:D $f) returns Str is native(HELPER) { * }

        class X::GDBM::Store is X::GDBM {
        }

        proto method store(|c) { * }

        multi method store(Str:D $k, Str:D $v, StoreOptions $flag = Replace --> Bool) {
            my Bool $rc = True;
            my $ret = p_gdbm_store(self, $k, $v, $flag.Int);
            if $ret == -1 {
                with p_gdbm_last_errno_strerror(self) -> $message {
                    X::GDBM::Store.new(:$message).throw;
                }
                else {
                    # What is the correct error message here?
                    X::GDBM::Store.new(message => "GDBM was not opened as a writer").throw;
                }
            }
            elsif $ret == 1 {
                X::GDBM::Store.new(message => "Key exists and 'Replace' wasn't specified").throw;
            }
            $rc;
        }

        multi method store(Pair:D $pair ( Str :$key, Str :$value ), StoreOptions $flag = Replace --> Bool) {
            self.store($key, $value);
        }

        multi method store(*%items --> Bool) {
            for %items.pairs -> $p {
                self.store($p)
            }
            True;
        }

        sub p_gdbm_fetch(File:D $f, Str $k) returns Str is native(HELPER) { * }

        method fetch(Str $k --> Str) {
            p_gdbm_fetch(self, $k);
        }

        sub p_gdbm_delete(File:D $f, Str $k) returns int32 is native(HELPER) { * }

        method delete(Str $k --> Bool) {
            !p_gdbm_delete(self, $k);
        }

        # For the methods of these we'll just return the Datum as
        # we'll only be passing to next anyway

        sub p_gdbm_firstkey(File:D $f) returns Str is native(HELPER) { * }

        multi method first-key(--> Str) {
            p_gdbm_firstkey(self);
        }


        sub p_gdbm_nextkey(File:D $f, Str $prev) returns Str is native(HELPER) { * }

        multi method next-key(Str $prev --> Str) {
            p_gdbm_nextkey(self, $prev);
        }

        sub p_gdbm_reorganize (File:D $f) returns int32 is native(HELPER) { * }

        method reorganize(--> Bool) {
            my $rc = p_gdbm_reorganize(self);
            Bool($rc);
        }

        sub p_gdbm_sync(File:D $f) is native(HELPER) { * }

        method sync() {
            p_gdbm_sync(self);
        }

        sub p_gdbm_exists(File:D $f, Str $k) returns int32 is native(HELPER) { * }
        multi method exists(Str $k --> Bool) {
            my Int $rc = p_gdbm_exists(self, $k);
            return Bool($rc);
        }
    }

    has File $!file handles <fetch store exists delete sync close reorganize>;

    has Str $.filename is required;

    multi method new(Str() $filename) {
        self.new(:$filename);
    }

    multi method BUILD(:$!filename!, |c) {
        $!file = File.new(file => $!filename, |c);
    }

    multi submethod BUILD(File :$!file! ) {
    }

    multi method EXISTS-KEY (::?CLASS:D: $key) {
        self.exists($key);
    }

    multi method DELETE-KEY (::?CLASS:D: $key) {
        self.delete($key);
    }

    multi method ASSIGN-KEY (::?CLASS:D: Str $key, Str $new) {
        self.store($key, $new, Replace);
    }

    multi method AT-KEY (::?CLASS:D $self: $key) {
        Proxy.new(
            FETCH   =>  method () {
                $self.fetch($key);
            },
            STORE   => method ($val) {
                self.store($key, $val, Replace);
            }
        );
    }

    method keys(::?CLASS:D: --> Seq) {
        gather {
            my $key = $!file.first-key;
            while $key.defined {
                take $key;
                $key = $!file.next-key($key);
            }
        }
    }

    method kv(::?CLASS:D: --> Seq) {
        gather {
            for self.keys -> $key {
                take $key;
                take self.fetch($key) ;
            }
        }
    }

    method pairs(::?CLASS:D: --> Seq) {
        gather {
            for self.kv -> $k, $v {
                take $k => $v;
            }
        }
    }

    # Copied straight from Hash
    method perl(::?CLASS:D: --> Str ) {
        '{' ~ self.pairs.sort.map({.perl}).join(', ') ~ '}'
    }
}

# vim: ft=perl6 expandtab sw=4
