use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Antarctica::DumontDUrville does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0"), :rules(""), :until(-725846400)}, {:baseoffset("10:00"), :rules(""), :until(-566956800)}, {:baseoffset("0"), :rules(""), :until(-441849600)}, {:baseoffset("10:00"), :rules(""), :until(Inf)}]<>;
