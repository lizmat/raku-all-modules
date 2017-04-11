use NativeCall;

my $windows-dep-lock = Lock.new;
my $windows-dep-path;
sub libssh() {
    if %*ENV<PERL6_LIBSSH_LIB> -> $env {
        $env
    }
    elsif $*DISTRO.is-win {
        $windows-dep-lock.protect: {
            without $windows-dep-path {
                load-windows-dependencies();
                $windows-dep-path = extract-windows-library('ssh.dll');
            }
        }
        $windows-dep-path
    }
    else {
        'libssh.so.4'
    }
}
sub extract-windows-library($lib) {
    my $dest = "$*TMPDIR\\$lib";
    try %?RESOURCES{$lib}.IO.copy($dest);
    $dest
}
sub load-windows-dependencies(--> Nil) {
    # We try to call a non-existing symbol in the libraries; this does
    # enough to load them, though of course the call will fail, thus the
    # `try`.
    sub msvcr110() { extract-windows-library('msvcr110.dll') }
    sub libeay32() { extract-windows-library('libeay32.dll') }
    sub load-msvcr110() is native(&msvcr110) {*}
    sub load-libeay32() is native(&libeay32) {*}
    try load-msvcr110();
    try load-libeay32();
}

my class SSHSession is repr('CPointer') is export {}
my enum SSHSessionOptions is export <
    SSH_OPTIONS_HOST
    SSH_OPTIONS_PORT
    SSH_OPTIONS_PORT_STR
    SSH_OPTIONS_FD
    SSH_OPTIONS_USER
    SSH_OPTIONS_SSH_DIR
    SSH_OPTIONS_IDENTITY
    SSH_OPTIONS_ADD_IDENTITY
    SSH_OPTIONS_KNOWNHOSTS
    SSH_OPTIONS_TIMEOUT
    SSH_OPTIONS_TIMEOUT_USEC
    SSH_OPTIONS_SSH1
    SSH_OPTIONS_SSH2
    SSH_OPTIONS_LOG_VERBOSITY
    SSH_OPTIONS_LOG_VERBOSITY_STR
    SSH_OPTIONS_CIPHERS_C_S
    SSH_OPTIONS_CIPHERS_S_C
    SSH_OPTIONS_COMPRESSION_C_S
    SSH_OPTIONS_COMPRESSION_S_C
    SSH_OPTIONS_PROXYCOMMAND
    SSH_OPTIONS_BINDADDR
    SSH_OPTIONS_STRICTHOSTKEYCHECK
    SSH_OPTIONS_COMPRESSION
    SSH_OPTIONS_COMPRESSION_LEVEL
    SSH_OPTIONS_KEY_EXCHANGE
    SSH_OPTIONS_HOSTKEYS
    SSH_OPTIONS_GSSAPI_SERVER_IDENTITY
    SSH_OPTIONS_GSSAPI_CLIENT_IDENTITY
    SSH_OPTIONS_GSSAPI_DELEGATE_CREDENTIALS
    SSH_OPTIONS_HMAC_C_S
    SSH_OPTIONS_HMAC_S_C
>;
my enum SSHServerKnown is export (
    :SSH_SERVER_ERROR(-1),
    :SSH_SERVER_NOT_KNOWN(0),
    :SSH_SERVER_KNOWN_OK(1),
    :SSH_SERVER_KNOWN_CHANGED(2),
    :SSH_SERVER_FOUND_OTHER(3),
    :SSH_SERVER_FILE_NOT_FOUND(4)
);
sub ssh_new() returns SSHSession is native(&libssh) is export {*}
sub ssh_free(SSHSession) is native(&libssh) is export {*}
sub ssh_set_blocking(SSHSession, int32) is native(&libssh) is export {*}
sub ssh_options_set_int(SSHSession, int32, CArray[int32]) returns int32
    is symbol('ssh_options_set') is native(&libssh) is export {*}
sub ssh_options_set_str(SSHSession, int32, Str) returns int32
    is symbol('ssh_options_set') is native(&libssh) is export {*}
