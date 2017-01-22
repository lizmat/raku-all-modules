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
<jsimonet> botte++
<botte> jsimonet, Adding one point to botte in « main » category
<jsimonet> botte2++ Perl6
<botte> jsimonet, Adding one point to botte2 in « Perl6 » category
<jsimonet> jsimonet++
<botte> jsimonet, Influencing points of himself is not possible.
<jsimonet> !scores
<botte> jsimonet, « botte » has some points : 1 for main
<botte> jsimonet, « botte2 » has some points : 1 in Perl6
<jsimonet> !sum
<botte> jsimonet, Total points : 2
```

# DESCRIPTION

This module is a plugin for `IRC::Client`, which aims to count points delivered to users.

A point can be categorized, for more precision :)

Points can be listed with the `scores` command, and passing one or more users
will list only theirs points.

A sum can be printed with `sum` command, and like `scores` command, a list of users
can be used.

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
<nickName>++         # Add a point in "main" category
<nickName>--         # Remove a point in "main" category
<nickName>++ Perl6   # Add a point in "Perl6" category
!scores              # Prints the attributed points
!scores <nickName> … # Prints the attributed points
!sum                 # Sum of all attributed points
!sum <nickName> …    # Sum of attributed points for nickName
```

# BUGS

To report bugs or request features, please use
https://github.com/jsimonet/IRC-Client-Plugin-UserPoints/issues

# AUTHOR

Julien Simonet
