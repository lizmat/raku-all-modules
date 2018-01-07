use v6;

use Test;
use lib 'lib', 'xt'.IO.child('lib');
use Magento::Auth;
use Magento::Catalog;
use Magento::Config;
use Products;
use TestLogin;

my %config = TestLogin::admin_config;

my $customer_emai = 'p6magento@fakeemail.com';

subtest {

    my %t1_data = Products::downloadable();
    my %t1_results = products %config, data => %t1_data;
    is %t1_results<name>, 'Downloadable Product Test', 'products new';
    my $t1_product_id  = %t1_results<id>;
    my $t1_product_sku = %t1_results<sku>;

    my %t2_data = Products::simple();
    my %t2_results = products %config, data => %t2_data;
    is %t2_results<name>, 'Simple Product Test', 'products new [linked]';
    my $t2_product_id  = %t2_results<id>;
    my $t2_product_sku = %t2_results<sku>;

    my %t3_data = Products::bundle();
    my %t3_results = products %config, data => %t3_data;
    is %t3_results<name>, 'Bundle Product Test', 'products new [bundle]';
    my $t3_product_id  = %t3_results<id>;
    my $t3_product_sku = %t3_results<sku>;

    my %t4_data = Products::configurable();
    my $t4_results = products %config, data => %t4_data;
    is $t4_results<name>, 'Configurable Product Test', 'products new [configurable]';
    my $t4_product_id  = $t4_results<id>;
    my $t4_product_sku = $t4_results<sku>;

    my %t5_data = Products::downloadable-modified();
    my %t5_results = products %config, sku => 'P6-TEST-0001', data => %t5_data;
    is %t5_results<name>, 'Downloadable Product Test [modified]', 'products update';

    # Create short-lived product
    my %delete_me = Products::delete-me();
    products %config, data => %delete_me;

    my %t6_results = products %config, sku => 'P6-TEST-DELETE';
    is %t6_results<name>, 'Deletable Product', 'products by sku';

    my $t7_results = products-delete %config, sku => 'P6-TEST-DELETE';
    is $t7_results, True, 'products delete';

    my %t8_results = products %config;
    is %t8_results<items>.elems > 0, True, 'products get all';

}, 'Products';

subtest {

    my @t1_results = products-attributes-types %config;
    is @t1_results.elems > 0, True, 'products attributes types';

    my %t2_results = products-attributes %config;
    is %t2_results<items>.defined, True, 'products attributes all';

    my %t3_results = products-attributes %config, attribute_code => 'name';
    is %t3_results<default_frontend_label>, 'Product Name', 'products attributes by attribute_code';

    my %t4_data = Products::product-attribute();
    my %t4_results = products-attributes %config, data => %t4_data;
    is %t4_results<default_frontend_label>, 'delete_me', 'products attributes new';

    # This fails with 'Attribute with the same code'. revisit.
    #my %t5_data = Products::product-attribute-modified();
    #my %t5_results = products-attributes %config, attribute_code => 'deleteme', data => %t5_data;
    #is %t5_results<default_frontend_label>, 'delete_me', 'products attributes modified';

    my $t6_results = products-attributes-delete %config, attribute_code => 'deleteme';
    is $t6_results, True, 'products attributes delete';

}, 'Product attributes';

subtest {

    my %t1_results = categories-attributes %config, attribute_code => 'name';
    is %t1_results<default_frontend_label>, 'Name', 'categories attributes by attribute code';

    my @t2_results = categories-attributes %config;
    is @t2_results.elems > 0, True, 'categories attributes all';

    my @t3_results = categories-attributes-options %config, attribute_code => 'display_mode';
    is @t3_results.elems > 0, True, 'categories attributes options all ';

}, 'Category attributes';