sub ssh_connect(SSHSession) returns int32 is native(&libssh) is export {*}
sub ssh_disconnect(SSHSession) is native(&libssh) is export {*}
sub ssh_is_server_known(SSHSession) returns int32 is native(&libssh) is export {*}
sub ssh_write_knownhost(SSHSession) returns int32 is native(&libssh) is export {*}
sub ssh_get_pubkey_hash(SSHSession, CArray[Pointer]) returns int32 is native(&libssh) is export {*}
sub ssh_get_hexa(Pointer, size_t) returns Str is native(&libssh) is export {*}
sub ssh_clean_pubkey_hash(CArray[Pointer]) is native(&libssh) is export {*}

my class SSHKey is repr('CPointer') is export {}
my enum SSHAuth is export (
    :SSH_AUTH_SUCCESS(0),
    :SSH_AUTH_DENIED(1),
    :SSH_AUTH_PARTIAL(2),
    :SSH_AUTH_INFO(3),
    :SSH_AUTH_AGAIN(4),
    :SSH_AUTH_ERROR(-1)
);
sub ssh_userauth_publickey_auto(SSHSession, Str, Str) returns int32
    is native(&libssh) is export {*}
sub ssh_pki_import_privkey_file(Str, Str, Pointer, Pointer, CArray[SSHKey])
    returns int32 is native(&libssh) is export {*}
sub ssh_userauth_publickey(SSHSession, Str, SSHKey) returns int32
    is native(&libssh) is export {*}
sub ssh_key_free(SSHKey) is native(&libssh) is export {*}
sub ssh_userauth_password(SSHSession, Str, Str) returns int32
    is native(&libssh) is export {*}

my class SSHEvent is repr('CPointer') is export {}
sub ssh_event_new() returns SSHEvent is native(&libssh) is export {*}
sub ssh_event_free(SSHEvent) is native(&libssh) is export {*};
sub ssh_event_add_session(SSHEvent, SSHSession) returns int32 is native(&libssh) is export {*}
sub ssh_event_remove_session(SSHEvent, SSHSession) returns int32 is native(&libssh) is export {*}
sub ssh_event_dopoll(SSHEvent, int32) returns int32 is native(&libssh) is export {*}

my class SSHChannel is repr('CPointer') is export {}
sub ssh_channel_new(SSHSession) returns SSHChannel is native(&libssh) is export {*}
sub ssh_channel_free(SSHChannel) is native(&libssh) is export {*}
sub ssh_channel_open_session(SSHChannel) returns int32 is native(&libssh) is export {*}
sub ssh_channel_close(SSHChannel) returns int32 is native(&libssh) is export {*}
sub ssh_channel_request_exec(SSHChannel, Str) returns int32 is native(&libssh) is export {*}
sub ssh_channel_read_nonblocking(SSHChannel, Buf, uint32, int32) returns int32
    is native(&libssh) is export {*}
sub ssh_channel_is_eof(SSHChannel) returns int32 is native(&libssh) is export {*}
sub ssh_channel_get_exit_status(SSHChannel) returns int32 is native(&libssh) is export {*}
sub ssh_channel_window_size(SSHChannel) returns uint32 is native(&libssh) is export {*}
sub ssh_channel_write(SSHChannel, Blob, uint32) returns int32 is native(&libssh) is export {*}
sub ssh_channel_send_eof(SSHChannel) returns int32 is native(&libssh) is export {*}
sub ssh_channel_open_forward(SSHChannel, Str, int32, Str, int32) returns int32
    is native(&libssh) is export {*}
sub ssh_channel_listen_forward(SSHSession, Str, int32, CArray[int32]) returns int32
    is native(&libssh) is symbol('ssh_forward_listen') is export {*}
sub ssh_channel_accept_forward(SSHSession, int32, CArray[int32]) returns SSHChannel
    is native(&libssh) is export {*}

sub ssh_get_error(SSHSession) returns Str is symbol('ssh_get_error')
    is native(&libssh) is export {*}
