A fun little REPL for perl6 inspired by Pry, nREPL, and others

## EXAMPLE

Demo program:

    use LREP;

    sub hmm {
      my $x = "hello";
      LREP::here;
      say $x;
    }

    hmm;

Then when you run it you get a prompt. You can look at local vars and change them. "^D" to continue.

    > $x
    hello
    > $x = "bye"
    bye
    > ^D
    bye

## TODO / IDEAS
* Middleware / Plugins
  * Make adding plugins easy. Middleware == Plugins!
  * Make plugins powerful -- build off of each other, declarative help
  * Make everything a plugin
  * Extract middleware into separate files
  * Adopt some middleware-dependency concepts like nREPL has?
* Make (optionally) client/server
* Hook up a next/step debugger
* Steal more from core REPL for tab-complete
* Add handy plugins from Pry
  * ls -- list current context methods, list methods of obj
  * show-source -- show the source code of something
  * show-doc -- show the documentation for something
  * @ / whereami -- show the current surrounding source code
  * help -- help!

