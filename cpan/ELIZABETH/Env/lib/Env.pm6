use v6.c;

module Env:ver<0.0.2>:auth<cpan:ELIZABETH> { }

# Since we cannot use the normal EXPORT mechanism, we need to resort to some
# deep magic, originally conceived by Zoffix Znet.  Since EXPORT is run at
# compile time, the $*W object is available, which refers to the nqp World
# object (from src/Perl/World.nqp).  This class has 2 methods that are being
# used by the normal export process:
#
# - cur_lexpad
#   This returns the lexpad for which we're compiling
#
# - install_lexical_symbol
#   Given a lexpad and name, install given object in there.

sub EXPORT(*@keys) {
    @keys = %*ENV.keys unless @keys;

    # things we need to work with
    my $world  := $*W;
    my $lexpad := $world.cur_lexpad;

    # Proxy for scalar keys
    sub as-scalar($name is copy) is raw {
        $name = $name.substr(1) if $name.starts-with('$');

        # re-containerize with default Nil
        %*ENV{$name} := my $value is default(Nil) = %*ENV{$name};

        Proxy.new(
          FETCH => -> $ { $value },
          STORE => -> $, \new-value {
              %*ENV{$name}:delete if new-value === Nil;
              $value = new-value
          }
        )
    }

    # Proxy for array keys
    sub as-array($name is copy) is raw {
        $name = $name.substr(1);
        my $sep  := $*DISTRO.path-sep;
        my @parts = %*ENV{$name}.split($sep);

        %*ENV{$name} := Proxy.new(
          FETCH => -> $ {
              %*ENV{$name}:exists ?? @parts.join($sep) !! Nil
          },
          STORE => -> $, \new-value {
              if new-value === Nil {
                  %*ENV{$name}:delete;
                  @parts = ();
                  Nil
              }
              else {
                  @parts = new-value.split($sep)
              }
          }
        );

        @parts
    }

    # name of variable to be installed
    sub varname($name --> Str:D) {
        $name.starts-with('$') || $name.starts-with('@') ?? $name !! "\$$name"
    }

    # run through all the keys (implicitely) specified
    for @keys -> $name --> Nil {
        $world.install_lexical_symbol(
          $lexpad,
          varname($name),
          $name.starts-with('@')
            ?? as-array($name)
            !! as-scalar($name)
        )
    }

    {}  # we don't export anything using the "normal" mechanism
}

=begin pod

=head1 NAME

Env - Port of Perl 5's Env module

=head1 SYNOPSIS

    use Env;
    use Env <PATH HOME TERM>;
    use Env <$SHELL @LD_LIBRARY_PATH>;

=head1 DESCRIPTION

Perl 6 maintains environment variables in a special hash named C<%*ENV>.
For when this access method is inconvenient, the Perl 6 module Env allows
environment variables to be treated as scalar or array variables.

The C<Env> binds environment variables with suitable names to "our" Perl
variables with the same names. By default it binds all existing environment
variables (%*ENV.keys) to scalars.  If names are specified, it takes them
to be a list of variables to bind; it's okay if they don't yet exist. The
scalar type prefix '$' is inferred for any element of this list not prefixed
by '$' or '@'. Arrays are implemented in terms of split and join, using
C<$*DISTRO.path-sep> as the delimiter.

After an environment variable is bound, merely use it like a normal variable.
You may access its value

    @path = split(':', $PATH);
    say join("\n", @LD_LIBRARY_PATH);

or modify it

    $PATH .= ":.";
    push @LD_LIBRARY_PATH, $dir;

however you'd like. Bear in mind, however, that each access to a bound array
variable requires splitting the environment variable's string anew.

The code:

    use Env <@PATH>;
    push @PATH, '.';

is equivalent to:

    use Env <PATH>;
    $PATH .= ":.";

except that if $*ENV{PATH} started out empty, the second approach leaves it
with the (odd) value ":.", but the first approach leaves it with ".".

To remove a bound environment variable from the environment, undefine it:

    undefine $PATH;
    undefine @LD_LIBRARY_PATH;

=head1 IDIOMATIC PERL 6 WAYS

If you're only interested in a few environment variables to be exported to
your lexical context as constants, you can use the auto-destructuring feature
of signatures in Perl 6:

    my (:$PATH, :$SHELL, *%) := %*ENV;

This will still collide with already defined variables (such as C<$_>).  This
can be circumvented by creating a new scope:

    given %*ENV -> (:$_, :$PATH, *%) {
        dd $_, $PATH
    }

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Env . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
