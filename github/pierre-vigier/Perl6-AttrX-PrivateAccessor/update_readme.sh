#!/bin/sh

echo "Generating README.md"

echo "# Perl6-AttrX::PrivateAccessor\n\n[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-AttrX-PrivateAccessor)\n" >README.md

perl6 --doc=Markdown lib/AttrX/PrivateAccessor.pm6 >>README.md

