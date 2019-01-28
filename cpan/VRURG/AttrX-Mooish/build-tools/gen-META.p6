#!/usr/bin/env perl6

use lib <lib>;
use META6;
use AttrX::Mooish;

my $m = META6.new(
    name           => 'AttrX::Mooish',
    description    => 'Extending attribute functionality with ideas from Moo/Moose',
    version        => AttrX::Mooish.^ver,
    perl-version   => Version.new('6.*'),
    #depends        => <JSON::Class>,
    test-depends   => <Test Test::META Test::When>,
    #build-depends  => <META6 p6doc Pod::To::Markdown>,
    tags           => <AttrX Moo Moose Mooish attribute mooish trait>,
    authors        => ['Vadim Belman <vrurg@cpan.org>'],
    auth           => 'github:vrurg',
    source-url     => 'git://github.com/vrurg/Perl6-AttrX-Mooish.git',
    support        => META6::Support.new(
        source          => 'git://github.com/vrurg/Perl6-AttrX-Mooish.git',
    ),
    provides => {
        'AttrX::Mooish' => 'lib/AttrX/Mooish.pm6',
    },
    license        => 'Artistic-2.0',
    production     => False,
);

print $m.to-json;

#my $m = META6.new(file => './META6.json');
#$m<version description> = v0.0.2, 'Work with Perl 6 META files even better';
#spurt('./META6.json', $m.to-json);

