#!/bin/sh

echo "Generating README.md"

echo "# Perl6-AttrX::Lazy\n\n[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-AttrX-Lazy.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-AttrX-Lazy)\n" >README.md

perl6 --doc=Markdown lib/AttrX/Lazy.pm6 >>README.md

