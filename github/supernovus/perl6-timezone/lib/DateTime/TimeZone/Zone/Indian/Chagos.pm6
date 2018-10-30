use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Chagos does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("4:49:40"), :rules(""), :until(-1988150400)}, {:baseoffset("5:00"), :rules(""), :until(820454400)}, {:baseoffset("6:00"), :rules(""), :until(Inf)}]<>;
