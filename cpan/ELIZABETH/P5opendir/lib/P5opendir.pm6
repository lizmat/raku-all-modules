use v6.c;

my class DIRHANDLE {
    has str $.path;
    has str @.items;
    has int $.index;

    # This class heavily depends on nqp:: ops, so enable it for the whole class
    use nqp;

    # Since the nqp:: ops don't have any support for 'telldir', 'seekdir' or
    # 'rewinddir' functionality, we're going to slurp the whole directory
    # immediately and fake that functionality (as a first approximation).
    method SET-SELF($!path) {
        my $handle := nqp::opendir($!path); # throws if it didn't work
        nqp::while(
          nqp::chars(my str $next = nqp::nextfiledir($handle)),
          nqp::push_s(@!items,$next)
        );
        nqp::closedir($handle);
        $!index = 0;
        self
    }
    method new(\path) { DIRHANDLE.CREATE.SET-SELF(path) }

    method next() {
        $!index < nqp::elems(@!items)
          ?? nqp::atpos_s(@!items,$!index++)
          !! Nil
    }
    method left() {
        if $!index < nqp::elems(@!items) {
            my int $index = nqp::elems(@!items);
            my $result := @!items.splice($!index);
            $!index = $index;
            $result
        }
        else {
            ()
        }
    }
    method set(\index --> True) {
        $!index = (index max 0) min nqp::elems(@!items)
    }
    method elems() { nqp::elems(@!items) }

    method Str(--> Str:D) { $!path }
}

module P5opendir:ver<0.0.2>:auth<cpan:ELIZABETH> {

    sub opendir(\handle, Str() $path) is export {
        my $success = True;
        CATCH { default { $success = False } }
        handle = DIRHANDLE.new($path);
        $success
    }

    proto sub readdir(|) is export {*}
    multi sub readdir(DIRHANDLE:D \handle, :$void!) {
        CALLERS::<$_> = handle.next
    }
    multi sub readdir(DIRHANDLE:D \handle, :$scalar!) { handle.next }
    multi sub readdir(DIRHANDLE:D \handle) { handle.left }

    sub telldir(DIRHANDLE:D \handle) is export { handle.index }
    sub rewinddir(DIRHANDLE:D \handle) is export { handle.set(0) }
    sub seekdir(DIRHANDLE:D \handle, Int() $pos) is export { handle.set($pos) }
    sub closedir(DIRHANDLE:D \handle) is export { True }
}

=begin pod

=head1 NAME

P5opendir - Implement Perl 5's opendir() and related built-ins

=head1 SYNOPSIS

    # exports opendir, readdir, telldir, seekdir, rewinddir, closedir
    use P5opendir;

    opendir(my $dh, $some_dir) || die "can't opendir $some_dir: $!";
    my @dots = grep { .starts-with('.') && "$some_dir/$_".IO.f }, readdir($dh);
    closedir $dh;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<opendir>, C<readdir>,
C<telldir>, C<seekdir>, C<rewinddir> and C<closedir> functions of Perl 5
as closely as possible.

=head1 PORTING CAVEATS

The C<readdir> function has three modes:

=head2 list mode

By default, C<readdir> returns a list with all directory entries found.

    my @entries = readdir($dh);

=head2 scalar context

In scalar context, C<readdir> returns one directory entry at a time.  Add the
C<:scalar> named variable to mimic this behaviour:

    while readdir($dh, :scalar) -> $entry {
        say "found $entry";
    }

=head2 void context

In void context, C<readdir> stores one directory entry at a time in C<$_>.
Add the C<:void> named variable to mimic this behaviour:

    .say while readdir($dh, :void);

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5opendir . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
