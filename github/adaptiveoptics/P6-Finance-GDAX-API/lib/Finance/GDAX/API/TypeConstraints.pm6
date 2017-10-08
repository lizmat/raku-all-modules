use v6;

unit module Finance::GDAX::API::TypeConstraints;

my package EXPORT::DEFAULT {

    subset FundingStatus      of Str  where * eq any <outstanding settled rejected>;
    subset MarginTransferType of Str  where * eq any <deposit withdraw>;
    
    subset OrderSelfTradePreventionFlag of Str  where * eq any <dc co cn cb>;
    subset OrderSide                    of Str  where * eq any <buy sell>;
    subset OrderTimeInForce             of Str  where * eq any <GTC GTT IOC FOK>;
    subset OrderType                    of Str  where * eq any <limit market stop>;
    
    subset PositiveInt       of Int  where * > 0;
    subset PositiveNum       of Real where * > 0;
    subset PositiveNumOrZero of Real where * >= 0;
    
    subset ProductLevel of Int where 0 < * < 4;
    subset ReportFormat of Str where * eq any <pdf csv>;
    subset ReportType   of Str where * eq any <fills account>;
}
