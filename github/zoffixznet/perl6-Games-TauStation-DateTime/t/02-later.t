use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 31;
with GCT.new: '100.18/05:407 GCT' {
    is .later( :cycle),      '101.18/05:407 GCT', ':cycle';
    is .later(:3cycles),     '103.18/05:407 GCT', ':3cycles';
    is .later(:cycles(-10)), '090.18/05:407 GCT', ':cycles(-10)';

    is .later( :day),      '100.19/05:407 GCT', ':day';
    is .later(:3days),     '100.21/05:407 GCT', ':3days';
    is .later(:days(-20)), '099.98/05:407 GCT', ':days(-20)';

    is .later( :segment),      '100.18/06:407 GCT', ':segment';
    is .later(:3segments),     '100.18/08:407 GCT', ':3segments';
    is .later(:3000segments),  '100.48/05:407 GCT', ':3000segments';
    is .later(:segments(-10)), '100.17/95:407 GCT', ':segments(-10)';

    is .later( :unit),         '100.18/05:408 GCT', ':unit';
    is .later(:3003units),     '100.18/08:410 GCT', ':3003units';
    is .later(:units(-10020)), '100.17/95:387 GCT', ':units(-10020)';

    is .later( :second),         .later(:units(1/.864)),    ':second';
    is .later(:3003seconds),     .later(:units(3003/.864)), ':3003seconds';
    is .later(:seconds(-10020)), .later(:units(-10020/.864)),
        ':seconds(-10020)';

    is .later( :minute),         .later(:units(60/.864)),    ':minute';
    is .later(:3003minutes),     .later(:units(60*3003/.864)),
        ':3003minutes';
    is .later(:minutes(-10020)), .later(:units(-10020*60/.864)),
        ':minutes(-10020)';

    is .later( :hour),           .later(:units(60*60/.864)),    ':hour';
    is .later(:3003hours),       .later(:units(60*60*3003/.864)),
        ':3003hours';
    # Here we tweak to account for leap second
    is .later(:hours(-10020)),   .later(:units(-1-10020*60*60/.864)),
        ':hours(-10020)';

    is .later( :week),           .later(:units(60*60*24*7/.864)),
        ':week';
    is .later(:3weeks),          .later(:units(60*60*24*7*3/.864)),
        ':3weeks';
    # Here we tweak to account for leap seconds
    is .later(:weeks(-10020)), .later(:units(-19-10020*60*60*24*7/.864)),
        ':weeks(-10020)';

    is .later( :month),         .later(:units(60*60*24*30/.864)),
        ':month';
    is .later(:3months), .later(:units(
        (3*31-1)*60*60*24/.864)),
        ':3months';
    is .later(:months(-10020)), GCT.new('-2949.58/94:612 GCT'),
        ':months(-10020)';

    is .later( :year),         .later(:units(60*60*24*(30*4+31*7+29)/.864)),
        ':year';
    is .later(:2years), .later(:units(
        1+60*60*24*(30*8+31*14+29+28)/.864)),
        ':2years';
    is .later(:years(-10020)), GCT.new('-36497.11/94:612 GCT'),
        ':years(-10020)';
}
