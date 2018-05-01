use v6.c;

use NativeCall;

my constant @message =
  '',
  'Operation not permitted',
  'No such file or directory',
  'No such process',
  'Interrupted system call',
  'error',
  'No such device or address',
  'Argument list too long',
  'Exec format error',
  'Bad file number',
  'No child processes',
  'Try again',
  'Out of memory',
  'Permission denied',
  'Bad address',
  'Block device required',
  'Device or resource busy',
  'File exists',
  'Cross-device link',
  'No such device',
  'Not a directory',
  'Is a directory',
  'Invalid argument',
  'File table overflow',
  'Too many open files',
  'Not a typewriter',
  'Text file busy',
  'File too large',
  'No space left on device',
  'Illegal seek',
  'Read-only file system',
  'Too many links',
  'Broken pipe',
  'Math argument out of domain of func',
  'Math result not representable',
  'Resource deadlock would occur',
  'File name too long',
  'No record locks available',
  'Function not implemented',
  'Directory not empty',
  'Too many symbolic links encountered',
  'Operation would block',
  'No message of desired type',
  'Identifier removed',
  'Channel number out of range',
  'Level 2 not synchronized',
  'Level 3 halted',
  'Level 3 reset',
  'Link number out of range',
  'Protocol driver not attached',
  'No CSI structure available',
  'Level 2 halted',
  'Invalid exchange',
  'Invalid request descriptor',
  'Exchange full',
  'No anode',
  'Invalid request code',
  'Invalid slot',
  'Bad font file format',
  'Device not a stream',
  'No data available',
  'Timer expired',
  'Out of streams resources',
  'Machine is not on the network',
  'Package not installed',
  'Object is remote',
  'Link has been severed',
  'Advertise error',
  'Srmount error',
  'Communication error on send',
  'Protocol error',
  'Multihop attempted',
  'RFS specific error',
  'Not a data message',
  'Value too large for defined data type',
  'Name not unique on network',
  'File descriptor in bad state',
  'Remote address changed',
  'Can not access a needed shared library',
  'Accessing a corrupted shared library',
  '.lib section in a.out corrupted',
  'Attempting to link in too many shared libraries',
  'Cannot exec a shared library directly',
  'Illegal byte sequence',
  'Interrupted system call should be restarted',
  'Streams pipe error',
  'Too many users',
  'Socket operation on non-socket',
  'Destination address required',
  'Message too long',
  'Protocol wrong type for socket',
  'Protocol not available',
  'Protocol not supported',
  'Socket type not supported',
  'Operation not supported on transport endpoint',
  'Protocol family not supported',
  'Address family not supported by protocol',
  'Address already in use',
  'Cannot assign requested address',
  'Network is down',
  'Network is unreachable',
  'Network dropped connection because of reset',
  'Software caused connection abort',
  'Connection reset by peer',
  'No buffer space available',
  'Transport endpoint is already connected',
  'Transport endpoint is not connected',
  'Cannot send after transport endpoint shutdown',
  'Too many references: cannot splice',
  'Connection timed out',
  'Connection refused',
  'Host is down',
  'No route to host',
  'Operation already in progress',
  'Operation now in progress',
  'Stale NFS file handle',
  'Structure needs cleaning',
  'Not a XENIX named type file',
  'No XENIX semaphores available',
  'Is a named type file',
  'Remote I/O error',
  'Quota exceeded',
  'No medium found',
  'Wrong medium type',
  'Operation Canceled',
  'Required key not available',
  'Key has expired',
  'Key has been revoked',
  'Key was rejected by service',
  'Owner died',
;

my constant CLIB = $*KERNEL.name eq 'darwin'
  ?? 'libSystem.B.dylib'
  !! 'libc.so.6';   # other variations may need to be added later
my int $last_set = 0;
my int $last_seen_native
  = my $ERRNO := cglobal(CLIB, "errno", int32);

my class errno {
    method !index() {
        my int $errno_now = $ERRNO;
        $last_set = $last_seen_native = $errno_now
          if $last_seen_native != $errno_now;
        $last_set
    }
    method Str(--> Str:D)  { @message[self!index] }
    method gist(--> Str:D) {
        if self!index -> $index {
            "@message[$index] (errno = $index)"
        }
        else {
            ""
        }
    }
    method Numeric(--> Int:D) { self!index }
}

module Unix::errno:ver<0.0.2>:auth<cpan:ELIZABETH> {
    my $proxy := Proxy.new(
      FETCH => -> $ { UNIT::errno },
      STORE => -> $, $value { set_errno($value) }
    );

    my sub errno() is export is raw { $proxy }
    my sub set_errno(Int() $value) is export is raw {
        $last_seen_native = $ERRNO;  # ignore any changes until now
        $last_set = $value;
        $proxy
    }
}

=begin pod

=head1 NAME

Unix::errno - Provide transparent access to errno

=head1 SYNOPSIS

    use Unix::errno;  # exports errno, set_errno

    set_errno(2);

    say errno;              # No such file or directory (errno = 2)
    say "failed: {errno}";  # failed: No such file or directory
    say +errno;             # 2

=head1 DESCRIPTION

This module provides access to the C<errno> variable that is available on
all Unix-like systems.  Please note that in a threaded environment such as
Perl 6 is, the value of C<errno> is even more volatile than it has been
already.  For now, this issue is ignored.

=head1 CAVEATS

Since setting of any "extern" variables is not supported yet by C<NativeCall>,
the setting of C<errno> is faked.  If C<set_errno> is called, it will set
the value only in a shadow copy.  That value will be returned As long as
the underlying "real" errno doesn't change (at which point that value
will be returned.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Unix-errno . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
