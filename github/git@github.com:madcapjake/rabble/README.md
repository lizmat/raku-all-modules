# Rabble

An implementation of a Forth-like language in Perl 6.

## Usage

```
rabble --expression|-e [--debug|-d] <expr>
rabble [--debug|-d] <file>
rabble --repl|-r
```

### Examples
```
\\ Multipy
5 2 * . \\= 10

\\ Dip below last value to apply quotation
5 10 2 [ * ] dip .S \\= [50 2]>

\\ Apply quotation
7 6 [2 3 + + +] apply . \\= 18
```

## Plan

To build a decently well-featured Forth in Perl 6, learn more about Perl 6 and Forth in the process, and explore ideas in all aspects.

### Status

A good chunk of builtins, a REPL, and some tests have been added.  Lots more words to be added but already pretty fun to fiddle with!

### Upcoming

* Add (even) more words
* Implement a return stack
* Debugger
* Documentation

## Credits

Thanks to Michael Fogus's [Read-Eval-Print-λove v003](https://leanpub.com/readevalprintlove003) and [rforth](https://github.com/ananthrk/rforth) for inspiration and guidance in learning Forth and stack-oriented programming.
