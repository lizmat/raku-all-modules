
# DESCRIPTION

This distribution installs `rebailador` script that will watch the source
code of your Bailador app for changes and automatically restart the app.

# USAGE

    rebailador bin/your-bailador-app.p6

    rebailador --w=lib,bin,views,public   bin/your-bailador-app.p6

### `--w`

Takes comma-separated list of directories to watch. By default,
will watch `lib` and `bin` directories.

If you have to watch a directory with a comma in its name, prefix it with a backslash:

    rebailador --w=x\\,y bin/app.p6  # watches directory "x,y"

----

# REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Bailador-Dev-AutoRestarter

# BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Bailador-Dev-AutoRestarter/issues

# AUTHOR

Zoffix Znet (http://zoffix.com/)

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
