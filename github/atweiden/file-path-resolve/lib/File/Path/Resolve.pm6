use v6;
unit class File::Path::Resolve;

# p6doc {{{

=begin pod
=head NAME

File::Path::Resolve

=head METHODS

=head2 C<absolute($path)>

Method C<absolute> runs C<IO.resolve> on paths to produce absolute paths
after expanding leading C<~/> to C<$*HOME>.

Rakudo considers paths starting with a C<~/> to be relative paths:

    '~'.IO.is-relative.so       # True
    '~/'.IO.is-relative.so      # True
    '~/hello'.IO.is-relative.so # True

This method expands the leading C<~/> to C<$*HOME>. Thus, it does not
consider paths beginning with C<~/> to be relative paths.

=head2 C<relative($path, $base)>

Method C<relative> resolves a path (C<$path>) relative to the base
directory of a file (C<$base>).

This method is intended for config files which allow users to specify
relative paths. When relative paths are given in a config file, these
relative paths should be resolved I<relative to the config file's base
directory> for DWIM.

Like method C<absolute>, method C<relative> expands leading C<~/>s to
C<$*HOME>. Thus, it does not consider paths beginning with C<~/> to be
relative paths.
=end pod

# end p6doc }}}

# token home {{{

my token home           { ^'~'$ }
my token home-path      { ^'~''/'+$ }
my token home-path-plus { ^'~/'.+$ }

# end token home }}}

# method absolute {{{

method absolute(Str:D $path where .so --> IO::Path:D)
{
    my IO::Path:D $resolve = absolute($path);
}

multi sub absolute(Str:D $path where &home --> IO::Path:D)
{
    my IO::Path:D $resolve = $*HOME;
}

multi sub absolute(Str:D $path where &home-path --> IO::Path:D)
{
    my IO::Path:D $resolve = $*HOME;
}

multi sub absolute(Str:D $path where &home-path-plus --> IO::Path:D)
{
    my Str:D $subst = sprintf(Q{%s/}, $*HOME);
    my IO::Path:D $resolve = $path.subst(/^'~''/'+/, $subst).IO.resolve;
}

multi sub absolute(Str:D $path --> IO::Path:D)
{
    my IO::Path:D $resolve = $path.IO.resolve;
}

# end method absolute }}}
# method relative {{{

method relative(Str:D $path, Str:D $base --> IO::Path:D)
{
    my IO::Path:D $resolve = relative($path, $base);
}

multi sub relative(Str:D $path where &home, Str:D $ --> IO::Path:D)
{
    my IO::Path:D $resolve = $*HOME;
}

multi sub relative(Str:D $path where &home-path, Str:D $ --> IO::Path:D)
{
    my IO::Path:D $resolve = $*HOME;
}

multi sub relative(Str:D $path where &home-path-plus, Str:D $ --> IO::Path:D)
{
    my IO::Path:D $resolve = absolute($path);
}

multi sub relative(Str:D $path where .IO.is-relative, Str:D $base --> IO::Path:D)
{
    my Str:D $relative = join('/', $base.IO.dirname, $path);
    my IO::Path:D $resolve = absolute($relative);
}

multi sub relative(Str:D $path, Str:D $ --> IO::Path:D)
{
    my IO::Path:D $resolve = absolute($path);
}

# end method relative }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
