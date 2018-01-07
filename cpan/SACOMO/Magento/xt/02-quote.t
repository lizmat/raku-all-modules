use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

# To run the `mine` tests working set the password for the customer
# then run these scripts with the P6MAGENTOMINE enviornment 
# variable set:
# 
# P6MAGENTOMINE=1 prove -ve 'perl6 -Ilib' xt/02-quote.t

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Checkout;
use Magento::Config;
use Magento::Customer;
use Magento::Quote;
use Quote;
use Setup;
use TestLogin;

my %config         = TestLogin::admin_config;
my $customer_id    = Setup::customer-id();
my $customer_email = 'p6magento@fakeemail.com';
my $customer_pass  = 'fakeMagent0P6';
my $cart_id;
my $cart_item_id;
my $address_id;
my %mine_config;
my $customer_cart_id;
my $customer_item_id;

subtest {

    # POST   /V1/carts/
    my $t1_results = carts(%config);
    is $t1_results.^name, 'Int', 'carts new';
    $cart_id = $t1_results;

    # GET    /V1/carts/:cartId
    my %t2_results = carts %config, :$cart_id;
    is %t2_results<customer_is_guest>, False, 'carts by id';

    # PUT    /V1/carts/:cartId
    my %t3_data = customerId => $customer_id,
                  storeId    => 1;
    my $t3_results = carts(%config, cart_id => $cart_id, data => %t3_data);
    given $t3_results {
        when Bool {
            is $t3_results, True, 'carts update';
        }
        default {
            like $t3_results<message>, /'Cannot assign customer to the given cart'/, 'carts update';
        }
    }

}, 'Carts';

subtest {

    # POST   /V1/carts/:cartId/billing-address
    my %t1_data = Quote::carts-billing-address();

    my $t1_results =
        carts-billing-address
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is $t1_results ~~ Int, True, 'carts billing-address new';
    my $cart_address_id = $t1_results;

    # GET    /V1/carts/:cartId/billing-address
    my %t2_results = carts-billing-address %config, :$cart_id;
    is %t2_results<postcode>, 90210, 'carts billing-address by id';

}, 'Carts billing-address';

subtest {

    my $sku = Setup::product-sku();

    # POST   /V1/carts/:quoteId/items
    my %t1_data = Quote::carts-items(quote_id => "$cart_id");

    my %t1_results =
        carts-items
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is %t1_results<sku>, 'P6-TEST-DELETE', 'carts items new';
    $cart_item_id = %t1_results<item_id>;

    # PUT    /V1/carts/:cartId/items/:itemId
    my %t2_data = Quote::carts-items-update(quote_id => "$cart_id");

    my %t2_results =
        carts-items
            %config,
            cart_id => $cart_id,
            item_id => $cart_item_id,
            data    => %t2_data;
    is %t2_results<qty>, 5, 'carts items update';

    # GET    /V1/carts/:cartId/items
    my $t3_results = carts-items %config, :$cart_id;
    is $t3_results.head<product_type>, 'simple', 'carts items by cart_id';

}, 'Carts items';

#subtest {
#
#    use Magento::SalesRule;
#    # PUT    /V1/carts/:cartId/coupons/:couponCode
#    my $coupon_id = Setup::coupon-id();
#
#    # No way to assign 'specific' coupon_code
#    # to sales rule using the API yet, revisit.
#    %config
#    ==> carts-coupons(
#        cart_id     => $cart_id,
#        coupon_code => 'DeleteMeCoupon'
#    )
#    ==> my $t2_results;
#    is True, True, 'carts coupons update';
#
#    # GET    /V1/carts/:cartId/coupons
#    %config
#    ==> carts-coupons(:$cart_id)
#    ==> my @t2_results;
#    is @t2_results, [], 'carts coupons by cart_id';
#
#    # DELETE /V1/carts/:cartId/coupons
#    %config
#    ==> carts-coupons-delete(:$cart_id)
#    ==> my $t3_results;
#    is $t3_results, True, 'carts coupons delete';
#
#}, 'Carts coupons';

