#!/usr/bin/env sh
PERL6LIB=lib pod-render.pl6 --md ./lib/Git/Log.pm6
mv Log.md README.md
