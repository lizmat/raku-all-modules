use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Backend;
use TestLogin;

my %config = TestLogin::admin_config;

subtest {

    # GET    /V1/modules
    my @t1_results = modules %config;
    is @t1_results (cont) 'Magento_Store', True, 'modules all';

}, 'Modules';

done-testing;
