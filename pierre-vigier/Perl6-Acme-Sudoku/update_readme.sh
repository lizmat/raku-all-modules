#!/bin/sh

echo "Generating README.md"

#echo "# Perl6-Acme::Sudoku\n\n[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Acme-Sudoku.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Acme-Sudoku)\n" >README.md

perl6 --doc=Markdown lib/Acme/Sudoku.pm6 >>README.md

