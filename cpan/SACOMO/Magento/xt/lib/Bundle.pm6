use v6;
use Base64;

unit module Bundle;

our sub simple(
    :$sku = 'P6-SIMPLE-0001'
) {
    product => %{
        sku            => $sku,
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
        }
    }
}

our sub bundle() {
    product => %{
        sku            => 'P6-BUNDLE-0001',
        name           => 'Bundle Product Test',
        typeId         => 'bundle',
        attributeSetId => 4,
        price          => 19.95,
        status         => 1,
        visibility     => 1,
        weight         => 1.5,
        customAttributes => [
            %{
                attributeCode => 'price_view',
                value         => 0
            },
        ],
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
          bundleProductOptions => [
              %{
                  title         => 'Simple Bundle',
                  type          => 'select',
                  required      => 'true',
                  position      => 0,
                  sku           => 'BUNDLE-SIMPLE-0002',
                  productLinks  => [   # simple / virtual products only
                     %{
                          sku               => 'P6-SIMPLE-0001',
                          position          => 0,
                          isDefault         => 'true',
                          canChangeQuantity => 0
                      },
                  ],
              },
          ]
        },
        options => [
            %(
                productSku    => 'P6-BUNDLE-0001',
                title         => 'Color',
                type          => 'multiple',
                sortOrder     =>  0,
                isRequire     => 'true',
                values => [
                  %{
                    title       => 'Green',
                    sortOrder   =>  0,
                    price       =>  0,
                    priceType   => 'fixed'
                  },
                  %{
                    title       => 'Blue',
                    sortOrder   =>  1,
                    price       =>  0,
                    priceType   => 'fixed'
                  },
                  %{
                    title       => 'Gold',
                    sortOrder   =>  2,
                    price       =>  10.00,
                    priceType   => 'fixed'
                  }
                ]
            ),
        ],
    }
}

our sub bundle-products-links {
    linkedProduct  => %{   # simple / virtual products only
        sku               => 'P6-SIMPLE-0002',
        position          => 0,
        isDefault         => 'false',
        canChangeQuantity => 0
    }
}

our sub bundle-products-options {
    option => %{
        sku      => 'P6-BUNDLE-0001',
        title    => 'Color',
        type     => 'multiple',
        required => 'true'
    }
}

our sub bundle-products-options-add {
    %();
}

