use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Bundle;
use Magento::Catalog;
use Bundle;
use TestLogin;

my %config = TestLogin::admin_config;
my $simple_product  = products %config, data => %( Bundle::simple() );
my $simple_product2 = products %config, data => %( Bundle::simple sku => 'P6-SIMPLE-0002' );
my $bundle_product  = products %config, data => %( Bundle::bundle() );
my Int $option_id;

subtest {

    # GET    /V1/bundle-products/:productSku/children
    my $t1_results =
        bundle-products-children 
            %config,
            product_sku => 'P6-BUNDLE-0001';
    is $t1_results.head<sku>, 'P6-SIMPLE-0001', 'bundle products-children all';

}, 'Bundle products-children';

subtest {

    # GET    /V1/bundle-products/:sku/options/all
    my $t1_results =
        bundle-products-options-all 
            %config,
            sku => 'P6-BUNDLE-0001';
    is $t1_results.head<product_links>.head<sku>, 'P6-SIMPLE-0001', 'bundle products-options-all all';
    $option_id = $t1_results.head<option_id>.Int;

}, 'Bundle products-options-all';

subtest {

    # POST   /V1/bundle-products/:sku/links/:optionId
    my %t1_data = Bundle::bundle-products-links();

    my $t1_results =
        bundle-products-links 
            %config,
            sku       => 'P6-BUNDLE-0001',
            option_id => $option_id,
            data      => %t1_data;
    is $t1_results ~~ Int, True, 'bundle products-links new';

    # PUT    /V1/bundle-products/:sku/links/:id
    my %t2_data = Bundle::bundle-products-links();

    my $t2_results =
        bundle-products-links 
            %config,
            sku  => 'P6-BUNDLE-0001',
            id   => $t1_results,
            data => %t2_data;
    is $t2_results, True, 'bundle products-links update';

}, 'Bundle products-links';
#
subtest {

    # GET    /V1/bundle-products/:sku/options/:optionId
    my $t1_results =
        bundle-products-options 
            %config,
            sku       => 'P6-BUNDLE-0001',
            option_id => $option_id;
    is $t1_results.head<product_links>.head<sku>, 'P6-SIMPLE-0001', 'bundle products-options by option id';

    # PUT    /V1/bundle-products/options/:optionId
    my %t2_data = Bundle::bundle-products-options();

    my $t2_results =
        bundle-products-options 
            %config,
            option_id => $option_id,
            data      => %t2_data;
    is $t2_results ~~ Int, True, 'bundle products-options update';

}, 'Bundle products-options';

subtest {

    # POST   /V1/bundle-products/options/add
    my %t1_data = Bundle::bundle-products-options();

    my $t1_results =
        bundle-products-options-add 
            %config,
            data => %t1_data;
    is $t1_results ~~ Int, True, 'bundle products-options-add new';

}, 'Bundle products-options-add';

subtest {

    # GET    /V1/bundle-products/options/types
    my $t1_results = bundle-products-options-types %config;
    is so $t1_results.any.grep({$_<code> ~~ 'radio'}), True, 'bundle products-options-types all';

}, 'Bundle products-options-types';

subtest {

    # DELETE /V1/bundle-products/:sku/options/:optionId/children/:childSku
    my $t1_results =
        bundle-products-options-children-delete 
            %config,
            sku => 'P6-BUNDLE-0001',
            option_id => $option_id,
            child_sku => 'P6-SIMPLE-0002';
    is $t1_results, True, 'bundle products-options-children delete';

    # DELETE /V1/bundle-products/:sku/options/:optionId
    my $t2_results =
        bundle-products-options-delete 
            %config,
            sku       => 'P6-BUNDLE-0001',
            option_id => $option_id;
    is $t2_results, True, 'bundle products-options delete';

    for ['P6-BUNDLE-0001', 'P6-SIMPLE-0001', 'P6-SIMPLE-0002'] {
        products-delete %config, sku => $_
    }

}, 'Cleanup';

done-testing;
