# NAME

Bailador::Plugin::Static - automatically serve static files

# SYNOPSIS

```perl6
use Bailador;
use Bailador::Plugin::Static;

Bailador::Plugin::Static.install: app; # set up the route

```

# ALTERNATIVE

NOTE: Bailador now includes `Bailador::Route::StaticFile` in core that offers
more configuration than this module.

# DESCRIPTION

This module sets up a route to automatically serve static
files from `/assets/*` URL, where the file will served
from the `assets/` directory relative to the current
working directory.

The content type will be automatically detected from
file's extension.

# METHODS

## `.install`

```perl6
use Bailador::Plugin::Static;

Bailador::Plugin::Static.install: $app;
```

Takes one argument: your `Bailador::App` object;

Sets up the Bailador route that handles static files. If you need extra
functionality at your `/assets/*` path, declare routes for it *before* calling
`.install`. The route declared by this plugin is:

```perl6
    get rx{ ^ '/assets/' (.+) } => sub { ... }
```

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Bailador-Plugin-Static

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Bailador-Plugin-Static/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
