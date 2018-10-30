use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Antarctica::Casey does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0"), :rules(""), :until(-31536000)}, {:baseoffset("8:00"), :rules(""), :until(1255831200)}, {:baseoffset("11:00"), :rules(""), :until(1267754400)}, {:baseoffset("8:00"), :rules(""), :until(1319767200)}, {:baseoffset("11:00"), :rules(""), :until(1329843600)}, {:baseoffset("8:00"), :rules(""), :until(Inf)}]<>;
