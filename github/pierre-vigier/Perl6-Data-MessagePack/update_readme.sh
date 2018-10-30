#!/bin/sh

echo "Generating README.md"

echo "# Perl6-Data-MessagePack\n\n[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Data-MessagePack.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Data-MessagePack)\n" >README.md

perl6 -Ilib --doc=Markdown lib/Data/MessagePack.pm6 >>README.md
