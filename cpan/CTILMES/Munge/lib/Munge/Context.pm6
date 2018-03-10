use NativeCall;

constant LIBMUNGE = ('munge', v2);

enum Munge::Opt <
    MUNGE_OPT_CIPHER_TYPE
    MUNGE_OPT_MAC_TYPE
    MUNGE_OPT_ZIP_TYPE
    MUNGE_OPT_REALM
    MUNGE_OPT_TTL
    MUNGE_OPT_ADDR4
    MUNGE_OPT_ENCODE_TIME
    MUNGE_OPT_DECODE_TIME
    MUNGE_OPT_SOCKET
    MUNGE_OPT_UID_RESTRICTION
    MUNGE_OPT_GID_RESTRICTION
>;

enum Munge::Cipher <
    MUNGE_CIPHER_NONE
    MUNGE_CIPHER_DEFAULT
    MUNGE_CIPHER_BLOWFISH
    MUNGE_CIPHER_CAST5
    MUNGE_CIPHER_AES128
    MUNGE_CIPHER_AES256
>;

enum Munge::MAC <
    MUNGE_MAC_NONE
    MUNGE_MAC_DEFAULT
    MUNGE_MAC_MD5
    MUNGE_MAC_SHA1
    MUNGE_MAC_RIPEMD160
    MUNGE_MAC_SHA256
    MUNGE_MAC_SHA512
>;

enum Munge::Zip <
    MUNGE_ZIP_NONE
    MUNGE_ZIP_DEFAULT
    MUNGE_ZIP_BZLIB
    MUNGE_ZIP_ZLIB
>;

constant \MUNGE_TTL_MAXIMUM := -1;
constant \MUNGE_TTL_DEFAULT := 0;

constant \MUNGE_UID_ANY := -1;
constant \MUNGE_GID_ANY := -1;

enum Munge::Error <
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
>;

class X::Munge::Error is Exception
{
    has Munge::Error $.code;

    sub munge_strerror(int32 --> Str) is native(LIBMUNGE) {}

    method message() { munge_strerror($!code) }
}

class X::Munge::Unknown is X::Munge::Error
{
    has $.thing;
    has $.value;
    method message { "Unknown $!thing: $!value" }
}

class X::Munge::UnknownCipher is X::Munge::Unknown
{
    method new($cipher) { nextwith(thing => 'cipher', value => $cipher) }
}

class X::Munge::UnknownMAC is X::Munge::Unknown
{
    method new($mac) { nextwith(thing => 'MAC', value => $mac) }
}

class X::Munge::UnknownZip is X::Munge::Unknown
{
    method new($zip) { nextwith(thing => 'Zip', value => $zip) }
}

sub munge-check($code) is export
{
    die X::Munge::Error.new(code => Munge::Error($code))
        unless $code == EMUNGE_SUCCESS;
}

class Munge::Context is repr('CPointer')
{
    sub munge_ctx_create(--> Munge::Context) is native(LIBMUNGE) {}

    sub munge_ctx_destroy(Munge::Context)  is native(LIBMUNGE) {}

    sub munge_ctx_get_int32(Munge::Context, int32, int32 is rw --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_get') {}

    sub munge_ctx_set_int32(Munge::Context, int32, int32 --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_set') {}

    sub munge_ctx_get_int64(Munge::Context, int32, int64 is rw --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_get') {}

    sub munge_ctx_set_int64(Munge::Context, int32, int64 --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_set') {}

    sub munge_ctx_get_str(Munge::Context, int32, Pointer is rw --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_get') {}

    sub munge_ctx_set_str(Munge::Context, int32, Str --> int32)
        is native(LIBMUNGE) is symbol('munge_ctx_set') {}

    sub inet_ntoa(int64 --> Str) is native is symbol('inet_ntoa') {}

    method new(--> Munge::Context) { munge_ctx_create }

    method clone(--> Munge::Context)
        is native(LIBMUNGE) is symbol('munge_ctx_copy') {}

    method error(--> Str) is native(LIBMUNGE) is symbol('munge_ctx_strerror') {}

    multi method cipher(Munge::Cipher $cipher?)
    {
        my int32 $ciphertype;
        with $cipher
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_CIPHER_TYPE, $_))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_CIPHER_TYPE,
                                        $ciphertype));
        Munge::Cipher($ciphertype)
    }

    multi method cipher(Str $cipher)
    {
        samewith Munge::Cipher::{"MUNGE_CIPHER_$cipher.uc()"}
                 // die X::Munge::UnknownCipher.new($cipher)
    }

    multi method MAC(Munge::MAC $mac?)
    {
        my int32 $mactype;
        with $mac
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_MAC_TYPE, $_))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_MAC_TYPE, $mactype));
        Munge::MAC($mactype)
    }

    multi method MAC(Str $mac)
    {
        samewith Munge::MAC::{"MUNGE_MAC_$mac.uc()"}
                 // die X::Munge::UnknownMAC.new($mac)
    }

    multi method zip(Munge::Zip $zip?)
    {
        my int32 $ziptype;
        with $zip
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_ZIP_TYPE, $_))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_ZIP_TYPE, $ziptype));
        Munge::Zip($ziptype)
    }

    multi method zip(Str $zip)
    {
        samewith Munge::Zip::{"MUNGE_ZIP_$zip.uc()"}
                 // die X::Munge::UnknownZip.new($zip)
    }

    method ttl(Int $seconds?)
    {
        my int32 $ttl;
        with $seconds
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_TTL, $_))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_TTL, $ttl));
        $ttl
    }

    method addr4
    {
        my int64 $addr4;

        munge-check(munge_ctx_get_int64(self, MUNGE_OPT_ADDR4, $addr4));
        inet_ntoa($addr4)
    }

    method encode-time
    {
        my int64 $time;
        munge-check(munge_ctx_get_int64(self, MUNGE_OPT_ENCODE_TIME, $time));
        DateTime.new($time)
    }

    method decode-time
    {
        my int64 $time;
        munge-check(munge_ctx_get_int64(self, MUNGE_OPT_DECODE_TIME, $time));
        DateTime.new($time)
    }

    method socket(Str $local-domain-socket?)
    {
        my Pointer $p .= new;
        with $local-domain-socket
        {
            munge-check: munge_ctx_set_str(self, MUNGE_OPT_SOCKET,
                                           $local-domain-socket)
        }
        munge-check: munge_ctx_get_str(self, MUNGE_OPT_SOCKET, $p);
        nativecast(Str, $p)
    }

    method uid-restriction(Int $uid?)
    {
        my int32 $uid_t;
        with $uid
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_UID_RESTRICTION,
                                            $uid))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_UID_RESTRICTION,
                                        $uid_t));
        $uid_t
    }

    method gid-restriction(Int $gid?)
    {
        my int32 $gid_t;
        with $gid
        {
            munge-check(munge_ctx_set_int32(self, MUNGE_OPT_GID_RESTRICTION,
                                            $gid))
        }
        munge-check(munge_ctx_get_int32(self, MUNGE_OPT_GID_RESTRICTION,
                                        $gid_t));
        $gid_t
    }

    submethod DESTROY { munge_ctx_destroy(self) }
}

