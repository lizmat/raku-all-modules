use v6;
unit module Terminal::Readsecret;

use NativeCall;

my constant $library = %?RESOURCES<libraries/readsecret>.Str;

my Int enum rsecret_error_ty (
    RSECRET_SUCCESS => 0,
    RSECRET_ERROR_BAD_ARG => 1, # arguments to function are invalid 
    RSECRET_ERROR_TTY_OPEN => 2, #  can not open the controlling terminal 
    RSECRET_ERROR_SIGACTION => 3, # failed to establish signal handlers
    RSECRET_ERROR_NOECHO => 4, # failed to set terminal to no-echo mode
    RSECRET_ERROR_PROMPT => 5, # failed to write prompt
    RSECRET_ERROR_READ => 6, # failure during reading of user input
    RSECRET_ERROR_LENGTH => 7, # user input was too long to hold in the supplied buffer
    RSECRET_ERROR_INTERRUPTED => 8, # program was interrupted during input
    RSECRET_ERROR_TIMER_CREATE => 9, # could not create real-time timer
    RSECRET_ERROR_TIMEOUT => 10 # User not quick enough, a timeout value expired
);

my constant max-secret-length = 1024;
my constant time_t = int64;

class timespec is repr('CStruct') is export {
    has time_t $.tv_sec;
    has int64 $.tv_nsec;
}

my sub rsecret_get_secret_from_tty(CArray[int8], size_t, Str) returns int32 is native($library) is export { * }
my sub rsecret_get_secret_from_tty_timed(CArray[int8], size_t, Str, timespec) returns int32 is native($library) is export { * }
my sub rsecret_strerror(int32) returns Str is native($library) is export { * }

proto getsecret(Str:D $msg, |) { * }

multi sub getsecret(Str:D $msg, timespec $timeout) returns Str is export {
    my $buf = CArray[int8].new;
    $buf[max-secret-length] = 0;
    my size_t $size = nativesizeof(int8) * max-secret-length;
    my $status = rsecret_get_secret_from_tty_timed($buf, $size, $msg, $timeout);
    validate-response($status);
    buf2secret($buf);
}

multi sub getsecret(Str:D $msg) returns Str is export {
    my $buf = CArray[int8].new;
    $buf[max-secret-length] = 0;
    my size_t $size = nativesizeof(int8) * max-secret-length;
    my $status = rsecret_get_secret_from_tty($buf, $size, $msg);
    validate-response($status);
    buf2secret($buf);
}

my sub validate-response(Int $status) returns Bool {
    if ($status != RSECRET_SUCCESS) {
	die rsecret_strerror($status);
    }
    return True;
}

my sub buf2secret(CArray[int8] $buf) {
    my Str $secret = "";
    loop (my $i = 0; $i < max-secret-length; $i++) {
	last if Int.new($buf[$i]) == 0;
	$secret = $secret ~ Int.new($buf[$i]).chr;
    }
    return $secret;
}

=begin pod

=head1 NAME

Terminal::Readsecret - A perl6 binding of readsecret ( https://github.com/dmeranda/readsecret ) for reading secrets or passwords from a command line secretly (not being displayed)

=head1 SYNOPSIS

=head2 EXAMPLE1

       use Terminal::Readsecret;
       my $password = getsecret("password:" );
       say "your password is: " ~ $password;

=head2 EXAMPLE2

       use Terminal::Readsecret;
       my timespec $timeout .= new(tv_sec => 5, tv_nsec => 0); # set timeout to 5 sec
       my $password = getsecret("password:", $timeout);
       say "your password is: " ~ $password;

=head1 DESCRIPTION

Terminal::Readsecret is a perl6 binding of readsecret ( L<https://github.com/dmeranda/readsecret> ).
Readsecret is a simple self-contained C (or C++) library intended to be used on Unix and Unix-like operating systems that need to read a password or other textual secret typed in by the user while in a text-mode environment, such as from a console or shell.

=head2 METHODS

=head3 getsecret

       proto getsecret(Str:D, |) returns Str
       multi sub getsecret(Str:D) returns Str
       multi sub getsecret(Str:D, timespec) returns Str

Reads secrets or passwords from a command line and returns its input.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

Readsecret by Deron Meranda is licensed under Public Domain ( L<http://creativecommons.org/publicdomain/zero/1.0/> ).

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=head1 SEE ALSO

=item readsecret L<https://github.com/dmeranda/readsecret>

=end pod
