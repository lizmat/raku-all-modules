use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Kolkata does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("5:53:28"), :rules(""), :until(-2840140800)}, {:baseoffset("5:53:20"), :rules(""), :until(-915148800)}, {:baseoffset("6:30"), :rules(""), :until(-872035200)}, {:baseoffset("5:30"), :rules(""), :until(-883612800)}, {:baseoffset("6:30"), :rules(""), :until(-764121600)}, {:baseoffset("5:30"), :rules(""), :until(Inf)}]<>;
