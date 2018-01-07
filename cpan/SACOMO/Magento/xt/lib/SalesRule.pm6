use v6;
use Base64;

unit module SalesRule;

our sub coupons(
    :$rule_id  
) {
    coupon => %{
        ruleId    => $rule_id,
        code      => 'DeleteMeCouponTest',
        timesUsed => 0,
        isPrimary => 1,
        type      => 0
    }
}

our sub sales-rules {
    rule => %{
        name                => 'DeleteMeSalesRuleTest',
        websiteIds          => [ 0, 1 ],
        customerGroupIds    => [ 0, 1 ],
        usesPerCustomer     => 1,
        isActive            => 'true',
        stopRulesProcessing => 'false',
        isAdvanced          => 'true',
        sortOrder           => 0,
        simpleAction        => 'by_percent',
        discountAmount      => 4,
        discountStep        => 0,
        applyToShipping     => 'true',
        timesUsed           => 0,
        isRss               => 'true',
        couponType          => 'specific',
        useAutoGeneration   => 'false',
        usesPerCoupon       => 1
    }
}

our sub sales-rules-generated {
    rule => %{
        name                => 'DeleteMeSalesRuleGenerated',
        websiteIds          => [ 0, 1 ],
        customerGroupIds    => [ 0, 1 ],
        usesPerCustomer     => 1,
        isActive            => 'true',
        stopRulesProcessing => 'false',
        isAdvanced          => 'true',
        sortOrder           => 0,
        simpleAction        => 'by_percent',
        discountAmount      => 4,
        discountStep        => 0,
        applyToShipping     => 'true',
        timesUsed           => 0,
        isRss               => 'true',
        couponType          => 'specific',
        useAutoGeneration   => 'true',
        usesPerCoupon       => 1
    }
}
