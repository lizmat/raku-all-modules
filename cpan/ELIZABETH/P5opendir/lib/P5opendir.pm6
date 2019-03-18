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

module P5opendir:ver<0.0.4>:auth<cpan:ELIZABETH> {

    sub opendir(\handle, Str() $path) is export {
        my $success = True;
        CATCH { default { $success = False } }
        handle = DIRHANDLE.new($path);
        $success
    }

    proto sub readdir(|) is export {*}
    multi sub readdir(Mu:U, DIRHANDLE:D \handle) {
        CALLERS::<$_> = handle.next
    }
    multi sub readdir(DIRHANDLE:D \handle, :$void!)
      is DEPRECATED('Mu as first positional')
    {
        CALLERS::<$_> = handle.next
    }
    multi sub readdir(Scalar:U, DIRHANDLE:D \handle) { handle.next }
    multi sub readdir(DIRHANDLE:D \handle, :$scalar!)
      is DEPRECATED('Scalar as first positional')
    {
        handle.next
    }
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

=head1 ORIGINAL PERL 5 DOCUMENTATION

    opendir DIRHANDLE,EXPR
            Opens a directory named EXPR for processing by "readdir",
            "telldir", "seekdir", "rewinddir", and "closedir". Returns true if
            successful. DIRHANDLE may be an expression whose value can be used
            as an indirect dirhandle, usually the real dirhandle name. If
            DIRHANDLE is an undefined scalar variable (or array or hash
            element), the variable is assigned a reference to a new anonymous
            dirhandle; that is, it's autovivified. DIRHANDLEs have their own
            namespace separate from FILEHANDLEs.

    readdir DIRHANDLE
            Returns the next directory entry for a directory opened by
            "opendir". If used in list context, returns all the rest of the
            entries in the directory. If there are no more entries, returns
            the undefined value in scalar context and the empty list in list
            context.

            If you're planning to filetest the return values out of a
            "readdir", you'd better prepend the directory in question.
            Otherwise, because we didn't "chdir" there, it would have been
            testing the wrong file.

                opendir(my $dh, $some_dir) || die "can't opendir $some_dir: $!";
                @dots = grep { /^\./ && -f "$some_dir/$_" } readdir($dh);
                closedir $dh;

            As of Perl 5.12 you can use a bare "readdir" in a "while" loop,
            which will set $_ on every iteration.

                opendir(my $dh, $some_dir) || die;
                while(readdir $dh) {
                    print "$some_dir/$_\n";
                }
                closedir $dh;

            To avoid confusing would-be users of your code who are running
            earlier versions of Perl with mysterious failures, put this sort
            of thing at the top of your file to signal that your code will
            work monly on Perls of a recent vintage:

                use 5.012; # so readdir assigns to $_ in a lone while test

    telldir DIRHANDLE
            Returns the current position of the "readdir" routines on
            DIRHANDLE. Value may be given to "seekdir" to access a particular
            location in a directory. "telldir" has the same caveats about
            possible directory compaction as the corresponding system library
            routine.

    seekdir DIRHANDLE,POS
            Sets the current position for the "readdir" routine on DIRHANDLE.
            POS must be a value returned by "telldir". "seekdir" also has the
            same caveats about possible directory compaction as the
            corresponding system library routine.

    closedir DIRHANDLE
            Closes a directory opened by "opendir" and returns the success of
            that system call.

=head1 PORTING CAVEATS

The C<readdir> function has three modes:

=head2 list mode

By default, C<readdir> returns a list with all directory entries found.

    my @entries = readdir($dh);

=head2 scalar context

In scalar context, C<readdir> returns one directory entry at a time.  Add
C<Scalar> as the first positional variable to mimic this behaviour:

    while readdir(Scalar, $dh, :scalar) -> $entry {
        say "found $entry";
    }

=head2 void context

In void context, C<readdir> stores one directory entry at a time in C<$_>.
Add C<Mu> as the first positional variable to mimic this behaviour:

    .say while readdir(Mu, $dh, :void);

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5opendir . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018-2019 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
