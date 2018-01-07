use v6;
use Base64;

unit module Downloadable;

our sub downloadable() {
    product => %{
        sku            => 'P6-DOWNLOADABLE-0001',
        name           => 'Downloadable Product Test',
        typeId         => 'downloadable',
        attributeSetId => 4,
        price          => 19.95,
        status         => 1,
        visibility     => 1,
        weight         => 1.5,
        extensionAttributes => %{
            downloadableProductLinks => [
                %{
                    title             => 'Downloadable Test',
                    sortOrder         => 0,
                    isShareable       => 1,
                    price             => 4.99,
                    numberOfDownloads => 100,
                    linkType          => 'file',
                    linkFile          => 'xt'.IO.child('assets').child('link-file.gif').path,
                    sampleFileContent => %{
                        fileData => encode-base64(slurp('xt'.IO.child('assets').child('sample-file.png'), :bin), :str),
                        name     => 'sample-file.png'
                    },
                },
            ],
            downloadableProductSamples => [
                %{
                    title      => 'Downloadable Product Sample Test',
                    sortOrder  => 0,
                    sampleType => 'url',
                    sampleUrl  => 'https://raw.githubusercontent.com/scmorrison/perl6-Magento/master/xt/assets/downloadable-sample-file.gif'
                },
            ],
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
        options => [
            %(
                productSku    => 'P6-DOWNLOADABLE-0001',
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
        mediaGalleryEntries => [
            %{
                mediaType  => 'image',
                label      => 'Media File',
                position   => 0,
                disabled   => 'false',
                content => %{
                  base64EncodedData => encode-base64(slurp('xt'.IO.child('assets').child('sample-file.png'), :bin), :str),
                  type => 'image/png',
                  name => 'sample-file.png'
                },
            },
        ],
    }
}

our sub products-downloadable-links {
    link => %{
        title             => 'Downloadable Test',
        sortOrder         => 0,
        isShareable       => 1,
        price             => 4.99,
        numberOfDownloads => 100,
        link_type         => 'url',
        link_url          => 'https://raw.githubusercontent.com/scmorrison/perl6-Magento/master/xt/assets/downloadable-sample-file.gif'
    }

}

our sub products-downloadable-links-samples {
    sample => %{
        title      => 'Downloadable Product Sample Test',
        sortOrder  => 0,
        sampleType => 'url',
        sampleUrl  => 'https://raw.githubusercontent.com/scmorrison/perl6-Magento/master/xt/assets/downloadable-sample-file.gif'
    }
}

