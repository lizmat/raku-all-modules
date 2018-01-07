use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Customer;
use Magento::Catalog;
use Magento::Checkout;
use Magento::Config;
use Magento::Quote;
use Magento::Sales;
use Sales;
use TestLogin;

my %config = TestLogin::admin_config;
my $simple_prod    = products %config, data => %( Sales::simple() );
my $customer_email = 'p6magento@fakeemail.com';
my $customer_quote_id;
my $customer_item_id;
my $customer_invoice_id;
my $customer_creditmemo_id;
my $customer_shipment_id;

subtest {

    my $customer_pass  = 'fakeMagent0P6';
    my $customer_access_token = 
        request-access-token
            host      => %config<host>,
            username  => $customer_email,
            password  => $customer_pass,
            user_type => 'customer';

    my %mine_config     = %( |%config, access_token => $customer_access_token );
    my $cart_id         = carts-mine-new %mine_config;
    my %cart_items_data = Sales::carts-items(quote_id => $cart_id);

    my %cart_items =
        carts-mine-items
            %mine_config,
            data => %cart_items_data;

    my %customer_search_criteria = %{
        searchCriteria => %{ 
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'email',
                            value => $customer_email,
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }

    my %shipping_information = addressInformation => %{
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

    carts-mine-shipping-information %mine_config, data => %shipping_information;

    my %order_data = %{
        paymentMethod => %{
            method => 'checkmo',
        },
    }

    $customer_quote_id = carts-mine-order %mine_config, data => %order_data;

    # GET    /V1/orders
    my %t1_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'status',
                            value => 'pending',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }

    my %t1_results = orders %config; #, search_criteria => %t1_search_criteria;
    my $quote_parent_id = %t1_results<items>.head<parent_id>;
    $customer_item_id   = %t1_results<items>.head<items>.head<item_id>.Int;
    is %t1_results<items>.head<base_currency_code>, 'USD', 'orders all';

    # GET    /V1/orders/:id
    my %t2_results = orders %config, id => $customer_quote_id;
    is %t2_results<base_currency_code>, 'USD', 'orders by id';
    my $entity_id = %t2_results<billing_address><entity_id>.Int;
    my $parent_id = %t2_results<billing_address><parent_id>.Int;

    # PUT    /V1/orders/:parent_id
    my %t3_data = Sales::orders-address-update(:$entity_id, :$parent_id);

    my %t3_results = 
        orders 
            %config,
            parent_id => $parent_id,
            data      => %t3_data;
    is %t3_results<message>, 'Could not save order address', 'orders update';

    # POST   /V1/orders/
    my %t4_order = orders %config, id => $customer_quote_id;
    my %filtered_order = %t4_order.grep({
        $_.key !~~ 'payment'|'state'|'status'|'status_histories'|'quote_id'|'order_id'|'extension_attributes'
    });

}, 'Orders';

subtest {

    my %t1_order = orders %config, id => $customer_quote_id;
    my %t1_order_new = %t1_order.grep({ $_.key !~~ 'payment'|'status_histories' });
    my %t1_data = %{ entity => %t1_order_new };
    
    # PUT    /V1/orders/create
    my $t1_results =
        orders-create 
            %config,
            data => %t1_data;
    is $t1_results<base_currency_code>, 'USD', 'orders create update';

}, 'Orders create';

subtest {

    # POST   /V1/orders/:id/comments
    my %t1_data = %{
        statusHistory => %{
            comment              => "Delete me comment",
            is_customer_notified => 0,
            is_visible_on_front  => 1
        }
    }

    my $t1_results =
        orders-comments 
            %config,
            id   => $customer_quote_id,
            data => %t1_data;
    is $t1_results, True, 'orders comments new';

    # GET    /V1/orders/:id/comments
    my $t2_results =
        orders-comments 
            %config,
            id => $customer_quote_id;
    is $t2_results<items>.head<comment>, 'Delete me comment', 'orders comments by id';

}, 'Orders comments';

subtest {

    # POST   /V1/orders/:id/emails
    my $t1_results =
        orders-emails 
            %config,
            id => $customer_quote_id;
    is $t1_results, True, 'orders emails new';

}, 'Orders emails';

subtest {

    # GET    /V1/orders/items
    my %t1_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'sku',
                            value => 'P6-SIMPLE-0001',
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
            current_page => 1,
            page_size    => 10
        }
    }

    my $t1_results = orders-items %config, search_criteria => %t1_search_criteria;
    is $t1_results<items>.head<sku>, 'P6-SIMPLE-0001', 'orders items all';
    my $quote_item_id = $t1_results<items>.tail<item_id>.Int;

    # GET    /V1/orders/items/:id
    my $t2_results = orders-items %config, id => $quote_item_id;
    is $t2_results<sku>, 'P6-SIMPLE-0001', 'orders items by item id';

}, 'Orders items';

