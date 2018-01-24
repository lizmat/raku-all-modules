use v6.c;
unit class Sys::Hostname:ver<0.0.2>;

#use NativeCall;

#my sub gethostname(Str $name, size_t $len --> int32) is native {*}

#my class UnameStruct is repr('CStruct') {
#    has Str $.sysname;
#    has Str $.nodename;
#    has Str $.release;
#    has Str $.version;
#    has Str $.machine;
#}
#my sub uname(UnameStruct:D $ --> int32) is native {*}

my sub clean($name is copy) { $name.subst(/ \s | \0 /,'',:g) }

sub hostname() is export {
    clean(qx/hostname/)
      || clean(qx/uname -n/)
      || clean(slurp "/com/host")
      // die "Cannot get host name of local machine"
}

=begin pod

=head1 NAME

Sys::Hostname - Implement Perl 5's Sys::Hostname core module

=head1 SYNOPSIS

  use Sys::Hostname;
  $host = hostname;

=head1 DESCRIPTION

Attempts several methods of getting the system hostname and then caches the
result. It tries the first available of the C library's gethostname(),
uname(2), syscall(SYS_gethostname), `hostname`, `uname -n`, and the file
/com/host. If all that fails it dies.

All NULs, returns, and newlines are removed from the result.

=head1 PORTING CAVEATS

At present, only `hostname`, `uname -n` and /com/host are attempted before
dieing.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sys-Hostname . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Originally developed by David Sundstrom and Greg Bacon.  Re-imagined from Perl 5
as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
