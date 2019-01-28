#!/usr/bin/env perl6

use lib <lib>;
use META6;
use OO::Plugin;

my $m = META6.new(
    name           => 'OO::Plugin',
    description    => 'Framework for working with OO application plugins',
    version        => OO::Plugin.^ver,
    perl-version   => Version.new('6.d'),
    depends        => [ <WhereList File::Find> ],
    test-depends   => <Test Test::META Test::When>,
    build-depends  => <META6 p6doc Pod::To::Markdown>,
    tags           => <OO Plugin Plugins>,
    authors        => ['Vadim Belman <vrurg@cpan.org>'],
    auth           => 'github:vrurg',
    source-url     => 'git://github.com/vrurg/Perl6-OO-Plugin.git',
    support        => META6::Support.new(
        source          => 'https://github.com/vrurg/Perl6-OO-Plugin.git',
    ),
    provides => {
        'OO::Plugin'                            => 'lib/OO/Plugin.pm6',
        'OO::Plugin::Manager'                   => 'lib/OO/Plugin/Manager.pm6',
        'OO::Plugin::Class'                     => 'lib/OO/Plugin/Class.pm6',
        'OO::Plugin::Declarations'              => 'lib/OO/Plugin/Declarations.pm6',
        'OO::Plugin::Exception'                 => 'lib/OO/Plugin/Exception.pm6',
        'OO::Plugin::Registry'                  => 'lib/OO/Plugin/Registry.pm6',
        'OO::Plugin::Metamodel::PluginHOW'      => 'lib/OO/Plugin/Metamodel/PluginHOW.pm6',
        'OO::Plugin::Metamodel::PlugRoleHOW'    => 'lib/OO/Plugin/Metamodel/PlugRoleHOW.pm6',
    },
    license        => 'Artistic-2.0',
    production     => False,
);

print $m.to-json;

#my $m = META6.new(file => './META6.json');
#$m<version description> = v0.0.2, 'Work with Perl 6 META files even better';
#spurt('./META6.json', $m.to-json);
