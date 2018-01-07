use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

# Setup Magento 2 for Perl 6 Magento module testing
#
# ./bin/magento config:set sales/gift_options/allow_order true
# ./bin/magento config:set sales/gift_options/allow_items true

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::GiftMessage;
use Magento::Quote;
use Magento::Catalog;
use GiftMessage;
use TestLogin;

my %config = TestLogin::admin_config;
my $simple_prod = products %config, data => %( GiftMessage::simple() );

subtest {

    my $cart_id = carts %config;
    my %t1_cart_items_data = GiftMessage::carts-items(quote_id => $cart_id);

    my %cart =
        carts-items
            %config,
            cart_id => $cart_id,
            data    => %t1_cart_items_data;

    # POST   /V1/carts/:cartId/gift-message
    my %t1_data = GiftMessage::gift-message();

    my $t1_results =
        carts-gift-message 
            %config,
            cart_id => $cart_id,
            data    => %t1_data;
    is $t1_results, True, 'carts gift-message new';

    # GET    /V1/carts/:cartId/gift-message
    my $t2_results =
        carts-gift-message 
            %config,
            cart_id => $cart_id;
    is $t2_results<message>, 'Delete me message', 'carts gift-message by cart id';

    # POST   /V1/carts/:cartId/gift-message/:itemId
    my $t3_results =
        carts-gift-message 
            %config,
            cart_id => $cart_id,
            item_id => %cart<item_id>.Int,
            data    => %t1_data;
    is $t3_results, True, 'carts gift-message item message new';

    # GET    /V1/carts/:cartId/gift-message/:itemId
    my $t4_results =
        carts-gift-message 
            %config,
            cart_id => $cart_id,
            item_id => %cart<item_id>.Int;
    is $t4_results<message>, 'Delete me message', 'carts gift-message by item id';

}, 'Carts gift-message';


subtest {

    my $customer_email = 'p6magento@fakeemail.com';
    my $customer_pass  = 'fakeMagent0P6';
    my %mine_config;

    my $customer_access_token = 
        request-access-token
            host      => %config<host>,
            username  => $customer_email,
            password  => $customer_pass,
            user_type => 'customer';

    %mine_config     = %( |%config, access_token => $customer_access_token );
    my $mine_cart_id = carts-mine-new %mine_config;

    # Add product to Cart
    my %t1_cart_items_data = GiftMessage::carts-items(quote_id => $mine_cart_id);

    my %mine_cart =
        carts-mine-items
            %mine_config,
            data => %t1_cart_items_data;

    # POST   /V1/carts/mine/gift-message
    my %t1_data = GiftMessage::gift-message();

    my $t1_results =
        carts-mine-gift-message 
            %mine_config,
            data => %t1_data;
    is $t1_results, True, 'carts mine-gift-message new';

    # GET    /V1/carts/mine/gift-message
    my $t2_results =
        carts-mine-gift-message %mine_config;
    is $t2_results<message>, 'Delete me message', 'carts mine-gift-message all';

    # POST   /V1/carts/mine/gift-message/:itemId
    my $t3_results =
        carts-mine-gift-message 
            %mine_config,
            item_id => %mine_cart<item_id>.Int,
            data    => %t1_data;
    is $t3_results, True, 'carts mine-gift-message cart item message new';

    # GET    /V1/carts/mine/gift-message/:itemId
    my $t4_results =
        carts-mine-gift-message 
            %mine_config,
            item_id => %mine_cart<item_id>.Int;
    is $t4_results<message>, 'Delete me message', 'carts mine-gift-message by cart item id';

}, 'Carts mine-gift-message';

subtest {

    my $guest_cart_id = guest-carts %config;
    my %t1_cart_items_data = GiftMessage::carts-items(quote_id => $guest_cart_id);

    my %guest_cart =
        guest-carts-items
            %config,
            cart_id => $guest_cart_id,
            data    => %t1_cart_items_data;

    # POST   /V1/guest-carts/:cartId/gift-message
    my %t1_data = GiftMessage::gift-message();
    my $t1_results =
        guest-carts-gift-message 
            %config,
            cart_id => $guest_cart_id,
            data    => %t1_data;
    is $t1_results, True, 'guest carts-gift-message new';

    # GET    /V1/guest-carts/:cartId/gift-message
    my $t2_results =
        guest-carts-gift-message 
            %config,
            cart_id => $guest_cart_id;
    is $t2_results<message>, 'Delete me message', 'guest carts-gift-message by cart id';

    # POST   /V1/guest-carts/:cartId/gift-message/:itemId
    my $t3_results =
        guest-carts-gift-message 
            %config,
            cart_id => $guest_cart_id,
            item_id => %guest_cart<item_id>.Int,
            data    => %t1_data;
    is $t3_results, True, 'guest carts-gift-message cart item messsage new';

    # GET    /V1/guest-carts/:cartId/gift-message/:itemId
    my $t4_results =
        guest-carts-gift-message 
            %config,
            cart_id => $guest_cart_id,
            item_id => %guest_cart<item_id>.Int;
    is $t4_results<message>, 'Delete me message', 'guest carts-gift-message by cart item id';

}, 'Guest carts-gift-message';

done-testing;
