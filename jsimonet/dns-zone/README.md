[![Build Status](https://travis-ci.org/jsimonet/dns-zone.svg?branch=master)](https://travis-ci.org/jsimonet/dns-zone)

# What

A tool providing an easy way to manage a DNS file zone.

# Why

For fun, because similar modules already exists in Perl 5.
I wanted to use Perl 6 to discover the language, and to learn with a concrete
project.

# How

## Grammar

The main part of this project is to write a grammar for parsing a DNS zone file.
As a result, we will obtain an AST "DNSZone" object, representing the content of this
file.

## AST

This object will contains methods to add, update and remove an entry.

The last step is to write a new zone file based on the new AST.
