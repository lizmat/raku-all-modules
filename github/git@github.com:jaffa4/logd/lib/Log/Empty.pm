#require(Exporter);

#@ISA = qw(Exporter);

#@EXPORT =
#  qw(dprint dban);

unit class Log::Empty;
#our  %allowonly; 

has $.enablee is rw;
has $.enablew is rw;
has $.enablei is rw;
has $.enabled is rw;
has $.enablev is rw;
has $.enablep is rw;


has $.enablees is rw;
has $.enablews is rw;
has $.enableis is rw;
has $.enableds is rw;
has $.enablevs is rw;
has $.enableps is rw;

has %bans;

has %allowonly;

has $.o is rw;

has &.prefix is rw;

has $.notify is rw;

method new($output?,:$e,:$w,:$i,:$d,:$v,:$p)
{
  self.bless(o=> $output // $*ERR, enablee => $e,enablew => $w,enablei => $i,enabled => $d,enablev => $v, enablep => $p,
  enablees => $e,enablews => $w,enableis => $i,enableds => $d,enablevs => $v, enableps => $p, prefix => sub { return ""}
  );

}

method enable(*%e)
{
 
}

method allow($section)
{
  
}

method remove_allow($section)
{

}

method ban($section)
{
i
}

method remove_ban($section)
{

}

multi method e($message) 
{
 
}

multi method e($section,$message) 
{
 
}

multi method w($message) 
{
 
}

multi method w($section,$message) 
{

}


multi method i($message) 
{
 
}

multi method i($section,$message) 
{
  
 
}

multi method d($message) 
{
 

 
}

multi method d($section,$message) 
{
 
}

multi method v($message) 
{  
 
}

multi method v($section,$message) 
{
 
}

multi method p($message) 
{
  
}

multi method p($section,$message) 
{
 
}

