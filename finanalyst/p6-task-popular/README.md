# Task::Popular
[Introduction](#introduction)  
[Problems](#problems)  
[Updates and Algorithm](#updates-and-algorithm)  
[Module Listing](#modules-in-this-distribution)

## Introduction

The developers of Perl6 decided early on that the implementation
of the language (eg. Rakudo) would be available with a bare minimum of "core" modules.
Some modules are essential, such as Test, or the module manager (previously `panda`, currently `zef`).

The intention is for users / user groups to contribute distributions that meet a specific topic area.
Rakudo is available in a package called `Rakudo Star` with a minimal number of modules.

However, for someone coming to Perl6 for the first time, there is a natural question as to which
modules 'should' be installed first to provide the dependencies most other modules will need.
Since 'should' can be quite subjective, and space is a limited resource, there no solution for newcomers has yet been agreed.

Another problem (at the time of writing) is that Perl6 has a rapidly expanding Ecosystem (available modules),
whilst the language itself
continues to evolve. This means that modules which were well-tested and useful at one moment in time are being
replaced by other modules or get out of date. Consequently, any list of 'necessary' modules has to
be monitored on a regular basis.

This distribution list takes another, data driven, approach.

Some modules provide common functionality, and so are `use`d or **cited** by other modules in the Ecosystem.
Consequently, by chosing a set of modules that are
frequently used, it can be fairly safely assumed they will be regularly maintained. Failures in these modules will affect other modules.

This list uses [Citation Indices](http://finanalyst.github.io/ModuleCitation/) to identify the 30 modules most recursively popular modules in the Ecosystem.

## Problems

Inevitably for commonly needed functionality, there may be multiple modules that provide the same functionality.
An example is JSON::Tiny and JSON::Fast. J/Fast was designed to be a drop-in replacement for J/Tiny, which
was first written to demonstrate how to use Perl6 and not as a workhorse module. However, for some reason J/Tiny
has a lot of support, although J/Fast is taking over (see the  ModuleCitation page to trace the historical change).

So the Task::Popular list may have alternate modules for the same functionality. But for a newcomer to the Ecosystem
that might in fact be interesting as it provides a choice, and the opportunity to compare coding styles.

## Updates and Algorithm

The aim is to update the list regularly (eg. monthly).

The algorithm for generating the distribution list is implemented as a method in the [ModuleCitation class](https://github.com/finanalyst/ModuleCitation).

## Modules in this distribution

| Module Name | Recursive Citation Index | Module Description |
|---| :---: | :--- |
| JSON::Fast | 32.69 | A naive, fast json parser and serializer; drop-in replacement for JSON::Tiny |
| MIME::Base64 | 25 | Encoding and decoding Base64 ASCII strings |
| File::Directory::Tree | 23.46 | Port of File::Path::Tiny - create and delete directory trees |
| File::Temp | 23.08 | Create temporary files & directories |
| URI | 21.54 | A URI implementation using Perl 6 grammars to implement RFC 3986 BNF |
| HTTP::Status | 20.38 | Get the text message associated with an HTTP status code |
| JSON::Tiny | 18.08 | A minimal JSON (de)serializer |
| JSON::Name | 13.85 | Provides a trait to store an alternative JSON Name |
| Encode | 13.46 | Character encodings in Perl 6 |
| DateTime::Parse | 13.08 | DateTime parser |
| HTTP::UserAgent | 12.69 | Web user agent |
| JSON::Unmarshal | 12.69 | Turn JSON into objects |
| JSON::Marshal | 12.31 | Simple serialisation of objects to JSON |
| JSON::Class | 11.54 | role to provide simple serialisation/deserialisation of objects to/from JSON |
| XML | 11.54 | A full-featured, pure-perl XML library (parsing, manipulation, emitting, queries, etc.) |
| OpenSSL | 11.15 | OpenSSL bindings |
| Terminal::ANSIColor | 11.15 | Colorize terminal output |
| Digest | 9.62 | Pure perl6 implementation of digest algorigthms. |
| META6 | 8.85 | Work with Perl 6 META files |
| PSGI | 8.85 | A PSGI helper library. |
| Test::META | 8.08 | Test a distributions META file |
| File::Find | 7.69 | File::Find for Perl 6 |
| IO::Socket::SSL | 7.69 | IO::Socket::SSL for Perl 6 using OpenSSL |
| DateTime::Format | 7.31 | strftime and other DateTime formatting libraries |
| File::Which | 7.31 | Cross platform Perl 6 executable path finder (aka which on UNIX) |
| LibraryMake | 7.31 | An attempt to simplify native compilation |
| HTTP::Easy | 6.54 | HTTP servers made easy, including PSGI |
| Digest::HMAC | 6.15 | Generic HMAC implementation |
| JSON::Pretty | 6.15 | A minimal JSON (de)serializer that produces easily readable JSON |
| LWP::Simple | 6.15 | LWP::Simple quick & dirty implementation for Rakudo Perl 6 |