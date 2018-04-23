use lib 'lib';
use Test;
use Games::TauStation::DateTime;

plan 31;
with GCT.new: '100.18/05:407 GCT' {
    is .earlier( :cycle),           '099.18/05:407 GCT', ':cycle';
    is .earlier(:3cycles),          '097.18/05:407 GCT', ':3cycles';
    is .earlier(:cycles(-10)),      '110.18/05:407 GCT', ':cycles(-10)';

    is .earlier( :day),             '100.17/05:407 GCT', ':day';
    is .earlier(:3days),            '100.15/05:407 GCT', ':3days';
    is .earlier(:days(-20)),        '100.38/05:407 GCT', ':days(-20)';

    is .earlier( :segment),         '100.18/04:407 GCT', ':segment';
    is .earlier(:3segments),        '100.18/02:407 GCT', ':3segments';
    is .earlier(:3000segments),     '099.88/05:407 GCT', ':3000segments';
    is .earlier(:segments(-10)),    '100.18/15:407 GCT', ':segments(-10)';

    is .earlier( :unit),           '100.18/05:406 GCT', ':unit';
    is .earlier(:3003units),       '100.18/02:404 GCT', ':3003units';
    is .earlier(:units(-10020)),   '100.18/15:427 GCT', ':units(-10020)';

    is .earlier( :second),         .earlier(:units(1/.864)),    ':second';
    is .earlier(:3003seconds),     .earlier(:units(3003/.864)), ':3003seconds';
    is .earlier(:seconds(-10020)), .earlier(:units(-10020/.864)),
        ':seconds(-10020)';

    is .earlier( :minute),         .earlier(:units(60/.864)),    ':minute';
    is .earlier(:3003minutes),     .earlier(:units(60*3003/.864)),
        ':3003minutes';
    is .earlier(:minutes(-10020)), .earlier(:units(-10020*60/.864)),
        ':minutes(-10020)';

    is .earlier( :hour),           .earlier(:units(60*60/.864)),    ':hour';
    is .earlier(:3003hours),       .earlier(:units(60*60*3003/.864)),
        ':3003hours';
    # Here we tweak to account for leap second
    is .earlier(:hours(-10020)),   .earlier(:units(-1-10020*60*60/.864)),
        ':hours(-10020)';

    is .earlier( :week),           .earlier(:units(60*60*24*7/.864)),
        ':week';
    is .earlier(:3weeks),          .earlier(:units(60*60*24*7*3/.864)),
        ':3weeks';
    is .earlier(:weeks(-3)),       .earlier(:units(-60*60*24*7*3/.864)),
        ':weeks(-3)';

    is .earlier( :month),         .earlier(:units(60*60*24*31/.864)),
        ':month';
    is .earlier(:3months),        .earlier(:units((3*31-1)*60*60*24/.864)),
        ':3months';
    is .earlier(:months(-3)),     .earlier(:units(-(3*31-1)*60*60*24/.864)),
        ':months(-3)';

    is .earlier( :year),         .earlier(:units(1+60*60*24*(30*4+31*7+28)/.864)),
        ':year';
    is .earlier(:2years), .earlier(:units(
        2+60*60*24*(30*8+31*14+28*2)/.864)),
        ':2years';
    is .earlier(:years(-1)),
        .earlier(:units(-60*60*24*(30*4+31*7+29)/.864)),
        ':years(-1)';
}
