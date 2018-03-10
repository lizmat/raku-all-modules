use NativeCall;
use Munge::Context;

# Re-export symbols from Munge::Context
my package EXPORT::DEFAULT {}
BEGIN for <
    MUNGE_CIPHER_NONE
    MUNGE_CIPHER_DEFAULT
    MUNGE_CIPHER_BLOWFISH
    MUNGE_CIPHER_CAST5
    MUNGE_CIPHER_AES128
    MUNGE_CIPHER_AES256

    MUNGE_MAC_DEFAULT
    MUNGE_MAC_MD5
    MUNGE_MAC_SHA1
    MUNGE_MAC_RIPEMD160
    MUNGE_MAC_SHA256
    MUNGE_MAC_SHA512

    MUNGE_ZIP_NONE
    MUNGE_ZIP_DEFAULT
    MUNGE_ZIP_BZLIB
    MUNGE_ZIP_ZLIB

    MUNGE_TTL_DEFAULT
    MUNGE_TTL_MAXIMUM

    MUNGE_UID_ANY
    MUNGE_GID_ANY

    EMUNGE_SUCCESS
    EMUNGE_SNAFU
    EMUNGE_BAD_ARG
    EMUNGE_BAD_LENGTH
    EMUNGE_OVERFLOW
    EMUNGE_NO_MEMORY
    EMUNGE_SOCKET
    EMUNGE_TIMEOUT
    EMUNGE_BAD_CRED
    EMUNGE_BAD_VERSION
    EMUNGE_BAD_CIPHER
    EMUNGE_BAD_MAC
    EMUNGE_BAD_ZIP
    EMUNGE_BAD_REALM
    EMUNGE_CRED_INVALID
    EMUNGE_CRED_EXPIRED
    EMUNGE_CRED_REWOUND
    EMUNGE_CRED_REPLAYED
    EMUNGE_CRED_UNAUTHORIZED
> { EXPORT::DEFAULT::{$_} = ::($_) }

class Munge
{
    has Munge::Context $.context handles<error cipher MAC zip ttl addr4 socket
                                         encode-time decode-time
                                         uid-restriction gid-restriction>;
    has int32 $.uid;
    has int32 $.gid;

    sub munge_encode(Pointer is rw, Munge::Context, Blob, int32 --> int32)
        is native(LIBMUNGE) {}

    sub munge_decode(Str, Munge::Context, Pointer is rw, int32 is rw,
                     int32 is rw, int32 is rw --> int32) is native(LIBMUNGE) {}

    sub free(Pointer) is native {}

    submethod TWEAK(:$cipher, :$MAC, :$zip, :$ttl, :$socket,
                    :$uid-restriction, :$gid-restriction)
    {
        $!context .= new;
        $!context.ttl($_) with $ttl;
        $!context.socket($_) with $socket;
        $!context.uid-restriction($_) with $uid-restriction;
        $!context.gid-restriction($_) with $gid-restriction;

        $!context.cipher($_) with $cipher;
        $!context.MAC($_) with $MAC;
        $!context.zip($_) with $zip;
    }

    multi method encode(Str $str)
    {
        samewith $str.encode
    }

    multi method encode(Blob $buf?)
    {
        my Pointer $cred .= new;
        LEAVE free($_);
        munge-check(munge_encode($cred, $!context, $buf,
                                 $buf ?? $buf.bytes !! 0));
        nativecast(Str, $cred)
    }

    method decode-buf(Str $cred)
    {
        my int32 $len;
        my Pointer $ptr .= new;
        LEAVE free($_);
        munge-check(munge_decode($cred, $!context, $ptr, $len, $!uid, $!gid));
        buf8.new(nativecast(CArray[uint8], $ptr)[0 ..^ $len])
    }

    method decode(Str $cred) { $.decode-buf($cred).decode }
}

=begin pod

=head1 NAME

Munge -- MUNGE Uid 'N' Gid Emporium Authentication Service

=head1 SYNOPSIS

  use Munge;

  my $m = Munge.new;

  # Strings:
  my $encoded = $m.encode('this');
  say $m.decode($encoded);

  # Blobs:
  my $encoded = $m.encode(Buf.new(1,2,3,4));
  say $m.decode-buf($encoded);

=head1 DESCRIPTION

From the main Munge site: L<https://github.com/dun/munge/wiki>

MUNGE (MUNGE Uid 'N' Gid Emporium) is an authentication service for
creating and validating credentials. It is designed to be highly
scalable for use in an HPC cluster environment. It allows a process to
authenticate the UID and GID of another local or remote process within
a group of hosts having common users and groups. These hosts form a
security realm that is defined by a shared cryptographic key. Clients
within this security realm can create and validate credentials without
the use of root privileges, reserved ports, or platform-specific
methods.

=head2 Context

A new C<Munge::Context> is created for each new Munge object, and many
methods are forwarded to that context to query or manipulate it
(B<.error>, B<.cipher>, B<.MAC>, B<.zip>, B<.ttl>, B<.addr4>,
B<socket>, B<encode-time>, B<decode-time>, B<uid-restriction>,
B<gid-restriction>.

Since the context is set during the decoding process, it is likely not
what you want for encoding, so you probably want to use separate Munge
objects for encoding/decoding.

Encoding/decoding are also not thread-safe, so you should either lock
the Munge object during use, or better yet, just make a new (or clone)
object for separate threads.

=head1 METHODS

=head2 B<new>(:cipher, :MAC, :zip, :ttl, :socket, :uid-restriction,
:gid-restriction)

Create a new Munge object and context.

The optional arguments are used to initialize the C<Munge::Context>.

=head2 B<clone>()

Copy an existing Munge object and context.

=head2 B<encode>(Blob $buf?)
=head2 B<encode>(Str $str)

Create a credential contained in a base64 string.  An optional payload
(either Str or Blob) can be encapsulated as well.

=head2 B<decode-buf>(Str $cred)

Validates the specified credential, optionally returning the
encapsulated payload as a Blob.

Throws an exception for any error, including invalid credentials.

=head2 B<decode>(Str $cred)

Validates the specified credential, optionally returning the
encapsulated payload as a decoded string.

Throws an exception for any error, including invalid credentials.

=head1 EXCEPTIONS

Base exception is X::Munge::Error.

$exception.code will return a Munge::Error enumeration value `EMUNGE_*`

+$exception.code will give you the traditional libmunge error code.

=end pod
