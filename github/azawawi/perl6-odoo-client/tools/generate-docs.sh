#!/usr/bin/env perl6

use v6;

say "Generating Markdown documentation...";
shell("perl6 -Ilib --doc=Markdown lib/Odoo/Client.pm6 >doc/Odoo-Client.md");