subtest {

    # POST   /V1/orders/:id/hold
    my $t1_results =
        orders-hold 
            %config,
            id => $customer_quote_id;
    is $t1_results, True, 'orders hold new';

    # POST   /V1/orders/:id/unhold
    my $t2_results =
        orders-unhold 
            %config,
            id => $customer_quote_id;
    is $t2_results, True, 'orders unhold new';

}, 'Orders hold / unhold';

subtest {

    # POST /V1/order/:orderId/ship
    my %t1_data = %{
        entity => %{
            order_id       => $customer_quote_id,
            shipping_label => 'Shipment Label Delete Me',
            items => [
                %{
                    order_item_id => $customer_item_id,
                    qty => 1
                },
            ]
        }
    }

    my $t1_results =
        order-ship 
            %config,
            order_id => $customer_quote_id,
            data    => %t1_data;
    is $t1_results ~~ Int, True, 'order ship new';

}, 'Order ship';

subtest {

    # GET    /V1/orders/:id/statuses
    my $t1_results =
        orders-statuses 
            %config,
            id => $customer_quote_id;
    is $t1_results, 'processing', 'orders statuses by order id';

}, 'Orders statuses';

subtest {

    # POST /V1/order/:orderId/invoice
    my %t1_data = %{
        capture => 'true',
        items => [
            %{
                order_item_id => $customer_item_id,
                qty           => 1
            },
        ],
        notify        => 'false',
        appendComment => 'true',
        comment => %{
            comment             => 'Delete me comment',
            is_visible_on_front => 1
        }
    }

    my $t1_results =
        order-invoice 
            %config,
            order_id => $customer_quote_id,
            data     => %t1_data;
    is $t1_results ~~ Int, True, 'order invoice new';

}, 'Order invoice';

subtest {

    # POST   /V1/invoices/
    my %t1_data = entity => %{
        order_id => $customer_quote_id,
        base_currency_code => 'USD'
    }

    my $t1_results =
        invoices 
            %config,
            data => %t1_data;
    is $t1_results<base_currency_code>, 'USD', 'invoices update';

    # GET    /V1/invoices
    my $t2_results = invoices %config;
    is $t2_results<items>.tail<base_currency_code>, 'USD', 'invoices all';
    $customer_invoice_id = $t2_results<items>.tail<entity_id>.Int;

    # GET    /V1/invoices/:id
    my $t3_results =
        invoices 
            %config,
            id => $customer_invoice_id;
    is $t3_results<base_currency_code>, 'USD', 'invoices by invoice id';


}, 'Invoices';

subtest {

    # revisit
    # POST   /V1/invoices/:id/capture
    my $t1_results =
        invoices-capture 
            %config,
            id => $customer_invoice_id;
    is $t1_results<message>, 'The capture action is not available.', 'invoices capture new';

}, 'Invoices capture';

