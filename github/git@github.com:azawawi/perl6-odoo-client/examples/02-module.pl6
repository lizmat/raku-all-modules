#!/usr/bin/env perl6

use v6;
use lib 'lib';

use Odoo::Client;

# Create a new odoo JSON-RPC client
my $odoo = Odoo::Client.new(
    hostname => "localhost",
    port     => 8069
);

# Login to odoo
my $uid = $odoo.login(
    database => "sample", 
    username => 'user@example.com',
    password => "123"
);


sub install-modules(@modules-to-install) {
    my $module = $odoo.model('ir.module.module');
    for @modules-to-install -> $module-name {
        my $module-ids = $module.search([
            ['name',  '=',      $module-name ],
            ['state', 'not in', ['installed', 'to upgrade']]
        ]);
        if $module-ids {
            say "Installing $module-name";
            my $result = $module.button-immediate-install($module-ids);
            say $result.perl;
        }
    }
}

install-modules([
    'sale',
    'crm'
]);