subtest {

    # POST   /V1/carts/:cartId/estimate-shipping-methods
    my %t1_data = Quote::carts-estimate-shipping-methods();

    my $t1_results =
        carts-estimate-shipping-methods
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is $t1_results.head<carrier_code>, 'flatrate', 'carts estimate-shipping-methods';

}, 'Carts estimate-shipping-methods';

subtest {

    my %customer_data = %{
        customer => %{
            email      => $customer_email,
            firstname  => 'Camelia',
            lastname   => 'Butterfly',
            middlename => 'Perl 6',
            websiteId  => 1,
            addresses => [
                %{
                    customerId       => $customer_id,
                    firstname        => 'Camelia',
                    lastname         => 'Butterfly',
                    postcode         => '90210',
                    city             => 'Beverly Hills',
                    street           => ['Zoe Ave'],
                    regionId         => 12,
                    countryId        => 'US',
                    telephone        => '555-555-5555',
                    default_shipping => 'true',
                    default_billing  => 'true',
                },
            ]
        },
    }

    # Customer update set address
    $address_id = customers(%config, id => $customer_id, data => %customer_data)<addresses>.head<id>;

    # POST   /V1/carts/:cartId/estimate-shipping-methods-by-address-id
    my %t1_data = %{ 
        addressId => $address_id
    }

    my $t1_results =
        carts-estimate-shipping-methods-by-address-id
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is $t1_results.head<carrier_code>, 'flatrate', 'carts estimate-shipping-methods-by-address-id';

}, 'Carts estimate-shipping-methods-by-address-id';

subtest {

    # GET    /V1/carts/:cartId/payment-methods
    my @t1_results = carts-payment-methods(%config, :$cart_id);
    is so @t1_results.any.grep({ $_<code> ~~ 'banktransfer' }), True, 'carts payment-methods by cart_id';

}, 'Carts payment-methods';

subtest {

    # Cannot complete order without shipping address
    # assigned to cart. Confirm endpoint returns 
    # expected shipping address message.
 
    # PUT    /V1/carts/:cartId/shipping-address
    my %t1_address = %{
        address => %{
            customerId    => $customer_id,
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email,
            useForShipping => 'true'

        }
    }

    # Need to save shipping address for cart before 
    # setting the payment method. Cannot set the cart
    # shipping address via the API. Looks like it is being
    # workied on in beta, revisit:
    # https://github.com/magento/magento2/issues/2517

    # Assign shipping address to cart
    carts-billing-address
        %config,
        cart_id => $cart_id,
        data    => %t1_address;

    # PUT    /V1/carts/:cartId/selected-payment-method
    my %t1_data = method => %{
        method => 'banktransfer'
    }

    my %t1_results =
        carts-selected-payment-method
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is %t1_results<message>, 'Shipping address is not set', 'carts selected-payment-method update';

    # GET    /V1/carts/:cartId/selected-payment-method
    my $t2_results = carts-selected-payment-method %config, :$cart_id;
    is $t2_results, False, 'carts selected-payment-method by id';


}, 'Carts selected-payment-method';

subtest {

    # GET    /V1/carts/:cartId/shipping-methods
    my %t1_results = carts-shipping-methods %config, :$cart_id;
    is %t1_results<message>, 'Shipping address not set.', 'carts shipping-methods by cart_id';

}, 'Carts shipping-methods';

subtest {

    # GET    /V1/carts/:cartId/totals
    my %t1_results = carts-totals %config, :$cart_id;
    is %t1_results<grand_total>, '99.75', 'carts totals by cart_id';

}, 'Carts totals';

subtest {

    # POST   /V1/customers/:customerId/carts
    my $t1_results = customers-carts %config, :$customer_id;
    is $t1_results ~~ Int, True, 'customers carts new';

}, 'Customers carts';

