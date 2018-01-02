# Task::Popular
[Introduction](#introduction)    
[Module Listing](#modules-in-this-distribution)  
[Date of Compilation](#date-of-compilation)  
[Problems](#problems)  
[Updates and Algorithm](#updates-and-algorithm)

## Introduction

The developers of Perl6 decided that the implementation
of the language (eg. Rakudo) would be available with a bare minimum of "core" modules.
Some modules are essential, such as Test, or the module manager (previously `panda`, currently `zef`).

The intention is for users / user groups to contribute distributions that meet a specific topic area.
Rakudo itself is available in a package called `Rakudo Star` with a minimal number of modules.

This distribution list takes another, data driven, approach.

Modules are intended to provide common functionality, and so are `use`d or **cited** by other modules in the Ecosystem. A set of modules that are
frequently used can be fairly safely assumed will be regularly maintained. Failures in these modules will affect many other modules, and there will be pressure to get them fixed. 

This list uses [Citation Indices](http://finanalyst.github.io/ModuleCitation/) to identify the 30 modules most recursively popular modules in the Ecosystem.

## Modules in this distribution

| Module Name | Recursive Citation Index | Module Description |
|---| :---: | :--- |
| JSON::Fast | 37.87 | OOps description not found, please file issue at github repository of p6-task-popular |
| URI | 31.56 | A URI implementation using Perl 6 grammars to implement RFC 3986 BNF |
| MIME::Base64 | 28.9 | Encoding and decoding Base64 ASCII strings |
| File::Directory::Tree | 26.58 | Port of File::Path::Tiny - create and delete directory trees |
| File::Temp | 25.91 | Create temporary files & directories |
| HTTP::Status | 23.59 | Get the text message associated with an HTTP status code |
| JSON::Tiny | 18.94 | OOps description not found, please file issue at github repository of p6-task-popular |
| OpenSSL | 17.94 | OpenSSL bindings |
| JSON::Name | 16.28 | Provides a trait to store an alternative JSON Name |
| Encode | 15.61 | Character encodings in Perl 6 |
| DateTime::Parse | 15.28 | DateTime parser |
| JSON::Unmarshal | 15.28 | Turn JSON into objects |
| HTTP::UserAgent | 14.95 | Web user agent |
| JSON::Marshal | 14.95 | Simple serialisation of objects to JSON |
| Terminal::ANSIColor | 14.95 | Colorize terminal output |
| JSON::Class | 14.29 | role to provide simple serialisation/deserialisation of objects to/from JSON |
| HTML::Escape | 12.96 | Utility of HTML escaping |
| LibraryMake | 11.96 | An attempt to simplify native compilation |
| META6 | 11.63 | Work with Perl 6 META files |
| File::Find | 11.3 | File::Find for Perl 6 |
| Digest | 10.96 | Pure perl6 implementation of digest algorigthms. |
| XML | 10.63 | A full-featured, pure-perl XML library (parsing, manipulation, emitting, queries, etc.) |
| Test::META | 10.3 | Test a distributions META file |
| IO::Socket::SSL | 9.97 | IO::Socket::SSL for Perl 6 using OpenSSL |
| PSGI | 9.3 | A PSGI helper library. |
| URI::Encode | 8.97 | Encode and decode URIs according to RFC 3986 |
| File::Which | 8.31 | Cross platform Perl 6 executable path finder (aka which on UNIX) |
| Digest::HMAC | 7.97 | Generic HMAC implementation |
| HTTP::Easy | 7.31 | HTTP servers made easy, including PSGI |
| JSON::Pretty | 7.31 | A minimal JSON (de)serializer that produces easily readable JSON |
## Date of Compilation

This list was compiled on 2018-01-01.

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
