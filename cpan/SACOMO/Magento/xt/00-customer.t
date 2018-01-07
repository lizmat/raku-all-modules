use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

my $customer_email = 'p6magento@fakeemail.com';
my $customer_pass  = 'fakeMagent0P6';

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Customer;
use Magento::Store;
use TestLogin;

my %config = TestLogin::admin_config;

subtest {

    my %t1_data = group => %{ 
        code          => 'TestCustomerGroup',
        taxClassId    => 3,
        taxClassName  => 'Retail Customer'
    }
  
    # Customer Groups New
    my %t1_results = customer-groups %config, data => %t1_data;
    is %t1_results<code>, 'TestCustomerGroup', 'customer groups new [code]';
    is %t1_results<tax_class_id>, 3, 'customer groups new [tax_class_id]';
    is %t1_results<tax_class_name>, 'Retail Customer', 'customer groups new [tax_class_name]';
    my $t1_customer_group_id = %t1_results<id>;

    # Customer Group by ID
    my %t2_results = customer-groups %config, id => $t1_customer_group_id;
    is %t2_results<code>, 'TestCustomerGroup', 'customer groups by id [code]';
    is %t2_results<tax_class_id>, 3, 'customer groups by id [tax_class_id]';
    is %t2_results<tax_class_name>, 'Retail Customer', 'customer groups by id [tax_class_name]';

    # Customer Group store default
    my %t3_results = customer-groups-default %config, store_id => 1;
    is %t3_results<code>, 'General', 'customer groups store default [code]';
    is %t3_results<tax_class_id>, 3, 'customer groups store default [tax_class_id]';
    is %t3_results<tax_class_name>, 'Retail Customer', 'customer groups store default [tax_class_name]';

    my %t4_data = group => %{ 
        code => 'TestCustomerGroupModded',
        taxClassId    => 3,
        taxClassName  => 'Retail Customer'
    }

    # Customer Groups update 
    my %t4_results = customer-groups %config, id => $t1_customer_group_id, data => %t4_data;
    is %t4_results<code>, 'TestCustomerGroupModded', 'customer groups update [code]';

    my %t5_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'code',
                            value => '%TestCustomerGroup%',
                            condition_type =>  'like'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }
    # Customer Groups search
    my %t5_results = customer-groups-search %config, search_criteria => %t5_search_criteria;
    is %t5_results<items>.head<code>, 'TestCustomerGroupModded', 'customer groups search [code]';

    # Customer Group Delete
    my $fin_results = customer-groups-delete %config, id => $t1_customer_group_id;
    is $fin_results, True, 'customer groups delete';

}, 'Customer groups';

subtest {

    # Customer Metadata all
    my $t1_results = customer-metadata %config;
    is so $t1_results.any.grep({$_<attribute_code> ~~ 'website_id'}), True, 'customer metadata all';

    # Customer Metadata attribute
    my %t2_results = customer-metadata-attribute %config, attribute_code => 'website_id';
    is %t2_results<frontend_label>, 'Associate to Website', 'customer metadata attribute';

    # Customer Metadata form
    my $t3_results = customer-metadata-form %config, form_code => 'adminhtml_customer';
    is so $t3_results.any.grep({$_<attribute_code> ~~ 'created_at'}), True, 'customer metadata form';

    # Customer Metadata custom
    my $t4_results = customer-metadata-custom %config;
    is $t4_results, False, 'customer metadata custom';

    # Customer Metadata address attribute
    my %t5_results = customer-address-attribute %config, attribute_code => 'postcode';
    is %t5_results<store_label>, 'Zip/Postal Code', 'customer metadata address attribute';

    # Customer Metadata address form
    my $t6_results = customer-address-form %config, form_code => 'customer_register_address';
    is so $t6_results.any.grep({$_<frontend_label> ~~ 'Name Prefix'}), True, 'customer metadata address form';

    # Customer Metadata address
    my $t7_results = customer-address %config;
    is so $t7_results.any.grep({$_<frontend_label> ~~ 'Name Prefix'}), True, 'customer metadata address';

    # Customer Metadata address custom
    my $t8_results = customer-address-custom %config;
    is $t8_results, False, 'customer metadata address custom';


}, 'Customer metadata';

