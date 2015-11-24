#!/usr/bin/env perl6 

use lib 'lib';

use META6;

my $m = META6.new(   name        => 'META6',
                     description => 'Work with Perl 6 META files',
                     version     => Version.new('0.0.1'),
                     perl        => Version.new('6'),
                     depends     => <JSON::Class>,
                     test-depends   => <Test>,
                     tags        => <devel meta utils>,
                     authors     => ['Jonathan Stowe <jns+git@gellyfish.co.uk>'],
                     auth        => 'github:jonathanstowe',
                     source-url  => 'git://github.com/jonathanstowe/META6.git',
                     support     => META6::Support.new(
                        source => 'git://github.com/jonathanstowe/META6.git'
                     ),
                     provides => {
                        META6 => 'lib/META6.pm',
                     },
                     license     => 'Artistic',
                     production  => False,

                 );

print $m.to-json;

# vim: expandtab shiftwidth=4 ft=perl6

