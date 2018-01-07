use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::CatalogInventory;
use Magento::Catalog;
use CatalogInventory;
use TestLogin;

my %config = TestLogin::admin_config;
my $simple_product = products %config, data => %( CatalogInventory::simple() );
my $item_id;

subtest {

    # GET    /V1/stockItems/:productSku
    my $t1_results =
        stock-items 
            %config,
            product_sku => 'P6-SIMPLE-0001';
    is $t1_results<is_in_stock>, True, 'stock items all';
    $item_id = $t1_results<item_id>;

}, 'Stock items';

subtest {

    # PUT    /V1/products/:productSku/stockItems/:itemId
    my %t1_data = CatalogInventory::products-stock-items(item_id => $item_id);

    my $t1_results =
        products-stock-items 
            %config,
            product_sku => 'P6-SIMPLE-0001',
            item_id     => $item_id,
            data        => %t1_data;
    is $t1_results ~~ Int, True, 'products stock-items update';

}, 'Products stock-items';


subtest {

    # GET    /V1/stockItems/lowStock/
    my $t1_results =
        stock-items-low-stock %config, scope_id => 0, qty => 100, page_size => 1, current_page => 1;
    is $t1_results<items> ~~ Array, True, 'stock items-low-stock all';

}, 'Stock items-low-stock';

subtest {

    # GET    /V1/stockStatuses/:productSku
    my $t1_results =
        stock-statuses 
            %config,
            product_sku => 'P6-SIMPLE-0001';
    is $t1_results<stock_status>, 1, 'stock statuses all';

}, 'Stock statuses';

done-testing;
