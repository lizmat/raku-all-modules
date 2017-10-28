use v6;
use RakudoPrereq v2017.10, '', 'rakudo-only no-where';
use NativeCall;
use Parse::STDF::Native;

unit class Parse::STDF;

# Exception classes specific to Parse::STDF 
package GLOBAL::X::Parse::STDF 
{
  role X::Parse::STDF { }
  class UnableToOpen does X::Parse::STDF is Exception
  { 
    has $.stdf;
    method message() { "Parse::STDF: unable to open $.stdf" };
  }
  class NotFound does X::Parse::STDF is Exception
  { 
    has $.stdf;
    method message() { "Parse::STDF: $.stdf not found" };
  }
  class LibraryMissing does X::Parse::STDF is Exception
  {
    has $.library;
    method message() { "Parse::STDF: needs $.library, not found" };
  }
}

has $.stdf;
has $!f = stdf_open($!stdf) || X::Parse::STDF::UnableToOpen.new(:$!stdf).fail; # internal file handle
has $!rec;
has $.recname;
has $.header; # generic for all STDF record types

method new(:$stdf is required)
{
  # First native call is done here, can trigger X::AdHoc if libstdf is missing.
  CATCH 
  {
    when $_.message ~~ m/
    ^ "Cannot locate native library "
    ( "'" <-[ ' ]> * "'" ) 
    /
    {
      X::Parse::STDF::LibraryMissing.new(:library($/[0])).fail;
    }
  }
  ( $stdf.IO.e ) || X::Parse::STDF::NotFound.new(:$stdf).fail;
  self.bless(:$stdf);
}

submethod DESTROY
{
  stdf_close($!f) if ( $!f.defined );
}

method get_record
{
  $!rec = stdf_read_record($!f);
  if ( $!rec.defined )
  {
    $!header = $!rec.deref.header;
    $!recname = stdf_get_rec_name($!header.REC_TYP, $!header.REC_SUB);
  }
  return ($!rec.defined);
}

method ver
{
  stdf_get_setting($!f,STDF_SETTING_VERSION, my uint32 $ver);
  return ( $ver );
}

=begin comment
  Use of nativecast has the same effect of type casting in C.  This type-casting strategy is
  exactly how its done for c programs which use libstdf APIs.  See libstdf examples for more detail.
=end comment

method mir { return ( nativecast(Pointer[rec_mir],$!rec).deref ); }
method dtr { return ( nativecast(Pointer[rec_dtr],$!rec).deref ); }
method sdr { return ( nativecast(Pointer[rec_sdr],$!rec).deref ); }
method pcr { return ( nativecast(Pointer[rec_pcr],$!rec).deref ); }
method mrr { return ( nativecast(Pointer[rec_mrr],$!rec).deref ); }
method prr { return ( nativecast(Pointer[rec_prr],$!rec).deref ); }
method ptr { return ( nativecast(Pointer[rec_ptr],$!rec).deref ); }
method pir { return ( nativecast(Pointer[rec_pir],$!rec).deref ); }
method wir { return ( nativecast(Pointer[rec_wir],$!rec).deref ); }
method far { return ( nativecast(Pointer[rec_far],$!rec).deref ); }
method gdr { return ( nativecast(Pointer[rec_gdr],$!rec).deref ); }
method atr { return ( nativecast(Pointer[rec_atr],$!rec).deref ); }
method hbr { return ( nativecast(Pointer[rec_hbr],$!rec).deref ); }
method sbr { return ( nativecast(Pointer[rec_sbr],$!rec).deref ); }
method pmr { return ( nativecast(Pointer[rec_pmr],$!rec).deref ); }
method pgr { return ( nativecast(Pointer[rec_pgr],$!rec).deref ); }
method plr { return ( nativecast(Pointer[rec_plr],$!rec).deref ); }
method rdr { return ( nativecast(Pointer[rec_rdr],$!rec).deref ); }
method wrr { return ( nativecast(Pointer[rec_wrr],$!rec).deref ); }
method wcr { return ( nativecast(Pointer[rec_wcr],$!rec).deref ); }
method tsr { return ( nativecast(Pointer[rec_tsr],$!rec).deref ); }
method mpr { return ( nativecast(Pointer[rec_mpr],$!rec).deref ); }
method ftr { return ( nativecast(Pointer[rec_ftr],$!rec).deref ); }
method bps { return ( nativecast(Pointer[rec_bps],$!rec).deref ); }
method eps { return ( nativecast(Pointer[rec_eps],$!rec).deref ); }

=begin pod

=head1 NAME

Parse::STDF - Module for parsing files in Standard Test Data Format

=head1 SYNOPSIS


  use Parse::STDF;

  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    while $s.get_record
    {
      given ( $s.recname )
      {
        when "MIR"
        {
          my $mir = $s.mir; 
          printf("Started At: %s\n", $mir.START_T.ctime);
          printf("Station Number: %d\n", $mir.STAT_NUM);
          printf("Station Mode: %s\n", $mir.MODE_COD.chr);
          printf("Retst_Code: %s\n", $mir.RTST_COD.chr);
          printf("Lot: %s\n", $mir.LOT_ID.cnstr);
          printf("Part Type: %s\n", $mir.PART_TYP.cnstr);
          printf("Node Name: %s\n", $mir.NODE_NAM.cnstr);
          printf("Tester Type: %s\n", $mir.TSTR_TYP.cnstr);
          printf("Program: %s\n", $mir.JOB_NAM.cnstr); 
          printf("Version: %s\n", $mir.JOB_REV.cnstr);
          printf("Sublot: %s\n", $mir.SBLOT_ID.cnstr);
          printf("Operator: %s\n", $mir.OPER_NAM.cnstr);
          printf("Executive: %s\n", $mir.EXEC_TYP.cnstr);
          printf("Test Code: %s\n", $mir.TEST_COD.cnstr);
          printf("Test Temperature: %s\n", $mir.TST_TEMP.cnstr);
          printf("Package Type: %s\n", $mir.PKG_TYP.cnstr);
          printf("Facility ID: %s\n", $mir.FACIL_ID.cnstr);
          printf("Design Revision: %s\n", $mir.DSGN_REV.cnstr);
          printf("Flow ID: %s\n", $mir.FLOW_ID.cnstr);
          last;
        }
        default {}
      }
    }
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }

=head1 DESCRIPTION

Standard Test Data Format (STDF) is a widely used standard file format for semiconductor test information. 
It is a commonly used format produced by automatic test equipment (ATE) platforms from companies such as 
LTX-Credence, Roos Instruments, Teradyne, Advantest, and others.

A STDF file is compacted into a binary format according to a well defined specification originally designed by 
Teradyne. The record layouts, field definitions, and sizes are all described within the specification. Over the 
years, parser tools have been developed to decode this binary format in several scripting languages, but as 
of yet nothing has been released to CPAN for Perl.

Parse::STDF is a first attempt. It is an object oriented module containing methods which invoke APIs of
an underlying C library called C<libstdf> (see L<http://freestdf.sourceforge.net/>).  C<libstdf> performs 
the grunt work of reading and parsing binary data into STDF records represented as C-structs.  These 
structs are in turn referenced as Perl objects.

=head1 SEE ALSO

For an intro to the Standard Test Data Format (along with references to detailed documentation) 
see L<http://en.wikipedia.org/wiki/Standard_Test_Data_Format>.

=head1 AUTHOR

Erick Jordan <ejordan@cpan.org>

=end pod