subtest {

    my %t1_results = products-attribute-sets %config;
    is %t1_results<items>.elems > 0, True,'products attribute sets all';

    my %t2_data = Products::products-attribute-set();
    my %t2_results = products-attribute-sets %config, data => %t2_data;
    is %t2_results<attribute_set_name>, 'DeleteMe', 'products attribute sets new';
    my $t2_attribute_set_id = %t2_results<attribute_set_id>;

    my %t3_results = products-attribute-sets %config, attribute_set_id => $t2_attribute_set_id;
    is %t3_results<attribute_set_name>, 'DeleteMe', 'products attribute sets by attribute set id';

    my %t4_data = Products::products-attribute-set-modified();
    my %t4_results = products-attribute-sets %config, attribute_set_id => $t2_attribute_set_id, data => %t4_data;
    is %t4_results<attribute_set_name>, 'DeleteMeModified', 'products attribute sets modified';

    # 
    # Attribute sets
    #

    my %t6_attribute = Products::product-attribute();
    products-attributes %config, data => %t6_attribute;

    my $t5_results = products-attribute-sets-attributes %config, attribute_set_id => $t2_attribute_set_id;
    is so $t5_results.grep({$_<attribute_code>  ~~ 'image'}), True, 'products attribute sets attributes all';

    my %t6_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'attribute_set_id',
                            value => $t2_attribute_set_id,
                            condition_type =>  'eq'
                        },
                    ]
                },
            ],
        }
    }

    my %t6_attribute_groups = products-attribute-groups %config, search_criteria => %t6_search_criteria;

    my %t6_data = %{
        attributeSetId   => $t2_attribute_set_id,
        attributeGroupId => %t6_attribute_groups<items>.head<attribute_group_id>,
        attributeCode    => 'deleteme',
        sortOrder        => 0
    }

    my $t6_results = products-attribute-sets-attributes %config, data => %t6_data;
    is $t6_results > 0, True, 'products attribute sets attributes assign new';

    my $t7_results =
        products-attribute-sets-attributes-delete
            %config,
            attribute_set_id => $t2_attribute_set_id,
            attribute_code   => 'deleteme';
    is $t7_results, True, 'products attribute sets attributes delete';

    products-attributes-delete %config, attribute_code => 'deleteme';

    is products-attribute-sets-delete(%config, attribute_set_id => $t2_attribute_set_id),
           True, 'products attribute sets delete';

}, 'Product attribute sets';

subtest {

    my %t1_attribute_set = Products::products-attribute-set();
    my %t1_attribute_set_results = products-attribute-sets %config, data => %t1_attribute_set;
    my $t1_attribute_set_id = %t1_attribute_set_results<attribute_set_id>.Int;

    my %t1_search_criteria = %{
        searchCriteria => %{
            filterGroups => [
                {
                    filters => [
                        {
                            field => 'attribute_set_id',
                            value => 4,
                            condition_type => 'eq'
                        },
                    ]
                },
            ],
        }
    }

    my %t1_results = products-attribute-groups %config, search_criteria => %t1_search_criteria;
    is %t1_results<items>.head<attribute_group_name>, 'Product Details', 'products attributes groups all';

    # revist, failing with 'Cannot save attribute Group'
    #
    # my %t2_data = Products::products-attribute-group(attribute_set_id => $t1_attribute_set_id);
    # my %t2_results = products-attribute-groups %config, data => %t2_data;
    # is %t2_results<attribute_group_name>, 'Delete Me', 'products attributes groups new';
    # my $t2_group_id = %t2_results<attribute_group_id>;

    # my %t3_data = Products::products-attribute-group-save(attribute_set_id => $t1_attribute_set_id);
    # my %t3_results = products-attribute-groups %config, attribute_set_id => $t1_attribute_set_id, data => %t3_data;
    # is %t3_results<attribute_group_name>, 'Delete Me Too', 'products attributes groups modified';
    # my $t3_group_id = %t3_results<attribute_group_id>;

    # my $fin_result = products-attribute-groups-delete %config, group_id => $t2_group_id;
    # products-attribute-groups-delete %config, group_id => $t3_group_id;
    # is $fin_result, True, 'products attributes groups delete';

    # Cleanup
    products-attribute-sets-delete(%config, attribute_set_id => $t1_attribute_set_id);

}, 'Product attribute groups';