subtest {

    # Cannot complete order without shipping address
    # assigned to cart. Confirm endpoint returns 
    # expected shipping address message.

    # PUT    /V1/carts/:cartId/order
    my %t1_data = paymentMethod => %{
        method => 'banktransfer'
    }

    my %t1_results = 
        carts-order
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    like %t1_results<message>, / 'Please check the shipping address information' /, 'carts order update';

}, 'Carts order';

subtest {

    # POST   /V1/guest-carts
    my $t1_results = guest-carts %config;
    is $t1_results.chars, 32, 'guest carts new';
    my $t1_cart_id = $t1_results;

    # revisit, need to add customer to guest cart?

    # PUT    /V1/guest-carts/:cartId
    #my %t2_data = %{
    #    customerId => $customer_id,
    #    storeId    => 1
    #}

    #%config
    #my $t2_results =
    #    guest-carts
    #        %config,
    #        cart_id => $t1_cart_id,
    #        data    => %t2_data;
    #is True, True, 'guest carts update';

    # POST   /V1/guest-carts/:cartId/billing-address
    my %t3_data = %{
        address => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email

        }
    }

    my $t3_results = guest-carts-billing-address
        %config,
        cart_id => $t1_cart_id,
        data    => %t3_data;
    is $t3_results ~~ Int, True, 'guest carts-billing-address new';


    # GET    /V1/guest-carts/:cartId/billing-address
    my %t4_results =
        guest-carts-billing-address
            %config,
            cart_id => $t1_cart_id;
    is %t4_results<country_id>, 'US', 'guest carts-billing-address by cart_id';

    
    # GET    /V1/guest-carts/:cartId
    my %t5_results =
        guest-carts
            %config,
            cart_id => $t1_cart_id;
    is %t5_results<currency><quote_currency_code>, 'USD', 'guest carts by cart_id';

    # POST   /V1/guest-carts/:cartId/items
    my %t6_data = Quote::guest-carts-items cart_id => $t1_cart_id;

    my %t6_results =
        guest-carts-items
            %config,
            cart_id => $t1_cart_id,
            data    => %t6_data;
    is %t6_results<product_type>, 'simple', 'guest carts-items new';

    # PUT    /V1/guest-carts/:cartId/items/:itemId
    my %t7_data = Quote::guest-carts-items-update cart_id => $t1_cart_id;

    my %t7_results =
        guest-carts-items
            %config,
            cart_id => $t1_cart_id,
            item_id => %t6_results<item_id>,
            data    => %t7_data;
    is %t7_results<qty>, 7, 'guest carts-items update';

    # GET    /V1/guest-carts/:cartId/items
    my @t8_results = guest-carts-items %config, cart_id => $t1_cart_id;
    is @t8_results.elems, 1, 'guest carts-items by cart_id';

    my %t9_data = addressInformation => %{
        shippingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email
        },
        billingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email
        },
        shippingCarrierCode => 'flatrate', 
        shippingMethodCode  => 'flatrate'
    }

    my %t9_results =
        guest-carts-shipping-information
            %config,
            cart_id => $t1_cart_id,
            data    => %t9_data;
    is %t9_results<totals><base_currency_code>, 'USD', 'guest carts set shipping / billing address'; 

    my %t10_data = %{
        email         => $customer_email,
        paymentMethod => %{
            method => 'banktransfer'
        },
        billingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            sameAsBilling => 1
        }
    }

    my $t10_results =
        guest-carts-set-payment-information
            %config,
            cart_id => $t1_cart_id,
            data    => %t10_data;
    is $t10_results, True, 'guest carts set payment method'; 

    # PUT    /V1/guest-carts/:cartId/collect-totals
    my %t11_data = paymentMethod => %{
        method => 'banktransfer'
    }
    my %t11_results =
        guest-carts-collect-totals
            %config,
            cart_id => $t1_cart_id,
            data    => %t11_data;
    is %t11_results<quote_currency_code>, 'USD', 'guest carts-collect-totals update';

    # GET    /V1/guest-carts/:cartId/selected-payment-method
    my %t12_results =
        guest-carts-selected-payment-method
            %config,
            cart_id => $t1_cart_id;
    is %t12_results<method>, 'banktransfer', 'guest carts-selected-payment-method by cart_id';

    # PUT    /V1/guest-carts/:cartId/selected-payment-method
    my %t13_data = method => %{
        method => 'banktransfer'
    }

    my $t13_results = guest-carts-selected-payment-method(
        %config,
        cart_id => $t1_cart_id,
        data    => %t13_data
    );
    is $t13_results ~~ Int, True, 'guest carts-selected-payment-method update';

    # GET    /V1/guest-carts/:cartId/payment-methods
    my @t14_results =
        guest-carts-payment-methods
            %config,
            cart_id => $t1_cart_id;
    is so @t14_results.any.grep({ $_<code> ~~ 'checkmo' }), True, 'guest carts-payment-methods by cart_id';

    # GET    /V1/guest-carts/:cartId/shipping-methods
    my @t15_results =
        guest-carts-shipping-methods
            %config,
            cart_id => $t1_cart_id;
    is so @t15_results.any.grep({ $_<carrier_code> ~~ 'flatrate' }), True, 'guest carts-shipping-methods by cart_id';

    # GET    /V1/guest-carts/:cartId/totals
    my %t16_results =
        guest-carts-totals
            %config,
            cart_id => $t1_cart_id;
    is %t16_results<base_currency_code>, 'USD', 'guest carts-totals by cart_id';

    # Setup coupon
    my $coupon_id = Setup::coupon-id();

    # revisit, this doesn't work. there is no way to associate a 
    # coupon_code to a sales rule using the API.

    # PUT    /V1/guest-carts/:cartId/coupons/:couponCode
    my %t17_results =
        guest-carts-coupons
            %config,
            cart_id     => $t1_cart_id,
            coupon_code => 'DeleteMeCoupon';
    is %t17_results<message>, 'Coupon code is not valid', 'guest carts-coupons update';


    # GET    /V1/guest-carts/:cartId/coupons
    my $t18_results = guest-carts-coupons %config, cart_id => $t1_cart_id;
    is $t18_results, False, 'guest carts-coupons all by cart_id';

    # DELETE /V1/guest-carts/:cartId/coupons
    my $t19_results = guest-carts-coupons-delete %config, cart_id => $t1_cart_id;
    is $t19_results, True, 'guest carts-coupons delete';

    # POST   /V1/guest-carts/:cartId/estimate-shipping-methods
    my %t20_data = Quote::carts-estimate-shipping-methods();

    my $t20_results =
        guest-carts-estimate-shipping-methods
            %config,
            cart_id => $t1_cart_id,
            data    => %t20_data;
    is so $t20_results.any.grep({ $_<carrier_code> ~~ 'flatrate' }), True, 'guest carts-estimate-shipping-methods assign';

    # DELETE /V1/guest-carts/:cartId/items/:itemId
    my $t21_results =
        guest-carts-items-delete
            %config,
            cart_id => $t1_cart_id,
            item_id => %t6_results<item_id>;
    is $t21_results, True, 'guest carts-items delete';

    my %t22_data = Quote::guest-carts-items cart_id => $t1_cart_id;

    my %t22_results =
        guest-carts-items
            %config,
            cart_id => $t1_cart_id,
            data    => %t22_data;
    is %t22_results<product_type>, 'simple', 'guest carts-items re-add after delete';

    # PUT    /V1/guest-carts/:cartId/order
    my %t23_data = paymentMethod => %{
        method => 'banktransfer'
    }

    my $t23_results =
        guest-carts-order
            %config,
            cart_id => $t1_cart_id,
            data    => %t23_data;
    is $t23_results ~~ Int, True, 'guest carts-order place order';

}, 'Guest carts';

