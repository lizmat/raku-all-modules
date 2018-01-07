use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Downloadable;
use Magento::Catalog;
use Downloadable;
use TestLogin;

my %config = TestLogin::admin_config;
my $downloadable = products %config, data => %( Downloadable::downloadable() );


subtest {

    # GET    /V1/products/:sku/downloadable-links
    my $t1_results =
        products-downloadable-links 
            %config,
            sku => 'P6-DOWNLOADABLE-0001';
    is so $t1_results.any.grep({$_<link_type> ~~ 'file'}), True, 'products downloadable-links all';

    # POST   /V1/products/:sku/downloadable-links
    my %t2_data = Downloadable::products-downloadable-links();

    my $t2_results =
        products-downloadable-links 
            %config,
            sku  => 'P6-DOWNLOADABLE-0001',
            data => %t2_data;
    is $t2_results ~~ Int, True, 'products downloadable-links new';

    # PUT    /V1/products/:sku/downloadable-links/:id
    my %t3_data = Downloadable::products-downloadable-links();

    my $t3_results =
        products-downloadable-links 
            %config,
            sku  => 'P6-DOWNLOADABLE-0001',
            id   => $t2_results.Int,
            data => %t3_data;
    is $t3_results ~~ Int, True, 'products downloadable-links update';

    # DELETE /V1/products/downloadable-links/:id
    my $t4_results =
        products-downloadable-links-delete 
            %config,
            id => $t2_results;
    is $t4_results, True, 'products downloadable-links delete';

}, 'Products downloadable-links';

subtest {

    # GET    /V1/products/:sku/downloadable-links/samples
    my $t1_results =
        products-downloadable-links-samples 
            %config,
            sku => 'P6-DOWNLOADABLE-0001';
    is $t1_results.head<sample_type> ~~ 'url', True, 'products downloadable-links-samples all';

    # POST   /V4/products/:sku/downloadable-links/samples
    my %t2_data = Downloadable::products-downloadable-links-samples();

    my $t2_results =
        products-downloadable-links-samples 
            %config,
            sku  => 'P6-DOWNLOADABLE-0001',
            data => %t2_data;
    is $t2_results ~~ Int, True, 'products downloadable-links-samples new';

    # PUT    /V1/products/:sku/downloadable-links/samples/:id
    my %t3_data = Downloadable::products-downloadable-links-samples();

    my $t3_results =
        products-downloadable-links-samples 
            %config,
            sku  => 'P6-DOWNLOADABLE-0001',
            id   => $t2_results.Int,
            data => %t3_data;
    is $t3_results ~~ Int, True, 'products downloadable-links-samples update';

    # DELETE /V1/products/downloadable-links/samples/:id
    my $t4_results =
        products-downloadable-links-samples-delete 
            %config,
            id => $t2_results.Int;
    is $t3_results ~~ Int, True, 'products downloadable-links-samples delete';

}, 'Products downloadable-links-samples';

# Cleanup
products-delete %config, sku => 'P6-DOWNLOADABLE-0001';

done-testing;
