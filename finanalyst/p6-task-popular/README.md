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
| JSON::Fast | 33.2 | A naive, fast json parser and serializer; drop-in replacement for JSON::Tiny |
| MIME::Base64 | 26.25 | Encoding and decoding Base64 ASCII strings |
| File::Directory::Tree | 25.48 | Port of File::Path::Tiny - create and delete directory trees |
| File::Temp | 24.71 | Create temporary files & directories |
| HTTP::Status | 22.01 | Get the text message associated with an HTTP status code |
| URI | 22.01 | A URI implementation using Perl 6 grammars to implement RFC 3986 BNF |
| JSON::Tiny | 18.53 | A minimal JSON (de)serializer |
| Encode | 14.67 | Character encodings in Perl 6 |
| DateTime::Parse | 14.29 | DateTime parser |
| JSON::Name | 14.29 | Provides a trait to store an alternative JSON Name |
| HTTP::UserAgent | 13.9 | Web user agent |
| JSON::Unmarshal | 13.13 | Turn JSON into objects |
| JSON::Marshal | 12.74 | Simple serialisation of objects to JSON |
| JSON::Class | 11.97 | role to provide simple serialisation/deserialisation of objects to/from JSON |
| Terminal::ANSIColor | 11.97 | Colorize terminal output |
| XML | 11.97 | A full-featured, pure-perl XML library (parsing, manipulation, emitting, queries, etc.) |
| OpenSSL | 11.58 | OpenSSL bindings |
| Digest | 10.04 | Pure perl6 implementation of digest algorigthms. |
| File::Find | 9.65 | File::Find for Perl 6 |
| META6 | 9.27 | Work with Perl 6 META files |
| PSGI | 9.27 | A PSGI helper library. |
| Test::META | 8.49 | Test a distributions META file |
| File::Which | 8.11 | Cross platform Perl 6 executable path finder (aka which on UNIX) |
| IO::Socket::SSL | 8.11 | IO::Socket::SSL for Perl 6 using OpenSSL |
| DateTime::Format | 7.72 | strftime and other DateTime formatting libraries |
| LibraryMake | 7.72 | An attempt to simplify native compilation |
| HTTP::Easy | 6.95 | HTTP servers made easy, including PSGI |
| Digest::HMAC | 6.56 | Generic HMAC implementation |
| JSON::Pretty | 6.56 | A minimal JSON (de)serializer that produces easily readable JSON |
| URI::Encode | 6.18 | Encode and decode URIs according to RFC 3986 |

## Date of Compilation

This list was compiled on 2017-07-03.

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
