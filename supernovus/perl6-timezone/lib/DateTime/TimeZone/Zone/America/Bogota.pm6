use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Bogota does DateTime::TimeZone::Zone;
has %.rules = ( 
 CO => [{:adjust("1:00"), :date("3"), :letter("S"), :month(5), :time("0:00"), :years(1992..1992)}, {:adjust("0"), :date("4"), :letter("-"), :month(4), :time("0:00"), :years(1993..1993)}],
);
has @.zonedata = [{:baseoffset("-4:56:16"), :rules(""), :until(-2707689600)}, {:baseoffset("-4:56:16"), :rules(""), :until(-1739059200)}, {:baseoffset("-5:00"), :rules("CO"), :until(Inf)}]<>;