subtest {

   # POST   /V1/invoices/comments
    my %t1_data = %{
        entity => %{
            parent_id           => $customer_invoice_id,
            comment              => "Delete me comment",
            is_customer_notified => 0,
            is_visible_on_front  => 1
        }
    }

   my $t1_results =
       invoices-comments 
           %config,
           data => %t1_data;
   is $t1_results<comment>, 'Delete me comment', 'invoices comments new';

    # GET    /V1/invoices/:id/comments
    my $t2_results =
        invoices-comments 
            %config,
            id => $customer_invoice_id;
    is $t2_results<items>.head<comment>, 'Delete me comment', 'invoices comments by invoice id';

}, 'Invoices comments';

subtest {

    # POST   /V1/invoices/:id/emails
    my $t1_results = invoices-emails %config, id   => $customer_invoice_id;
    is $t1_results, True, 'invoices emails send';

}, 'Invoices emails';

subtest {

    # POST   /V1/creditmemo
    my %t1_data = %{
        entity => %{
            order_id => $customer_quote_id,
            base_currency_code => 'USD'
        }
    }

    my $t1_results =
        creditmemo 
            %config,
            data => %t1_data;
    is $t1_results<base_currency_code>, 'USD', 'creditmemo new';
    $customer_creditmemo_id = $t1_results<entity_id>.Int;

    # PUT    /V1/creditmemo/:id
    my %t2_data = Sales::creditmemo();

    my $t2_results =
        creditmemo 
            %config,
            id   => $customer_creditmemo_id,
            data => %t1_data;
    is $t2_results<message>, 'You can not cancel Credit Memo', 'creditmemo cancel';

    # GET    /V1/creditmemo/:id
    my $t3_results =
        creditmemo 
            %config,
            id => $customer_creditmemo_id;
    is $t3_results<base_currency_code>, 'USD', 'creditmemo new';

    # GET    /V1/creditmemos
    my $t4_results = creditmemos %config;
    is $t4_results<items>.tail<base_currency_code>, 'USD', 'creditmemos all';

}, 'Creditmemo';

subtest {

    # POST   /V1/creditmemo/:id/comments
    my %t1_data = %{
        entity => %{
            parent_id           => $customer_creditmemo_id,
            comment              => "Delete me comment",
            is_customer_notified => 0,
            is_visible_on_front  => 1
        }
    }

    my $t1_results =
        creditmemo-comments 
            %config,
            id   => $customer_creditmemo_id,
            data => %t1_data;
    is $t1_results<comment>, 'Delete me comment', 'creditmemo comments new';

    # GET    /V1/creditmemo/:id/comments
    my $t2_results =
        creditmemo-comments 
            %config,
            id => $customer_creditmemo_id;
    is $t2_results<items>.head<comment>, 'Delete me comment', 'creditmemo comments by creditmemo id';

}, 'Creditmemo comments';

subtest {

    # POST   /V1/creditmemo/:id/emails
    my $t1_results =
        creditmemo-emails 
            %config,
            id   => $customer_creditmemo_id;
    is $t1_results, True, 'creditmemo emails new';

}, 'Creditmemo emails';

subtest {

    # POST   /V1/shipment/
    my %t1_data = %{
        entity => %{
            order_id       => $customer_quote_id,
            shipping_label => 'Shipment Label Delete Me',
            items => [
                %{
                    order_item_id => $customer_item_id,
                    qty => 1
                },
            ]
        }
    }

    my $t1_results =
        shipment 
            %config,
            data => %t1_data;
    is $t1_results<items>.head<order_item_id>, $customer_item_id, 'shipment new';
    $customer_shipment_id = $t1_results<entity_id>.Int;

    # GET    /V1/shipment/:id
    my $t2_results =
        shipment 
            %config,
            id => $customer_shipment_id;
    is $t2_results<items>.head<order_item_id>, $customer_item_id, 'shipment by shipment id';

    # GET    /V1/shipments
    my $t3_results = shipments %config;
    is $t3_results<items>.tail<items>.head<order_item_id>, $customer_item_id, 'shipments all'; 

}, 'Shipment';

