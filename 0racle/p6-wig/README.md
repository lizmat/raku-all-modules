# wig ( where is grep ) 

Make grep prettier, put a wig on it!

{\[: )

## Synopsis

```perl6
use wig;

my @even = @numbers.where(* %% 2);

my @matches = @data.where(/pattern/);

my @prod_servers = @servers.where(*.status eq 'Production');

my @jpgs = %*ENV<HOME>.IO.dir.where: *.basename.ends-with( '.jpg' | '.jpeg' );
```

## Description

This module adds a new method (and function) called `where` that is essentially an 'alias' for `grep`.

The term `grep` is kind of a misnomer, and unfamiliar to a lot of people. Using `where` allows you to filter items in a way that reads much more like English, particularly when used in the method form.

This idea was originally a [language proposal](https://gist.github.com/0racle/ea0523759e2da15758d4) and my hope is that it makes its way into the language proper.

## Celebrity Endorsements

_I like the idea of "where" instead of "grep"_ - [lizmat](http://irclog.perlgeek.de/perl6/2016-03-30#i_12262416)

## Limitations / Issues

Rakudo currently has a cache invalidation issue where child classes don't automatically inherit augmented methods from a Parent class (in this case, the Any class).

Until this is fixed, the work around is is to call `.^compose` on your desired child classes. I haven't called it on _every_ class under Any (there's a lot!), just the ones `grep` is used with commonly. 

If a class hasn't been recomposed and you try to call `where` on it, Rakudo will report the error `Method 'where' not found for invocant of class 'ClassName'`.

As a quickfix, just call `ClassName.^compose;` after `use wig;`. Alternatively you can modify the module source.

If you think I've missed a very important class that I shouldn't have, please let me know (Issues | Submit a PR | irc://freenode, #perl6, user: perlawhirl).

## License

Artistic. Refer to the LICENSE file in the distribution.

