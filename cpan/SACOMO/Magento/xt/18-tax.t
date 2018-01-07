use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Tax;
use TestLogin;

my %config = TestLogin::admin_config;
my $tax_rate_ids;

subtest {

    # POST   /V1/taxClasses
    my %t1_data = %{
        taxClass => %{
            class_name => 'Delete me Tax Class',
            class_type => 'PRODUCT' # PRODUCT, CUSTOMER
        }
    }

    my $t1_results =
        tax-classes 
            %config,
            data => %t1_data;
    is $t1_results ~~ Int, True, 'tax classes new';

    # GET    /V1/taxClasses/:taxClassId
    my $t2_results =
        tax-classes 
            %config,
            tax_class_id => $t1_results;
    is $t2_results<class_name>, 'Delete me Tax Class', 'tax classes by id';

    # PUT    /V1/taxClasses/:classId
    my $t3_results =
        tax-classes 
            %config,
            class_id => $t1_results,
            data     => %t1_data;
    is $t3_results ~~ Int, True, 'tax classes update';

    # DELETE /V1/taxClasses/:taxClassId
    my $t4_results =
        tax-classes-delete 
            %config,
            tax_class_id => $t1_results;
    is $t4_results, True, 'tax classes delete';

}, 'Tax classes';

subtest {

    # GET    /V1/taxClasses/search
    my $t1_results =
        tax-classes-search 
            %config;
    is $t1_results<items>.elems > 0, True, 'tax classes-search all';

}, 'Tax classes-search';

subtest {

    # POST   /V1/taxRates
    my %t1_data = %{
        taxRate => %{
            code           => 'US-CA-Beverly-Hills-Rate',
            rate           => 15,
            region_name    => 'CA',
            tax_country_id => 'US',
            tax_postcode   => '90210',
            tax_region_id   => 12
        }
    }

    my $t1_results =
        tax-rates 
            %config,
            data => %t1_data;
    is $t1_results<code>, 'US-CA-Beverly-Hills-Rate', 'tax rates new';

    # GET    /V1/taxRates/:rateId
    my $t2_results =
        tax-rates 
            %config,
            rate_id => $t1_results<id>;
    is $t2_results<code>, 'US-CA-Beverly-Hills-Rate', 'tax rates by rate id';

    # PUT    /V1/taxRates
    my %t3_data = %{
        taxRate => %{
            id             => $t1_results<id>,
            code           => 'US-CA-Beverly-Hills-Rate',
            rate           => 15,
            region_name    => 'CA',
            tax_country_id => 'US',
            tax_postcode   => '90210',
            tax_region_id   => 12
        }
    }

    my $t3_results =
        tax-rates 
            %config,
            data => %t3_data;
    is $t3_results<code>, 'US-CA-Beverly-Hills-Rate', 'tax rates update';

    # DELETE /V1/taxRates/:rateId
    my $t4_results =
        tax-rates-delete 
            %config,
            rate_id => $t1_results<id>.Int;
    is $t4_results, True, 'tax rates delete';

}, 'Tax rates';

subtest {

    # GET    /V1/taxRates/search
    my $t1_results =
        tax-rates-search 
            %config;
    is $t1_results<items>.elems > 0, True, 'tax rates-search all';
    $tax_rate_ids = gather $t1_results<items>.map({take $_<id>});

}, 'Tax rates-search';

subtest {

    # POST   /V1/taxRules
    my %t1_data = %{
        rule => %{
            code                   => 'RuleDeleteMe',
            calculate_subtotal     => False,
            priority               => 0,
            product_tax_class_ids  => [2],
            customer_tax_class_ids => [3],
            tax_rate_ids           => $tax_rate_ids
        }
    }
            
    my $t1_results =
        tax-rules 
            %config,
            data => %t1_data;
    is $t1_results<code>, 'RuleDeleteMe', 'tax rules new';

    # PUT    /V1/taxRules
    my %t2_data = %{
        rule => %{
            id                     => $t1_results<id>.Int,
            code                   => 'RuleDeleteMe',
            calculate_subtotal     => False,
            priority               => 0,
            product_tax_class_ids  => [2],
            customer_tax_class_ids => [3],
            tax_rate_ids           => $tax_rate_ids
        }
    }
            
    my $t2_results =
        tax-rules 
            %config,
            data => %t2_data;
    is $t2_results<code>, 'RuleDeleteMe', 'tax rules update';

    # GET    /V1/taxRules/:ruleId
    my $t3_results =
        tax-rules 
            %config,
            rule_id => $t1_results<id>.Int;
    is $t3_results<code>, 'RuleDeleteMe', 'tax rules by id';

    # GET    /V1/taxRules/search
    my $t4_results =
        tax-rules-search 
            %config;
    is $t4_results<items>.head<code> ~~ 'RuleDeleteMe', True, 'tax rules-search all';

    # DELETE /V1/taxRules/:ruleId
    my $t5_results =
        tax-rules-delete 
            %config,
            rule_id => $t1_results<id>.Int;
    is $t5_results, True, 'tax rules delete';

}, 'Tax rules';

done-testing;
