use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Antarctica::Davis does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0"), :rules(""), :until(-409190400)}, {:baseoffset("7:00"), :rules(""), :until(-189388800)}, {:baseoffset("0"), :rules(""), :until(-31536000)}, {:baseoffset("7:00"), :rules(""), :until(1255831200)}, {:baseoffset("5:00"), :rules(""), :until(1268251200)}, {:baseoffset("7:00"), :rules(""), :until(1319767200)}, {:baseoffset("5:00"), :rules(""), :until(1329854400)}, {:baseoffset("7:00"), :rules(""), :until(Inf)}]<>;
