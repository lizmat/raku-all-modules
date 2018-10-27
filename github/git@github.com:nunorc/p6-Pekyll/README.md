
# Pekyll

A very simple tool to generate static websites from sources in different
formats, inspired by [Hakyll](http://jaspervdj.be/hakyll/), written
in [Perl 6](http://perl6.org/).

**Under heavy development, things will change.. you have been warned!**

## Synopsis

The basic idea is to define a *router* and a *compiler* for sets of files.
The *router* is used to define how the final destination of the file is
built from the original file path. And the *compiler* is used to build the final
HTML from the source file. There are some previously defined routers and
compilers available.

```
use Pekyll;
use Pekyll::Routers;
use Pekyll::Compilers;

my %rules = (
    'assets/*' => { router=>&router_id, compiler=>&plain_copy },
    'static/*' => { router=>&ext2html,  compiler=>&compile_static },
    '_end'     => &wrap_up,
  );

my $pekyll = Pekyll.new(:%rules);
$pekyll.build('src', 'dist');

sub compile_static($src, $target) { ...  }
sub wrap_up($dst) { ... }
```

In a nutshell this reads for every file in source directory `assets` use
the `router_id` function to build the final path for the file (the same in
this case), and the `plain_copy` function to build the final file.

The special `_end` rule is executed once (in the end), useful for generating
feeds, or special page.

## Example

For a more complex example visit this [repository](http://github.com/APPP/perl.pt).