subtest {

    # Get options
    my $t1_results = products-attributes-options %config, attribute_code => 'shipment_type';
    is $t1_results.head<label>, 'Together', 'products attributes options get by attribute code';

    my %t2_attribute_new = Products::product-attribute();
    my %t2_attribute_results = products-attributes %config, data => %t2_attribute_new;

    # New
    my %t2_data = Products::products-attributes-option();
    my $t2_results = products-attributes-options %config, attribute_code => 'deleteme', data => %t2_data;
    is $t2_results, True, 'products attributes options new';

    # Create temporary attribute
    my %t2_attribute = products-attributes %config, attribute_code => 'deleteme';
    my $t2_option_id = %t2_attribute<options>.grep({$_<label> ~~ 'Delete Me'}).head<value>.Int;

    # Delete
    my $t3_results = products-attributes-options-delete %config, attribute_code => 'deleteme', option_id => $t2_option_id;
    is $t3_results, True, 'product attributes options delete';

    # Cleanup temporary attribute
    products-attributes-delete %config, attribute_code => 'deleteme';
}, 'Product attribute options';

subtest {

    my %t1_attribute_set = Products::products-attribute-set();
    my %t1_attribute_set_results = products-attribute-sets %config, data => %t1_attribute_set;
    my $t1_attribute_set_id = %t1_attribute_set_results<attribute_set_id>.Int;
    my $t1_results = products-media-types %config, attribute_set_name => 'DeleteMe';
    is $t1_results.head<attribute_code>, 'image', 'products media types all';

    my $t2_results = products-media %config, sku => 'P6-TEST-0001';
    like $t2_results.head<file>, /'sample-file'/, 'products media by sku';
    
    my %t3_data = Products::products-media();
    my $t3_results = products-media %config, sku => 'P6-TEST-0001', data => %t3_data;
    is $t3_results.elems, 1, 'products media new';
    my $t3_entry_id = $t3_results.head.Int;

    my %t4_data = Products::products-media(entry_id => $t3_entry_id);
    my $t4_results = products-media %config, sku => 'P6-TEST-0001', entry_id => $t3_entry_id, data => %t4_data;
    is $t4_results, True, 'products media modify';

    my $t5_results = products-media-delete %config, sku => 'P6-TEST-0001', entry_id => $t3_entry_id;
    is $t5_results, True, 'products media delete';

    # Cleanup temporary attribute set
    products-attribute-sets-delete %config, attribute_set_id => $t1_attribute_set_id;

}, 'Product media';

subtest {

    my $t1_results =
        products-tier-prices
            %config,
            sku               => 'P6-TEST-0001',
            customer_group_id => 1,
            qty               => 10,
            price             => 12.95;
    is $t1_results, True, 'products tier prices new';

    my $t2_results = products-tier-prices %config, sku => 'P6-TEST-0001', customer_group_id => 1;
    is $t2_results.head<value>, '12.95', 'products tier prices all';

    my $t3_results =
        products-tier-prices-delete
            %config,
            sku               => 'P6-TEST-0001',
            customer_group_id => 1,
            qty               => 10;
    is $t3_results, True, 'products group prices delete';

}, 'Product tier prices';

subtest {

    my %t1_results = categories %config;
    is %t1_results<children_data>.head<name>, 'Default Category', 'categories all';

    my %t2_results = categories(%config, category_id => 1); 
    is %t2_results<name>, 'Root Catalog', 'categories by id';

    my %t3_data = Products::category();
    my %t3_results = categories(%config, data => %t3_data);
    is %t3_results<name>, 'Delete Me', 'categories new';
    my $t3_category_id = %t3_results<id>;

    my %t4_data = category => %( |%t3_results, name => 'Delete Me Modified' );
    my %t4_results = categories(%config, category_id => $t3_category_id, data => %t4_data);
    is %t4_results<name>, 'Delete Me Modified', 'categories update';

    my %t5_data = %{
        parentId => 1,
        afterId  => 1
    }
    my $t5_results = categories-move %config, category_id => $t3_category_id, data => %t5_data;
    is $t5_results, True, 'categories move';

    my $fin_results = categories-delete %config, category_id => $t3_category_id;
    is $fin_results, True, 'categories delete';

}, 'Categories';

