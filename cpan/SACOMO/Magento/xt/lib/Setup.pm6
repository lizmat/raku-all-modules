#!/usr/bin/env perl6

use v6;

use Magento::Auth;
use Magento::Catalog;
use Magento::CatalogInventory;
use Magento::Config;
use Magento::Customer;
use Magento::SalesRule;
use Products;
use TestLogin;

unit module Setup;

my %config = TestLogin::admin_config;

our sub customer-id() {
    my %customer_data = %{
        customer  => %{
            email      => 'p6magento@fakeemail.com',
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

    # Confirm customer doesn't already exist
    my %customer_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'email',
                            value => 'p6magento@fakeemail.com',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
        }
    }

    # Customer search
    my %customer_search_results = customers-search %config, search_criteria => %customer_search_criteria;

    # No customer found, create new and return
    return customers(%config, data => %customer_data)<id> when %customer_search_results<items>.elems eq 0;

    # Customer found, return ID;
    return %customer_search_results<items>.head<id>;

}

our sub rule-id() {

    # Confirm rule id doesn't exist
    my %rule_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'name',
                            value => 'DeleteMeSalesRule',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
        }
    }

    # Sales rule search
    %config
    ==> sales-rules-search(search_criteria => %rule_search_criteria)
    ==> my %rule_search_results;

    my %rule_data   = rule => %{
        name                => 'DeleteMeSalesRule',
        websiteIds          => [ 0, 1 ],
        customerGroupIds    => [ 0, 1 ],
        usesPerCustomer     => 1,
        isActive            => 'true',
        stopRulesProcessing => 'false',
        isAdvanced          => 'true',
        sortOrder           => 0,
        simpleAction        => 'by_percent',
        discountAmount      => 4,
        discountStep        => 0,
        applyToShipping     => 'true',
        timesUsed           => 0,
        isRss               => 'true',
        couponType          => 'specific',
        useAutoGeneration   => 'false',
        usesPerCoupon       => 1
    }

    return %rule_search_results<items>.elems eq 0
           ?? sales-rules(%config, data => %rule_data)<rule_id>
           !! %rule_search_results<items>.head<rule_id>;
}

our sub coupon-id(
    Int :$rule_id = rule-id()
) {
    my %coupon_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'code',
                            value => 'DeleteMeCoupon',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
        }
    }

    my %coupon_data = coupon => %{
        ruleId    => $rule_id,
        code      => 'DeleteMeCoupon',
        timesUsed => 0,
        isPrimary => 1,
        type      => 0
    }

    my %coupon_search_results = coupons-search(%config, search_criteria => %coupon_search_criteria);

    # Return coupon_id
    return %coupon_search_results<items>.elems eq 0
           ?? coupons(%config, data => %coupon_data)<coupon_id>
           !! %coupon_search_results<items>.head<coupon_id>;
}

our sub product-sku() {

    my %search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'sku',
                            value => 'P6-TEST-DELETE',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
        }
    }

    %config
    ==> products(search_criteria => %search_criteria)
    ==> my %search_results;

    # Setup test product
    my %test_product = Products::delete-me();
    my $sku = %search_results<items>.elems eq 0
              ?? products(%config, data => %test_product)<sku>
              !! %search_results<items>.head<sku>;
              #my %product_qty = Products::configurable-qty();
    return $sku;

}
