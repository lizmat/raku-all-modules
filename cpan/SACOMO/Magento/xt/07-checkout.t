use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Checkout;
use Magento::Quote;
use Magento::Catalog;
use Checkout;
use TestLogin;

my %config = TestLogin::admin_config;
my $simple_prod = products %config, data => %( Checkout::simple() );
my $customer_email = 'p6magento@fakeemail.com';

subtest {

    my $customer_pass  = 'fakeMagent0P6';
    my %mine_config;

    use Magento::Auth;
    my $customer_access_token = 
        request-access-token
            host      => %config<host>,
            username  => $customer_email,
            password  => $customer_pass,
            user_type => 'customer';

    %mine_config     = %( |%config, access_token => $customer_access_token );
    my $mine_cart_id = carts-mine-new %mine_config;
    my %t1_cart_items_data = Checkout::carts-items(quote_id => $mine_cart_id);

    my %cart =
        carts-mine-items
            %mine_config,
            data    => %t1_cart_items_data;

    # POST   /V1/carts/mine/shipping-information
    my %t1_data = addressInformation => %{
        shipping_address => %{
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
        billing_address => %{
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

    my $t1_results =
        carts-mine-shipping-information 
            %mine_config,
            data => %t1_data;
    is $t1_results<totals><base_currency_code>, 'USD', 'carts mine-shipping-information new';

    # POST   /V1/carts/mine/payment-information
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
        carts-mine-payment-information 
            %mine_config,
            data => %t2_data;
    is $t2_results ~~ Int, True, 'carts mine-payment-information new';

# revisit, these three are currently not working correctly.
# https://github.com/magento/magento2/issues/7299
#
#        # POST   /V1/carts/mine/set-payment-information
#        my $t3_results =
#            carts-mine-set-payment-information
#                %mine_config,
#                data => %t2_data;
#                note $t3_results;
#        is True, True, 'carts mine-set-payment-information';
#    
#        # GET    /V1/carts/mine/payment-information
#        my $t4_results = carts-mine-payment-information %mine_config;
#            note $t3_results;
#        is True, True, 'carts mine-payment-information all';
#    
#        # POST   /V1/carts/mine/totals-information
#        my %t5_data = addressInformation => %{
#            address => %{
#                firstname     => 'Camelia',
#                lastname      => 'Butterfly',
#                postcode      => '90210',
#                city          => 'Beverly Hills',
#                street        => ['Zoe Ave'],
#                regionId      => 12,
#                countryId     => 'US',
#                telephone     => '555-555-5555',
#                email         => $customer_email
#            },
#            shippingCarrierCode => 'flatrate', 
#            shippingMethodCode  => 'flatrate'
#        }
#
#        my $t5_results =
#            carts-mine-totals-information 
#                %mine_config,
#                data => %t5_data;
#                note $t5_results;
#        is True, True, 'carts mine-totals-information';

}, 'Carts mine';

subtest {

    my $cart_id = carts %config;
    my %t1_cart_items_data = Checkout::carts-items(quote_id => $cart_id);

    my %cart =
        carts-items
            %config,
            cart_id => $cart_id,
            data    => %t1_cart_items_data;

    # POST   /V1/carts/:cartId/shipping-information
    my %t1_data = addressInformation => %{
        shipping_address => %{
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
        billing_address => %{
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

    my $t1_results =
        carts-shipping-information 
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is $t1_results<totals><base_currency_code>, 'USD', 'carts shipping-information new';

    # POST   /V1/carts/:cartId/totals-information
    my %t2_data = addressInformation => %{
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
        },
        shippingCarrierCode => 'flatrate', 
        shippingMethodCode  => 'flatrate'
    }

    my $t2_results =
        carts-totals-information 
            %config,
            cart_id => $cart_id,
            data    => %t2_data;
    is $t1_results<totals><base_currency_code>, 'USD', 'carts totals-information new';

}, 'Carts';

subtest {

    my $guest_cart_id = guest-carts %config;
    my %t1_cart_items_data = Checkout::carts-items(quote_id => $guest_cart_id);

    my %guest_cart =
        guest-carts-items
            %config,
            cart_id => $guest_cart_id,
            data    => %t1_cart_items_data;

    # POST   /V1/guest-carts/:cartId/shipping-information
    my %t1_data = addressInformation => %{
        shipping_address => %{
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
        billing_address => %{
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

    my $t1_results =
        guest-carts-shipping-information 
            %config,
            cart_id => $guest_cart_id,
            data    => %t1_data;
    is $t1_results<totals><base_currency_code>, 'USD', 'guest carts-shipping-information';

    # POST   /V1/guest-carts/:cartId/payment-information
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
        guest-carts-payment-information 
            %config,
            cart_id => $guest_cart_id,
            data    => %t2_data;
    is $t2_results ~~ Int, True, 'guest carts-payment-information new';

    # revisit, not working. complaining about invalid cartId
    #
    # GET    /V1/guest-carts/:cartId/payment-information
    #my $t3_results =
    #    guest-carts-payment-information 
    #        %config,
    #        cart_id => $guest_cart_id;
    #        note $t3_results;
    ##is $t3_results<totals><base_currency_code>, 'USD', 'guest carts-payment-information by id';

    ## POST   /V1/guest-carts/:cartId/set-payment-information
    #my $t4_results =
    #    guest-carts-set-payment-information 
    #        %config,
    #        cart_id => $guest_cart_id,
    #        data    => %t2_data;
    #        note $t4_results;
    #is $t4_results ~~ Int, True, 'guest carts-set-payment-information new';

    # POST   /V1/guest-carts/:cartId/totals-information
    #my %t5_data = addressInformation => %{
    #    address => %{
    #        firstname     => 'Camelia',
    #        lastname      => 'Butterfly',
    #        postcode      => '90210',
    #        city          => 'Beverly Hills',
    #        street        => ['Zoe Ave'],
    #        regionId      => 12,
    #        countryId     => 'US',
    #        telephone     => '555-555-5555',
    #        email         => $customer_email
    #    },
    #    shippingCarrierCode => 'flatrate', 
    #    shippingMethodCode  => 'flatrate'
    #}

    #my $t5_results =
    #    guest-carts-totals-information 
    #        %config,
    #        cart_id => $guest_cart_id,
    #        data    => %t5_data;
    #        note $t5_results;
    #is $t5_results<totals><base_currency_code>, 'USD', 'guest carts-totals-information new';

}, 'Guest carts';

done-testing;