subtest {

    my %t1_data = %{
        customer  => %{
            email      => 'camelia@p6magentofakemail.com',
            firstname  => 'Camelia',
            lastname   => 'Butterfly',
            middlename => 'Perl 6',
            addresses => [
                %{
                    firstname       => 'Camelia',
                    lastname        => 'Butterfly',
                    postcode        => '90210',
                    city            => 'Beverly Hills',
                    street          => ['Zoe Ave'],
                    regionId        => 12,
                    countryId       => 'US',
                    telephone       => '555-555-5555',
                    defaultShipping => 'true',
                    defaultBilling  => 'true'
                },
            ]
        },
    }

    # Customer new
    my %t1_results = customers %config, data => %t1_data;
    is %t1_results<firstname>, 'Camelia', 'customer new [firstname]';
    is %t1_results<lastname>, 'Butterfly', 'customer new [lastname]';
    is %t1_results<created_in>, 'Default Store View', 'customer new [created_in]';
    my $t1_customer_id = %t1_results<id>;
    my $t1_address_id  = %t1_results<addresses>.head<id>;

    my %t2_data = %{
        customer => %{
            email      => 'camelia1@p6magentofakemail.com',
            firstname  => 'Camelia',
            lastname   => 'Butterfly',
            middlename => 'Perl 6!!!!',
            websiteId  => 1 
        },
    }

    # Customer update
    my %t2_results = customers %config, id => $t1_customer_id, data => %t2_data;
    is %t2_results<firstname>, 'Camelia', 'customer update [firstname]';
    is %t2_results<lastname>, 'Butterfly', 'customer update [lastname]';
    is %t2_results<middlename>, 'Perl 6!!!!', 'customer update [middlename]';

    my %t3_data = %{
        email      => 'camelia1@p6magentofakemail.com',
        websiteId  => 1
    }

    # Customer send verification email
    #
    # This will only work if Stores > Configuration > Customer Configuration 
    # > Create New Account Options > Require Emails Confirmation = Yes
    # ./bin/magento config:set customer/create_account/confirm true

    my %t3_results = customers-confirm %config, data => %t3_data;
    # This should return the following message:
    is %t3_results<message>, 'No confirmation needed.', 'customer confirm email';

    my %t4_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'email',
                            value => 'camelia1@p6magentofakemail.com',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }

    # Customer search
    my %t4_results = customers-search %config, search_criteria => %t4_search_criteria;
    is %t4_results<items>.head<firstname>, 'Camelia', 'customer search [firstname]';
    is %t4_results<items>.head<lastname>, 'Butterfly', 'customer search [lastname]';

    my %t5_data = %{
        confirmationKey => 'aklsjdkljasdjklasdjklasjkldlkajsdjklasdlkj' 
    }
    # Customer email activate
    my %t5_results = customers-email-activate %config, email => 'camelia1@p6magentofakemail.com', data => %t5_data;
    is %t5_results<message>, 'Account already active', 'customer email activate';

    # Customer reset link token
    my %t6_results = customers-reset-link-token %config, id => $t1_customer_id, link_token => 'asdasdasd';
    is %t6_results<message>, 'Reset password token mismatch.', 'customer reset link token';

    my %t7_data = %{
        email      => $customer_email,
        template   => 'email_reset',
        websiteId  => 1
    }

    # Customer password
    #
    # This will only work if Stores > Configuration > Customer Configuration 
    # > Password Options > Max Number of Password Reset Requests = 0
    #
    # ./bin/magento config:set customer/password/max_number_password_reset_requests 0
    #
    # and:
    #
    # Stores > Configuration > Customer Configuration > Password Options
    # > Min Time Between Password Reset Requests = 0
    # ./bin/magento config:set customer/password/min_time_between_password_reset_requests 0

    my $t7_results = customers-password %config, data => %t7_data;
    is $t7_results, False, 'customer password';

    # Customer confirm by id
    my $t8_results = customers-confirm %config, id => $t1_customer_id;
    is $t8_results, 'account_confirmed', 'customer confirm by id';

    my %t9_data = %{
        customer => %{
            email      => 'fakeemail@someplace.com',
            firstname  => 'Camelia',
            lastname   => 'Butterfly',
            middlename => 'Perl 6',
            groupId    => 2
        }
    }

    # Customer validate
    my %t9_results = customers-validate %config, data => %t9_data;
    is %t9_results<valid>, False, 'customer validate';

    # Customer permissions read-only (Check if customer can be deleted)
    my $t10_results = customers-permissions %config, id => $t1_customer_id;
    is $t10_results, False, 'customer permissions read-only';

    my %t11_data = %{
        customerEmail => 'camelia1@p6magentofakemail.com',
        websiteId     => 1
    }
    # Customer is email available
    my $t11_results = customers-email-available %config, data => %t11_data;
    is $t11_results, False, 'customer email available';

    # Customer address by id
    my %t12_results = customers-addresses %config, address_id => $t1_address_id;
    is %t12_results<postcode>, '90210', 'customer address by id';

    # Customer shipping address
    my %t13_results = customers-addresses-shipping %config, id => $t1_customer_id;
    is %t13_results<postcode>, '90210', 'customer shipping address';

    # Customer billing address
    my %t14_results = customers-addresses-billing %config, id => $t1_customer_id;
    is %t14_results<postcode>, '90210', 'customer shipping address';

    # Customer address delete
    my $fin_address_results = customers-addresses-delete %config, address_id => $t1_address_id;
    is $fin_address_results, True, 'customer address delete';

    # Customer delete
    my $fin_customer_results = customers-delete %config, id => $t1_customer_id;
    is $fin_customer_results, True, 'customer delete';

}, 'Customers';

subtest {

    my %mine_config;

    my $customer_access_token = 
        request-access-token
            host      => %config<host>,
            username  => $customer_email,
            password  => $customer_pass,
            user_type => 'customer';

    %mine_config = %( |%config, access_token => $customer_access_token );

}, 'Me';

done-testing;