=begin pod

=head1 NAME

Munge::Context -- Context for MUNGE

=head1 SYNOPSIS

  use Munge::Context;

  my $ctx = Munge::Context.new;

  say $ctx.cipher;

  $ctx.cipher(MUNGE_CIPHER_BLOWFISH);
  # or
  $ctx.cipher('BLOWFISH');

  say $ctx.MAC;

  $ctx.MAC(MUNGE_MAC_SHA1);
  # or
  $ctx.MAC('SHA1');

  say $ctx.zip;

  $ctx.zip(MUNGE_ZIP_BZLIB);
  # or
  $ctx.zip('BZLIB');

  $ctx.ttl(300); # seconds
  $ctx.ttl(MUNGE_TTL_MAXIMUM);


  say $ctx.addr4; # dotted quad IP address

  say $ctx.encode-time; # DateTime
  say $ctx.decode-time;

  say $ctx.socket; # /path/to/socket
  $ctx.socket('/path/to/socket');

  $ctx.uid-restriction(MUNGE_UID_ANY); # or specific uid
  $ctx.gid-restriction(MUNGE_GID_ANY); # or specific gid


=head1 DESCRIPTION

A Context for C<Munge>;

=head1 METHODS

=head2 B<new>(--> B<Munge::Context>)

Create a new context.

=head2 B<clone>(--> B<Munge::Context>)

Copy a context.

=head2 B<error>(--> Str)

Returns a descriptive text string describing the MUNGE error number
according to the context.

=head2 B<cipher>(Munge::Cipher $cipher?)
=head2 B<cipher>(Str $cipher)

Optionally set the context cipher to: MUNGE_CIPHER_NONE,
MUNGE_CIPHER_DEFAULT, MUNGE_CIPHER_BLOWFISH, MUNGE_CIPHER_CAST5,
MUNGE_CIPHER_AES128, MUNGE_CIPHER_AES256

Ciphers can also be specified by string without MUNGE_CIPHER.

Returns a Munge::Cipher enumeration one of above.

=head2 B<MAC>(Munge::MAC $mac?)
=head2 B<MAC>(Str $mac)

Optionally set the context message authentication code (MAC) to:
MUNGE_MAC_DEFAULT MUNGE_MAC_MD5 MUNGE_MAC_SHA1 MUNGE_MAC_RIPEMD160
MUNGE_MAC_SHA256 MUNGE_MAC_SHA512

MAC can also be specified by string without MUNGE_MAC.

Returns a Munge::MAC enumeration one of above.

=head2 B<zip>(Munge::Zip $zip?)
=head2 B<zip>(Str $zip)

Optionally set the context compression type to: MUNGE_ZIP_NONE
MUNGE_ZIP_DEFAULT MUNGE_ZIP_BZLIB MUNGE_ZIP_ZLIB

Zip can also be specified by string without MUNGE_ZIP.

Returns a Munge::Zip enumeration one of above.

=head2 B<ttl>(Int $seconds?)

Optionally set Time-To-Live number of seconds after the encode-time
that the credential is considered valid.  Can also specify
MUNGE_TTL_DEFAULT (0) or MUNGE_TTL_MAXIMUM (-1).

Returns the current value.

=head2 B<addr4>(--> Str)

Returns the dotted quad for the IPv4 address of the host where the
credential was encoded.

=head2 B<encode-time>(--> DateTime)

Returns the time at which the credential was encoded.

=head2 B<decode-time>(--> DateTime)

Returns the time at which the credential was decoded.

=head2 B<socket>(Str $local-domain-socket?)

Get and optionally set the local domain socket for connecting with
munged.

=head2 B<uid-restriction>(Int $uid?)

Get and optionally set the UID allowed to decode the credential.
Defaults to MUNGE_UID_ANY (-1).

=head2 B<gid-restriction>(Int $gid?)

Get and optionally set the GID allowed to decode the credential.
Defaults to MUNGE_GID_ANY (-1).

=end pod
