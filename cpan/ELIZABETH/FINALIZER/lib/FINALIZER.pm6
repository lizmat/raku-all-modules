use v6.c;

class FINALIZER:ver<0.0.5>:auth<cpan:ELIZABETH> {
    # The blocks that this finalizer needs to finalize
    has @.blocks;
    has $!lock;

    # Make sure we have a lock for adding / removing from blocks
    submethod TWEAK() { $!lock = Lock.new }

    # The actual method calling the registered blocks for this finalizer
    method FINALIZE(FINALIZER:D:) {
        $!lock.protect: {
            my @exceptions;
            for @!blocks -> &code {
                code();
                CATCH { default { @exceptions.push($_) } }
            }
            dd @exceptions if @exceptions;
        }
    }

    # Run code with a lock protecting changes to blocks
    method !protect(FINALIZER:D: &code) { $!lock.protect: &code }

    # Register a block for finalizing if there is a dynamic variable with
    # a FINALIZER object in it.
    method register(FINALIZER:U: &code --> Callable:D) {
        with $*FINALIZER -> $finalizer {
            $finalizer!protect: { $finalizer.blocks.push(&code) }
            -> { $finalizer!unregister(&code) }
        }
        else {
            -> --> Nil { }
        }
    }

    # Unregister a finalizing block: done as a private object method to
    # make access to blocks easier.  Assumes we're already in protected
    # mode wrt making changes to blocks.
    method !unregister(FINALIZER:D: &code --> Nil) {
        my $WHICH := &code.WHICH;
        @!blocks.splice($_,1) with @!blocks.first( $WHICH eq *.WHICH, :k );
    }
}

# Exporting for a client environment
multi sub EXPORT() {

    # The magic incantation to export a LEAVE phaser to the scope where
    # the -use- statement is placed, Zoffix++ for producing this hack!
    $*W.add_phaser: $*LANG, 'LEAVE', { $*FINALIZER.FINALIZE }

    # Make sure we export a dynamic variable as well, to serve as the
    # check point for the finalizations that need to happen in this scope.
    my %export;
    %export.BIND-KEY('$*FINALIZER',my $*FINALIZER = FINALIZER.new);
    %export
}

# Exporting for a module environment
multi sub EXPORT('class-only') { {} }

=begin pod

=head1 NAME

FINALIZER - dynamic finalizing for objects that need finalizing

=head1 SYNOPSIS

    {
        use FINALIZER;   # enable finalizing for this scope
        my $foo = Foo.new(...);
        # do stuff with $foo
    }
    # $foo has been finalized by exiting the above scope

    # different file / module
    use FINALIZER <class-only>;   # only get the FINALIZER class
    class Foo {
        has &!unregister;

        submethod TWEAK() {
            &!unregister = FINALIZER.register: { .finalize with self }
        }
        method finalize() {
            &!unregister();  # make sure there's no registration anymore
            # do whatever we need to finalize, e.g. close db connection
        }
    }

=head1 DESCRIPTION

FINALIZER allows one to register finalization of objects in the scope that
you want, rather than in the scope where objects were created (like one
would otherwise do with C<LEAVE>  blocks or the C<is leave> trait).

=head1 AS A MODULE DEVELOPER

If you are a module developer, you need to use the FINALIZE module in your
code.  In any logic that returns an object (typically the C<new> method) that
you want finalized at the moment the client decides, you register a code
block to be executed when the object should be finalized.  Typically that
looks something like:

    use FINALIZER <class-only>;  # only get the FINALIZER class
    class Foo {
        has &!unregister;

        submethod TWEAK() {
            &!unregister = FINALIZER.register: { .finalize with self }
        }
        method finalize() {
            &!unregister();  # make sure there's no registration anymore
            # do whatever we need to finalize, e.g. close db connection
        }
    }

=head1 AS A PROGRAM DEVELOPER

Just use the module in the scope you want to have objects finalized for
when that scope is left.  If you don't use the module at all, all objects
that have been registered for finalization, will be finalized when the
program exits.  If you want to have finalization happen for some scope,
just add C<use FINALIZER> in that scope.  This could e.g. be used inside
C<start> blocks, to make sure all registered resources of a job run in
another thread, are finalized:

    await start {
        use FINALIZE;
        # open database handles, shared memory, whatever
        my $foo = Foo.new(...);
    }   # all finalized after the job is finished

=head1 RELATION TO DESTROY METHOD

This module has B<no> direct connection with the C<.DESTROY> method
functionality in Perl 6.  However, if you, as a module developer, use
this module, you do not need to supply a C<DESTROY> method as well, as
the finalization will have been done by the C<FINALIZER> module.  And as
the finalizer code that you have registered, will keep the object otherwise
alive until the program exits.

It therefore makes sense to reset the variable in the code doing the
finalization.  For instance, in the above class Foo:

        method finalize(\SELF: --> Nil) {
            # do stuff with SELF
            SELF = Nil
        }

The C<\SELF:> is a way to get the invocant without it being decontainerized.
This allows resetting the variable containing the object (by assigning C<Nil>
to it).

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/FINALIZER . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
