use v6;
use Base64;

unit module GiftMessage;

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
        sku => 'P6-SIMPLE-0001',
        qty => 1,
        quoteId => "$quote_id"
    }
}

our sub gift-message {
    giftMessage => %{
        sender  => 'Camelia',
        message => 'Delete me message'
    }
}
