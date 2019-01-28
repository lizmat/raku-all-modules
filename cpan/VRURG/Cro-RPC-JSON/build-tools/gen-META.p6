#!/usr/bin/env perl6

use lib <lib>;
use META6;
use Cro::RPC::JSON::VER;

my $m = META6.new(
    name           => 'Cro::RPC::JSON',
    description    => 'Cro JSON-RPC implementation',
    version        => Cro::RPC::JSON::VER.^ver,
    perl-version   => Version.new('6.*'),
    depends        => <
        Cro::HTTP
        JSON::Fast
    >,
    test-depends   => <Test Test::META Test::When Cro::HTTP::Test>,
    #build-depends  => <META6 p6doc Pod::To::Markdown>,
    tags           => <Cro JSON-RPC>,
    authors        => ['Vadim Belman <vrurg@cpan.org>'],
    auth           => 'github:vrurg',
    source-url     => 'git://github.com/vrurg/Perl6-Cro-RPC-JSON.git',
    support        => META6::Support.new(
        source          => 'https://github.com/vrurg/Perl6-Cro-RPC-JSON.git',
    ),
    provides => {
        'Cro::RPC::JSON' => 'lib/Cro/RPC/JSON.pm6',
        'Cro::RPC::JSON::Exception' => 'lib/Cro/RPC/JSON/Exception.pm6',
        'Cro::RPC::JSON::Handler' => 'lib/Cro/RPC/JSON/Handler.pm6',
        'Cro::RPC::JSON::Message' => 'lib/Cro/RPC/JSON/Message.pm6',
        'Cro::RPC::JSON::RequestParser' => 'lib/Cro/RPC/JSON/RequestParser.pm6',
        'Cro::RPC::JSON::ResponseSerializer' => 'lib/Cro/RPC/JSON/ResponseSerializer.pm6',
    },
    license        => 'Artistic-2.0',
    production     => False,
);

print $m.to-json;

#my $m = META6.new(file => './META6.json');
#$m<version description> = v0.0.2, 'Work with Perl 6 META files even better';
#spurt('./META6.json', $m.to-json);