subtest {

    use Magento::Auth;
    my $customer_access_token = 
        request-access-token
            host      => %config<host>,
            username  => $customer_email,
            password  => $customer_pass,
            user_type => 'customer';

    %mine_config = %( |%config, access_token => $customer_access_token );

    # POST   /V1/carts/mine
    my $t1_results = carts-mine-new %mine_config;
    is $t1_results ~~ Int, True, 'carts mine new';
    $customer_cart_id = $t1_results;

    # GET    /V1/carts/mine
    my %t2_results = carts-mine %mine_config;
    is %t2_results<customer_is_guest>, False, 'carts mine by access_token';

    # PUT    /V1/carts/mine
    my $t3_results =
        carts-mine-update
            %mine_config,
            data => %( quote => %t2_results );
    is $t3_results, False, 'carts mine update';

}, 'Carts mine';

subtest {

    # POST   /V1/carts/mine/billing-address
    my %t1_data = Quote::carts-billing-address();

    my $t1_results =
        carts-mine-billing-address
            %mine_config,
            data => %t1_data;
    is $t1_results ~~ Int, True, 'carts mine billing-address new';
    my $cart_address_id = $t1_results;

    # GET    /V1/carts/mine/billing-address
    my %t2_results = carts-mine-billing-address %mine_config;
    is %t2_results<postcode>, 90210, 'carts mine billing-address by id';

}, 'Carts mine-billing-address';

