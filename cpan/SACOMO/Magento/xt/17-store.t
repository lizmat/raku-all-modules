use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Store;
use TestLogin;

my %config = TestLogin::admin_config;

subtest {

    # GET    /V1/store/storeConfigs
    my $t1_results =
        store-store-configs %config;
    is so $t1_results.grep({$_<base_currency_code> ~~ 'USD'}), True, 'store store-configs all';

}, 'Store store-configs';

subtest {

    # GET    /V1/store/storeGroups
    my $t1_results =
        store-store-groups %config;
    is so $t1_results.grep({$_<code> ~~ 'default'}), True, 'store store-groups all';

}, 'Store store-groups';

subtest {

    # GET    /V1/store/storeViews
    my $t1_results =
        store-store-views %config;
    is so $t1_results.grep({$_<code> ~~ 'default'}), True, 'store store-views all';

}, 'Store store-views';

subtest {

    # GET    /V1/store/websites
    my $t1_results =
        store-websites %config;
    is so $t1_results.grep({$_<code> ~~ 'base'}), True, 'store websites all';

}, 'Store websites';

done-testing;
