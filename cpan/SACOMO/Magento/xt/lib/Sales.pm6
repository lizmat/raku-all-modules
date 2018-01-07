use v6;
use Base64;

unit module Sales;

our sub creditmemo {
	entity => %{
        orderId => 0,
        items   => [

        ]
	}
}

our sub simple() {
    product => %{
        sku            => 'P6-SIMPLE-0001',
        name           => 'Simple Product Test',
        attributeSetId => 4,
        price          => 19.95,
        status         => 1,
        visibility     => 1,
        weight         => 1.5,
        extensionAttributes => %{
            stockItem => %{
                qty                      => 100,
                isInStock                => 'true',
                isQtyDecimal             => 'true',
                useConfigMinQty          => 'true',
                minQty                   => 10,
                useConfigMinSaleQty      => 1,
                minSaleQty               => 1,
                useConfigMaxSaleQty      => 'true',
                maxSaleQty               => 5,
                useConfigBackorders      => 'true',
                backorders               => 0,
                useConfigNotifyStockQty  => 'true',
                notifyStockQty           => 0,
                useConfigQtyIncrements   => 'true',
                qtyIncrements            => 0,
                useConfigEnableQtyInc    => 'true',
                enableQtyIncrements      => 'true',
                useConfigManageStock     => 'true',
                manageStock              => 'true'
            },
        },
    }
}

our sub carts-items(
    :$quote_id
) {
    cartItem  => %{
        sku      => 'P6-SIMPLE-0001',
        qty      => 1,
        quote_id => $quote_id
    }
}

our sub creditmemo-comments {
    %();
}

our sub creditmemo-emails {
    %();
}

our sub invoice-refund {
    %();
}

our sub invoices {
    %();
}

our sub invoices-capture {
    %();
}

our sub invoices-comments {
    %();
}

our sub invoices-emails {
    %();
}

our sub invoices-void {
    %();
}

our sub order-invoice {
    %();
}

our sub order-refund {
    %();
}

our sub orders(
    Str :$email = 'p6magento@fakeemail.com'
) {
    entity => %{
        base_grand_total              => 220.Int,
        base_shipping_amount          => 10.Int,
        base_shipping_discount_amount => 0.Int,
        base_shipping_incl_tax        => 10.Int,
        base_shipping_invoiced        => 10.Int,
        base_shipping_tax_amount      => 0.Int,
        base_subtotal                 => 210.Int,
        base_subtotal_incl_tax        => 210.Int,
        base_subtotal_invoiced        => 210.Int,
        base_tax_amount               => 0.Int,
        base_tax_invoiced             => 0.Int,
        base_to_global_rate           => 1.Int,
        base_to_order_rate            => 1.Int,
        base_total_due                => 0.Int,
        base_total_invoiced           => 220.Int,
        base_total_invoiced_cost      => 0.Int,
        base_total_paid               => 220.Int,
        billing_address               => {
            addressType        => "billing".Str,
            #parentId           => 1,
            firstname          => 'Camelia',
            lastname           => 'Butterfly',
            postcode           => '90211',
            city               => 'Beverly Hills',
            street             => ['Zoe Ave'],
            regionId           => 12,
            countryId          => 'US',
            telephone          => '555-555-5555',
            email              => $email
        },
        customer_email                => $email,
        grand_total                   => 220,
        items                         => [
            {
                amount_refunded                         => 0.Int,
                base_amount_refunded                    => 0.Int,
                base_discount_amount                    => 0.Int,
                base_discount_invoiced                  => 0.Int,
                base_discount_tax_compensation_amount   => 0.Int,
                base_discount_tax_compensation_invoiced => 0.Int,
                base_original_price                     => 105.Int,
                base_price                              => 105.Int,
                base_price_incl_tax                     => 105.Int,
                base_row_invoiced                       => 210.Int,
                base_row_total                          => 210.Int,
                base_row_total_incl_tax                 => 210.Int,
                base_tax_amount                         => 0.Int,
                base_tax_invoiced                       => 0.Int,
                discount_amount                         => 0.Int,
                discount_invoiced                       => 0.Int,
                discount_percent                        => 0.Int,
                discount_tax_compensation_amount        => 0.Int,
                discount_tax_compensation_invoiced      => 0.Int,
                free_shipping                           => 0.Int,
                is_qty_decimal                          => 0.Int,
                is_virtual                              => 0.Int,
                item_id                                 => 1.Int,
                no_discount                             => 0.Int,
                original_price                          => 105.Int,
                price                                   => 105.Int,
                price_incl_tax                          => 105.Int,
                product_id                              => 1.Int,
                product_type                            => "simple".Str,
                qty_canceled                            => 0.Int,
                qty_invoiced                            => 2.Int,
                qty_ordered                             => 2.Int,
                qty_refunded                            => 0.Int,
                qty_shipped                             => 2.Int,
                #quote_item_id                           => 1.Int,
                row_invoiced                            => 210.Int,
                row_total                               => 210.Int,
                row_total_incl_tax                      => 210.Int,
                row_weight                              => 2.Int,
                sku                                     => 'P6-TEST-DELETE',
                store_id                                => 1.Int,
                tax_amount                              => 0.Int,
                tax_invoiced                            => 0.Int,
                tax_percent                             => 0.Int,
                weight                                  => 1.Int,
            },
        ],
        shipping_amount                           => 10.Int,
        shipping_description                      => "Flat Rate - Fixed".Str,
        shipping_discount_amount                  => 0.Int,
        shipping_discount_tax_compensation_amount => 0.Int,
        shipping_incl_tax                         => 10.Int,
        shipping_invoiced                         => 10.Int,
        shipping_tax_amount                       => 0.Int,
        store_currency_code                       => "USD".Str,
        store_id                                  => 1.Int,
        store_name                                => "Main Website\nMain Website Store\n".Str,
        store_to_base_rate                        => 0.Int,
        store_to_order_rate                       => 0.Int,
        subtotal                                  => 210.Int,
        subtotal_incl_tax                         => 210.Int,
        subtotal_invoiced                         => 210.Int,
        tax_amount                                => 0.Int,
        tax_invoiced                              => 0.Int,
        total_due                                 => 0.Int,
        total_invoiced                            => 220.Int,
        total_item_count                          => 1.Int,
        total_paid                                => 220.Int,
        total_qty_ordered                         => 2.Int,
        weight                                    => 2.Int,
    }

}

our sub orders-address-update(
    Int :$entity_id,
    Int :$parent_id
) {
    entity => %{
        entityId      => $entity_id,
        parentId      => $parent_id,
        customerAddressId => 1,
        #customerId    => $customer_id,
        firstname     => 'Camelia',
        lastname      => 'Butterfly',
        postcode      => '90211',
        city          => 'Beverly Hills',
        street        => ['Zoe Ave'],
        regionId      => 12,
        countryId     => 'US',
        telephone     => '555-555-5555'
        #useForShipping => 'true'
    }
}

our sub orders-cancel {
    %();
}

our sub orders-comments {
    %();
}

our sub orders-create {
    %();
}

our sub orders-emails {
    %();
}

our sub order-ship {
    %();
}

our sub orders-hold {
    %();
}

our sub orders-unhold {
    %();
}

our sub shipment {
    %();
}

our sub shipment-comments {
    %();
}

our sub shipment-emails {
    %();
}

our sub shipment-track {
    %();
}

