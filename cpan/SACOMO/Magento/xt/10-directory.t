use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Directory;
use TestLogin;

my %config = TestLogin::admin_config;

subtest {

    # GET    /V1/directory/countries
    my $t1_results = directory-countries %config;
    is $t1_results.grep({$_<three_letter_abbreviation> ~~ 'USA'}).head<id> ~~ 'US', True, 'directory countries all';

    # GET    /V1/directory/countries/:countryId
    my $t2_results =
        directory-countries 
            %config,
            country_id => 'US';
    is $t2_results<two_letter_abbreviation>, 'US', 'directory countries by country id';

}, 'Directory countries';

subtest {

    # GET    /V1/directory/currency
    my $t1_results = directory-currency %config;
    is $t1_results<base_currency_code>, 'USD', 'directory currency all';

}, 'Directory currency';

done-testing;
