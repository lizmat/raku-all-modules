# NAME

Bailador::Plugin::AssetPack::SASS - automatically serve static files

# SYNOPSIS

```perl6
use Bailador;
use Bailador::Plugin::AssetPack::SASS;

Bailador::Plugin::AssetPack::SASS.install;

```

# DESCRIPTION

This module lets you transparently use [SASS](http://sass-lang.com/) by
handling `SASS -> CSS` conversion automatically.

# NON-PERL 6 RESOURCES

This module requires the presence of `sass` command line utility. See
http://sass-lang.com/install

# METHODS

## `.install`

```perl6
    Bailador::Plugin::AssetPack::SASS.install;
```

Starts `sass` watcher and creates a route for delivering CSS files from
`/assets/sass/*` URL, where the filename (and directory structure) from
`assets/sass` directory is preserved, except you'd refer to the file by
its `.css` extension. Attempting to access files with other extensions will
result in 404s.

NOTE: if you're also using
[Bailador::Plugin::Static](http://modules.perl6.org/dist/Bailador::Plugin::Static),
be sure to include it AFTER `::AssetPack::SASS` or it'll shadow the created route:

```perl6
    Bailador::Plugin::AssetPack::SASS.install;
    Bailador::Plugin::Static.install;
```

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Bailador-Plugin-AssetPack-SASS

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Bailador-Plugin-AssetPack-SASS/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
