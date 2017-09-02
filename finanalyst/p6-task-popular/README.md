# Task::Popular
[Introduction](#introduction)    
[Module Listing](#modules-in-this-distribution)  
[Date of Compilation](#date-of-compilation)  
[Problems](#problems)  
[Updates and Algorithm](#updates-and-algorithm)

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

## Modules in this distribution

| Module Name | Recursive Citation Index | Module Description |
|---| :---: | :--- |
| JSON::Fast | 36.08 | A naive, fast json parser and serializer; drop-in replacement for JSON::Tiny |
| URI | 31.96 | A URI implementation using Perl 6 grammars to implement RFC 3986 BNF |
| MIME::Base64 | 26.46 | Encoding and decoding Base64 ASCII strings |
| File::Directory::Tree | 23.71 | Port of File::Path::Tiny - create and delete directory trees |
| File::Temp | 23.02 | Create temporary files & directories |
| HTTP::Status | 21.65 | Get the text message associated with an HTTP status code |
| JSON::Tiny | 17.18 | A minimal JSON (de)serializer |
| JSON::Name | 16.49 | Provides a trait to store an alternative JSON Name |
| JSON::Unmarshal | 15.46 | Turn JSON into objects |
| JSON::Marshal | 15.12 | Simple serialisation of objects to JSON |
| OpenSSL | 15.12 | OpenSSL bindings |
| Encode | 14.78 | Character encodings in Perl 6 |
| DateTime::Parse | 14.43 | DateTime parser |
| JSON::Class | 14.43 | role to provide simple serialisation/deserialisation of objects to/from JSON |
| HTTP::UserAgent | 14.09 | Web user agent |
| Terminal::ANSIColor | 13.4 | Colorize terminal output |
| META6 | 11.68 | Work with Perl 6 META files |
| Test::META | 11 | Test a distributions META file |
| XML | 11 | A full-featured, pure-perl XML library (parsing, manipulation, emitting, queries, etc.) |
| File::Find | 10.65 | File::Find for Perl 6 |
| Digest | 9.97 | Pure perl6 implementation of digest algorigthms. |
| LibraryMake | 9.28 | An attempt to simplify native compilation |
| IO::Socket::SSL | 8.59 | IO::Socket::SSL for Perl 6 using OpenSSL |
| PSGI | 8.59 | A PSGI helper library. |
| File::Which | 8.25 | Cross platform Perl 6 executable path finder (aka which on UNIX) |
| DateTime::Format | 7.22 | strftime and other DateTime formatting libraries |
| Digest::HMAC | 6.87 | Generic HMAC implementation |
| HTTP::Easy | 6.53 | HTTP servers made easy, including PSGI |
| URI::Encode | 6.53 | Encode and decode URIs according to RFC 3986 |
| JSON::Pretty | 6.19 | A minimal JSON (de)serializer that produces easily readable JSON |

## Date of Compilation

This list was compiled on 2017-09-02.

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