subtest {

    my %t1_data = %{
        entity => %{
            parent_id            => $customer_shipment_id,
            comment              => "Delete me comment",
            is_customer_notified => 0,
            is_visible_on_front  => 1
        }
    }

    my $t1_results = shipment-comments
        %config,
        id   => $customer_shipment_id,
        data => %t1_data;
    is $t1_results<comment>, 'Delete me comment', 'shipment comments new';

    # GET    /V1/shipment/:id/comments
    my $t2_results =
        shipment-comments 
            %config,
            id => $customer_shipment_id;
    is $t2_results<items>.head<comment>, 'Delete me comment', 'shipment comments by shipment id';

}, 'Shipment comments';

#subtest {
#
# revisit, causes fatal error
#
#    # POST   /V1/shipment/:id/emails
#    my $t1_results =
#        shipment-emails 
#            %config,
#            id => $customer_shipment_id;
#            note $t1_results;
#    is True, True, 'shipment emails new';
#
#}, 'Shipment emails';

subtest {

    # GET    /V1/shipment/:id/label
    my $t1_results =
        shipment-label 
            %config,
            id => $customer_shipment_id;
    is $t1_results, 'Shipment Label Delete Me', 'shipment label by shipment id';

}, 'Shipment label';

subtest {

    # POST   /V1/shipment/track
    my %t1_data = %{
        entity => %{
            order_id     => $customer_quote_id,
            parent_id    => $customer_shipment_id,
            weight       => 1,
            qty          => 1,
            description  => 'Shipment Tracking Delete Me',
            track_number => 'P6-SIMPLE-TRACK-001',
            title        => 'Shipment initial track',
            carrier_code => 'flatrate'
        }
    }

    my $t1_results =
        shipment-track 
            %config,
            data => %t1_data;
    is $t1_results<track_number>, 'P6-SIMPLE-TRACK-001', 'shipment track new';
    my $track_id = $t1_results<entity_id>.Int;

    # DELETE /V1/shipment/track/:id
    my $t2_results =
        shipment-track-delete 
            %config,
            id => $track_id;
    is $t2_results ~~ Int, True, 'shipment track delete';

}, 'Shipment track';

subtest {
#
# revist
#
#    # GET    /V1/transactions/:id
#    my $t1_results =
#        transactions 
#            %config,
#            id => '';
#    is True, True, 'transactions by id';
#
    # GET    /V1/transactions
    my $t2_results =
        transactions %config;
    is $t2_results<total_count>, 0, 'transactions all';

}, 'Transactions';

#subtest {
#
#    # POST /V1/invoice/:invoiceId/refund
#    my %t1_data = Sales::invoice-refund();
#
#    my $t1_results =
#        invoice-refund 
#            %config,
#            invoice_id => '',
#        data      => %t1_data;
#    is True, True, 'invoice refund new';
#
#}, 'Invoice refund';
#
#subtest {
#
#    # POST   /V1/invoices/:id/void
#    my %t1_data = Sales::invoices-void();
#
#    my $t1_results =
#        invoices-void 
#            %config,
#            id   => '',
#        data => %t1_data;
#    is True, True, 'invoices void new';
#
#}, 'Invoices void';
#
#subtest {
#
#    # POST /V1/order/:orderId/refund
#    my %t1_data = Sales::order-refund();
#
#    my $t1_results =
#        order-refund 
#            %config,
#            order_id => '',
#        data    => %t1_data;
#    is True, True, 'order refund new';
#
#}, 'Order refund';
#
#subtest {
#
#    # POST   /V1/orders/:id/cancel
#    my %t1_data = Sales::orders-cancel();
#
#    my $t1_results =
#        orders-cancel 
#            %config,
#            id   => '',
#        data => %t1_data;
#    is True, True, 'orders cancel new';
#
#}, 'Orders cancel';

# Cleanup
products-delete %config, sku => 'P6-SIMPLE-0001';

done-testing;
