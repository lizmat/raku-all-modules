use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Rangoon does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("6:24:40"), :rules(""), :until(-2840140800)}, {:baseoffset("6:24:40"), :rules(""), :until(-1577923200)}, {:baseoffset("6:30"), :rules(""), :until(-883612800)}, {:baseoffset("9:00"), :rules(""), :until(-778377600)}, {:baseoffset("6:30"), :rules(""), :until(Inf)}]<>;