subtest {

    my $t1_results = products-options-types %config;
    is $t1_results.grep({$_<code> ~~ 'date'}).head<label>, 'Date', 'products custom options types';

    my %t2_data = Products::products-option();
    my %t2_results = products-custom-options %config, data => %t2_data;
    is %t2_results<title>, 'Delete Me', 'products custom options new';
    my $t2_option_id = %t2_results<option_id>.Int;

    my $t3_results = products-custom-options %config, sku => 'P6-TEST-0001';
    is $t3_results.grep({$_<title> ~~ 'Delete Me'}).head<type>, 'multiple', 'products custom options by sku';

    # Revisit: This is currently not working in Magento, updating a custom option creates a new option
    # https://github.com/magento/magento2/issues/5972
    #my %t4_data = option => %( |%t2_data<option>, isRequire => 'false' );
    #my %t4_results = products-custom-options %config, option_id => $t2_option_id, data => %t4_data;
    #is %t4_results<option_id>, $t2_option_id, 'products custom options update [optionId]';
    #is %t4_results<is_require>, 'False', 'products custom options update [isRequire]';

    my $fin_results = products-custom-options-delete %config, sku => 'P6-TEST-0001', option_id => $t2_option_id;
    is $fin_results, True, 'products custom options delete';
}, 'Product custom options';

subtest {

    my $t1_results = products-links-types %config;
    is $t1_results.head<name>, 'related', 'products links types all';

    my %t2_data = Products::products-links();
    my $t2_results = products-links %config, sku => 'P6-TEST-0001', data => %t2_data;
    is $t2_results, True, 'products links new';

    my $t3_results = products-links %config, sku => 'P6-TEST-0001', type => 'related';
    is $t3_results.head<linked_product_sku>, 'P6-TEST-0002', 'products links by sku and type';

    my %t4_data = Products::products-links-update();
    my $t4_results = products-links-update %config, sku => 'P6-TEST-0001', data => %t4_data;
    is $t4_results, True, 'products links update';

    my $fin_results = products-links-delete %config, sku => 'P6-TEST-0001', type => 'related', linked_product_sku => 'P6-TEST-0002';
    is $fin_results, True, 'products links delete';

}, 'Product links';

subtest {

    my %t1_data = Products::categories-products();
    my $t1_results = categories-products %config, category_id => 2, data => %t1_data;
    is $t1_results, True, 'categories products new';

    my @t2_results = categories-products %config, category_id => 2;
    is @t2_results.elems > 0, True, 'categories products all';

    my %t3_data = Products::categories-products();
    my $t3_results = categories-products-update %config, category_id => 2, data => %t3_data;
    is $t3_results, True, 'categories products update';

    my $t4_results = categories-products-delete %config, category_id => 2, sku => 'P6-TEST-0001';
    is $t4_results, True, 'categories products delete';

}, 'Categories products';

subtest {

    my %t1_data = productWebsiteLink => %{
        sku       => 'P6-TEST-0001',
        websiteId => 1 
    }

    my $t1_results = products-websites %config, sku => 'P6-TEST-0001', data => %t1_data;
    is $t1_results, True, 'products websites new';

    my $t2_results = products-websites-update %config, sku => 'P6-TEST-0001', data => %t1_data;
    is $t2_results, True, 'products websites update';

    my $fin_results = products-websites-delete %config, sku => 'P6-TEST-0001', website_id => 1;
    is $fin_results, True, 'products websites delete';

}, 'Product websites';

subtest {
    for ['P6-TEST-0001', 'P6-TEST-0002', 'P6-TEST-0003', 'P6-TEST-0004'] {
        products-delete %config, sku => $_
    }
}, 'Cleanup';

done-testing;
