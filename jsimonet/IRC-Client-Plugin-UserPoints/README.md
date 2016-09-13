# NAME

IRC::Client::Plugin::UserPoints

# SYNOPSIS

```perl6
    use IRC::Client;
    use IRC::Client::Plugin::UserPoints;

    IRC::Client.new(
        :nick<botte>
        :host<irc.freenode.net>
        :channels<#test>
        :plugins( IRC::Client::Plugin::UserPoints.new )
    ).run;
```

```irc
<jsimonet> jsimonet++
<botte> jsimonet, Adding one point to jsimonet in « main » category
<jsimonet> jsimonet++ Perl6
<botte> jsimonet, Adding one point to jsimonet in « Perl6 » category
<jsimonet> !scores
<botte> jsimonet, « jsimonet » has some points : 1 for main
```

# DESCRIPTION

This module is a plugin for `IRC::Client`, which aims to count points delivered to users.

A point can be categorized, for more precision :)

# Attributes

```perl6
    IRC::Client::Plugin::UserPoints.new(
        :db-file-name( 'path/to/file.txt' ),
        :command-prefix( '!' )
    )
```

## db-file-name

The file name of the points database.

## command-prefix

The command prefix is used to determine the char used to trigger the bot.

# IRC COMMANDS

```irc
<nickName>++       # Add a point in "main" category
<nickName>--       # Remove a point in "main" category
<nickName>++ Perl6 # Add a point in "Perl6" category
!scores            # Prints the attributed points
```

# BUGS

To report bugs or request features, please use
https://github.com/jsimonet/IRC-Client-Plugin-UserPoints/issues

# AUTHOR

Julien Simonet