subtest {
        
    # POST   /V1/carts/mine/items
    my %t1_data = Quote::carts-mine-items cart_id => $customer_cart_id;

    my %t1_results =
        carts-mine-items
            %mine_config,
            data => %t1_data;
    is %t1_results<product_type>, 'simple', 'carts-mine-items new';
    $customer_item_id = %t1_results<item_id>;

    # PUT    /V1/carts/mine/items/:itemId
    my %t2_data = Quote::carts-mine-items-update cart_id => $customer_cart_id;

    my %t2_results =
        carts-mine-items
            %mine_config,
            item_id => $customer_item_id,
            data    => %t2_data;
    is %t2_results<qty>, 7, 'carts-mine-items update';

    # GET    /V1/carts/mine/items
    my @t3_results = carts-mine-items %mine_config;
    is @t3_results.elems, 1, 'carts-mine-items by cart_id';

}, 'Carts mine-items';

subtest {

    my %t1_data = addressInformation => %{
        shippingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email
        },
        billingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            email         => $customer_email
        },
        shippingCarrierCode => 'flatrate', 
        shippingMethodCode  => 'flatrate'
    }

    my %t1_results =
        carts-mine-shipping-information
            %mine_config,
            data    => %t1_data;
    is %t1_results<totals><base_currency_code>, 'USD', 'carts mine set shipping / billing address'; 

    my %t2_data = %{
        email         => $customer_email,
        paymentMethod => %{
            method => 'banktransfer'
        },
        billingAddress => %{
            firstname     => 'Camelia',
            lastname      => 'Butterfly',
            postcode      => '90210',
            city          => 'Beverly Hills',
            street        => ['Zoe Ave'],
            regionId      => 12,
            countryId     => 'US',
            telephone     => '555-555-5555',
            sameAsBilling => 1
        }
    }

    my $t2_results =
        carts-mine-set-payment-information
            %mine_config,
            data => %t2_data;
    is $t2_results, True, 'carts mine set payment method'; 

    # GET    /V1/carts/mine/selected-payment-method
    my %t3_results = carts-mine-selected-payment-method %mine_config;
    is %t3_results<method>, 'banktransfer', 'carts-mine-selected-payment-method by cart_id';

    # PUT    /V1/carts/mine/selected-payment-method
    my %t4_data = method => %{
        method => 'banktransfer'
    }

    my $t4_results = carts-mine-selected-payment-method(
        %mine_config,
        data => %t4_data
    );
    is $t4_results ~~ Int, True, 'carts-mine-selected-payment-method update';

    # GET    /V1/-carts/:cartId/payment-methods
    my @t5_results = carts-mine-payment-methods %mine_config;
    is so @t5_results.any.grep({ $_<code> ~~ 'checkmo' }), True, 'carts-mine-payment-methods by cart_id';

    # GET    /V1/carts/mine/shipping-methods
    my @t6_results = carts-mine-shipping-methods %mine_config;
    is so @t6_results.any.grep({ $_<carrier_code> ~~ 'flatrate' }), True, 'carts-mine-shipping-methods by cart_id';

}, 'Carts mine shipping methods';

