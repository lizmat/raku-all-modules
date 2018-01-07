use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::Eav;
use Eav;
use TestLogin;

my %config = TestLogin::admin_config;

subtest {

    # GET    /V1/eav/attribute-sets/:attributeSetId
    my $t1_results =
        eav-attribute-sets 
            %config,
            attribute_set_id => 1;
    is $t1_results<attribute_set_name>, 'Default', 'eav attribute-sets by attribute_set_id';

    # POST   /V1/eav/attribute-sets
    my %t2_data = Eav::eav-attribute-sets();

    my $t2_results =
        eav-attribute-sets 
            %config,
            data => %t2_data;
    is $t2_results<attribute_set_name>, 'DeleteMe', 'eav attribute-sets new';

    # PUT    /V1/eav/attribute-sets/:attributeSetId
    my %t3_data = Eav::eav-attribute-sets-update();

    my $t3_results =
        eav-attribute-sets 
            %config,
            attribute_set_id => $t2_results<attribute_set_id>.Int,
            data             => %t3_data;
    is $t3_results<attribute_set_name>, 'DeleteMeModified', 'eav attribute-sets update';

    # DELETE /V1/eav/attribute-sets/:attributeSetId
    my $t4_results =
        eav-attribute-sets-delete 
            %config,
            attribute_set_id => $t2_results<attribute_set_id>.Int;
    is $t4_results, True, 'eav attribute-sets delete';

}, 'Eav attribute-sets';

subtest {

    # GET    /V1/eav/attribute-sets/list
    my $t1_results = eav-attribute-sets-list %config;
    is so $t1_results<items>.grep({ $_<attribute_set_name> ~~ 'Default' }), True, 'eav attribute-sets-list all';

}, 'Eav attribute-sets-list';

done-testing;
