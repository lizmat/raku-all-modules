use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Accra does DateTime::TimeZone::Zone;
has %.rules = ( 
 Ghana => [{:adjust("0:20"), :date("1"), :letter("GHST"), :month(9), :time("0:00"), :years(1936..1942)}, {:adjust("0"), :date("31"), :letter("GMT"), :month(12), :time("0:00"), :years(1936..1942)}],
);
has @.zonedata = [{:baseoffset("-0:00:52"), :rules(""), :until(-1640995200)}, {:baseoffset("0:00"), :rules("Ghana"), :until(Inf)}]<>;
