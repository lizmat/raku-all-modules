[![Build Status](https://travis-ci.org/scovit/perl6-IRC-Async.svg)](https://travis-ci.org/scovit/perl6-IRC-Async)

# NAME

IRC::Async - Asynchronous IRC client

# TABLE OF CONTENTS
- [NAME](#name)
- [TABLE OF CONTENTS](#table-of-contents)
- [EXAMPLE](#example)
- [DESCRIPTION](#description)
- [METHODS](#methods)
    - [`new`](#new)
    - [`connect`](#connect)
    - [`Supply`](#supply)
    - [`print`](#print)
    - [`write`](#write)
    - [`close`](#close)
    - [`privmsg`](#privmsg)
- [REPOSITORY](#repository)
- [BUGS](#bugs)
- [AUTHOR](#author)
- [LICENSE](#license)

# EXAMPLE

```perl6
   use IRC::Async;

   my $channel = "#channel";
   my $a = IRC::Async.new(
      :host<127.0.0.1>
      :channels($channel)
   );

   # my $stdinput = $*IN.Supply; Workaround for MoarVM/issues/165
   my $stdinput = {my $insupplier=Supplier.new;use Readline;start {my $rl = Readline.new;while my $msg = $rl.readline("") {$insupplier.emit($msg);}}; $insupplier.Supply; }();

   await $a.connect.then(
       {
          my $chat = .result;
          my $text = $chat.Supply.grep({ $_ ~~ :command("PRIVMSG") });

          react {
             whenever $text -> $e {
                say "{$e<who><nick>}: {$e<params>[1]}";
             }
             whenever $stdinput -> $e {
                if ($e eq "\\quit") {
                   await $chat.print("QUIT :My job is done\n");
                   $chat.close;
                   exit;
                };
                $chat.privmsg($channel, $e);
             }
       }
   });

```

# DESCRIPTION

Get an IRC client up, and interact to it using a totally
asynchronous API inspired from the Socket Async interface.

# METHODS

## new

```perl6
my $irc = IRC::Async.new;
```

```perl6
# Defaults are shown
my $irc = IRC::Async.new(
   debug              => False,
   host               => 'localhost',
   password           => (Str),
   port               => 6667,
   nick               => 'EvilBOT',
   username           => 'EvilBOT',
   userreal           => 'Evil annoying BOT',
   channels           => ['#perl6bot'],
);
```

Creates and returns a new `IRC::Async` objects. All arguments are optional
and self-explanatory.

## connect

```perl6
   method connect returns Promise;
```

Takes no arguments. Attempts to connect to the IRC server, returning a
Promise that will either be kept with a connected `IRC::Async` or
broken if the connection cannot be made.

## Supply

```perl6
   method Supply returns Supply 
```

Returns a `Supply` which can be tapped to obtain the message read from
the connected `IRC::Async` as it arrives. By default the data will be
emitted as an intuitive structured message as parsed by the
`IRC::Parser` grammar installed as a dependency to this module.

## print

```perl6
   method print (Str:D $msg) returns Promise
```

Attempt to send string `$msg` on the `IRC::Async` that will have been
obtained indirectly via connect, returning a Promise that
will be kept with the number of bytes sent or broken if there was an
error sending. Pay attention: IRC command terminates
with newline `"\n"` and print does not add it automagically, this
increase the flexibility; remember to add that character at the end of
every IRC command.

## write

```perl6
   method write (Blob:D $msg) returns Promise
```

Attempt to send binary blob `$msg` on the `IRC::Async` that will have
been obtained indirectly via connect, returning a Promise
that will be kept with the number of bytes sent or broken if there was
an error sending.

## close

```perl6
   method close
```

Close the connection to the server

## privmsg

```perl6
   method privmsg (Str $who, Str $what) returns Promise
```

Calls the method `print` with the following format: `"PRIVMSG $who
:$what\n"`.

# REPOSITORY

Fork this module on GitHub:
https://github.com/scovit/perl6-IRC-Async

# BUGS

To report bugs or request features, please use
https://github.com/scovit/perl6-IRC-Async/issues

# AUTHOR

Vittore F. Scolari (vittore.scolari@pasteur.fr)

Thanks to Zoffix and his
https://github.com/zoffixznet/perl6-IRC-Client for the very clever IRC
grammar.

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.