subtest {

    # PUT    /V1/carts/mine/collect-totals
    my %t1_data = paymentMethod => %{
        method => 'banktransfer'
    }
    my %t1_results =
        carts-mine-collect-totals
            %mine_config,
            data => %t1_data;
    is %t1_results<quote_currency_code>, 'USD', 'carts-mine-collect-totals update';

    # GET    /V1/carts/mine/totals
    my %t2_results = carts-mine-totals %mine_config;
    is %t2_results<base_currency_code>, 'USD', 'carts-mine-totals by cart_id';

}

#subtest {
#
# revisit, need to add customer to guest cart?
#
#    # GET    /V1/carts/mine/coupons
#    %config
#    ==> carts-mine-coupons(    )
#    ==> my $t1_results;
#    is True, True, 'carts mine-coupons all';
#
#    # PUT    /V1/carts/mine/coupons/:couponCode
#    my %t2_data = Quote::carts-mine-coupons();
#
#    %config
#    ==> carts-mine-coupons(
#        coupon_code => '',
#        data       => %t2_data
#    )
#    ==> my $t2_results;
#    is True, True, 'carts mine-coupons update';
#
#    # DELETE /V1/carts/mine/coupons
#    %config
#    ==> carts-mine-coupons(    )
#    ==> my $t3_results;
#    is True, True, 'carts mine-coupons delete';
#
#}, 'Carts mine-coupons';
#

subtest {

    # POST   /V1/carts/mine/estimate-shipping-methods
    my %t1_data = Quote::carts-estimate-shipping-methods();

    my $t1_results =
        carts-mine-estimate-shipping-methods
            %mine_config,
            data => %t1_data;
    is so $t1_results.any.grep({ $_<carrier_code> ~~ 'flatrate' }), True, 'carts-mine-estimate-shipping-methods assign';

}, 'Carts mine-estimate-shipping-methods';

subtest {

    # POST   /V1/carts/mine/estimate-shipping-methods-by-address-id
    my %t1_data = %{ 
        addressId => $address_id
    }

    my $t1_results =
        carts-mine-estimate-shipping-methods-by-address-id
            %mine_config,
            data => %t1_data;
    is $t1_results.head<carrier_code>, 'flatrate', 'carts-mine-estimate-shipping-methods-by-address-id';

}, 'Carts mine-estimate-shipping-methods-by-address-id';

subtest {

    # DELETE /V1/carts/mine/items/:itemId
    my $t1_results =
        carts-mine-items-delete
            %mine_config,
            item_id => $customer_item_id;
    is $t1_results, True, 'carts-mine-items delete';

    my %t2_data = Quote::carts-mine-items cart_id => $customer_cart_id;

    my %t2_results =
        carts-mine-items
            %mine_config,
            data => %t2_data;
    is %t2_results<product_type>, 'simple', 'carts-mine-items re-add after delete';

}, 'Carts mine delete items';

subtest {

    # PUT    /V1/carts/mine/order
    my %t1_data = paymentMethod => %{
        method => 'banktransfer'
    }

    my $t1_results =
        carts-mine-order
            %mine_config,
            data => %t1_data;
    is $t1_results ~~ Int, True, 'carts-mine-order place order';

}, 'Carts mine order';

subtest {

    # GET    /V1/carts/search
    my %t1_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'is_active',
                            value => 'true',
                            condition_type => 'eq'
                        },
                    ]
                },
            ],
        }
    }

    my %t1_results =
        carts-search
            %config,
            search_criteria => %t1_search_criteria;
    is so %t1_results<items>.any.grep({
        $_<billing_address><email> ~~ $customer_email
    }), True, 'carts search all';

}, 'Carts search';

done-testing;
