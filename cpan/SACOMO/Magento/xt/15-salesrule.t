use v6;

# These tests are meant to run against
# live development system. Do not run
# this against a production system.

use Test;
use lib 'lib', 'xt'.IO.child('lib');

use Magento::Auth;
use Magento::Config;
use Magento::SalesRule;
use SalesRule;
use TestLogin;

my %config = TestLogin::admin_config;
my $rule_id;
my $rule_id_generated;

subtest {

    # POST   /V1/salesRules
    my %t1_data = SalesRule::sales-rules();

    my $t1_results =
        sales-rules 
            %config,
            data => %t1_data;
    is $t1_results<name>, 'DeleteMeSalesRuleTest', 'sales rules new';
    $rule_id = $t1_results<rule_id>.Int;

    # GET    /V1/salesRules/:ruleId
    my $t2_results =
        sales-rules 
            %config,
            rule_id => $rule_id;
    is $t2_results<name>, 'DeleteMeSalesRuleTest', 'sales rules by id';

    # PUT    /V1/salesRules/:ruleId
    my %t3_data = SalesRule::sales-rules();

    my $t3_results =
        sales-rules 
            %config,
            rule_id => $rule_id,
            data    => %t1_data;
    is $t2_results<name>, 'DeleteMeSalesRuleTest', 'sales rules update';

}, 'Sales rules';

subtest {

    # GET    /V1/salesRules/search
    my $t1_results = sales-rules-search %config;
    is so $t1_results<items>.grep({$_<name> ~~ 'DeleteMeSalesRuleTest'}), True, 'sales rules-search all';

}, 'Sales rules-search';

subtest {


    # POST   /V1/coupons
    my %t1_data = SalesRule::coupons(:$rule_id);

    my $t1_results =
        coupons 
            %config,
            data => %t1_data;
    is $t1_results<code>, 'DeleteMeCouponTest', 'coupons new';
    my $coupon_id = $t1_results<coupon_id>.Int;

    # GET    /V1/coupons/:couponId
    my $t2_results =
        coupons 
            %config,
            coupon_id => $coupon_id;
    is $t2_results<code>, 'DeleteMeCouponTest', 'coupons by id';

    # PUT    /V1/coupons/:couponId
    my $t3_results =
        coupons 
            %config,
            coupon_id => $coupon_id,
            data      => %t1_data;
    is $t2_results<code>, 'DeleteMeCouponTest', 'coupons update';

    # DELETE /V1/coupons/:couponId
    my $t4_results =
        coupons-delete 
            %config,
            coupon_id => $coupon_id;
    is $t4_results, True, 'coupons delete';

}, 'Coupons';

subtest {

    my %coupon_data = SalesRule::coupons(:$rule_id);

    my $coupon =
        coupons 
            %config,
            data => %coupon_data;

    # POST   /V1/coupons/deleteByCodes
    my %t1_data = %{
        codes => [
            'DeleteMeCouponTest',
        ]
    }

    my $t1_results =
        coupons-delete-by-codes 
            %config,
            data => %t1_data;
    is $t1_results<failed_items>.elems, 0, 'coupons delete-by-codes';

}, 'Coupons delete-by-codes';

subtest {

    my %coupon_data = SalesRule::coupons(:$rule_id);

    my $coupon =
        coupons 
            %config,
            data => %coupon_data;

    # POST   /V1/coupons/deleteByIds
    my %t1_data = %{
        ids => [
            $coupon<coupon_id>.Int,
        ]
    }

    my $t1_results =
        coupons-delete-by-ids 
            %config,
            data => %t1_data;
    is $t1_results<failed_items>.elems, 0, 'coupons delete-by-ids';

}, 'Coupons delete-by-ids';

subtest {

    my %sales_rule_generated = SalesRule::sales-rules-generated();
    $rule_id_generated = sales-rules(%config, data => %sales_rule_generated)<rule_id>.Int;

    # POST   /V1/coupons/generate
    my %t1_data = %{
        couponSpec => %{
            rule_id  => $rule_id_generated,
            format   => 'alphanum',
            quantity => 10,
            length   => 10
        }
    }

    my $t1_results =
        coupons-generate 
            %config,
            data => %t1_data;
    is $t1_results.elems, 10, 'coupons generate new';

}, 'Coupons generate';

subtest {

    # GET    /V1/coupons/search
    my $t1_results = coupons-search %config;
    is $t1_results<items> ~~ Array, True, 'coupons search all';

}, 'Coupons search';

subtest {

    # DELETE /V1/salesRules/:ruleId
    my $t4_results =
        sales-rules-delete 
            %config,
            rule_id => $rule_id;
    is $t4_results, True, 'sales rules delete';

    sales-rules-delete 
        %config,
        rule_id => $rule_id_generated;

}, 'Cleanup';

done-testing;
