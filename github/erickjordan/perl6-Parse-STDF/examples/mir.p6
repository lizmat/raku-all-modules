#!/usr/bin/env perl6

use v6;
use Parse::STDF;

sub MAIN( Str $stdf )
{
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
          printf("\tSETUP_T: %s\n", $mir.SETUP_T.ctime);
          printf("\tSTART_T: %s\n", $mir.START_T.ctime);
          printf("\tSTAT_NUM: %d\n", $mir.STAT_NUM);
          printf("\tMODE_COD: %s\n", $mir.MODE_COD.chr);
          printf("\tRTST_COD: %s\n", $mir.RTST_COD.chr);
          printf("\tPROT_COD: %s\n", $mir.PROT_COD.chr);
          printf("\tBURN_TIM: %d\n", $mir.BURN_TIM); 
          printf("\tCMOD_COD: %s\n", $mir.CMOD_COD.chr);
          printf("\tLOT_ID: %s\n", $mir.LOT_ID.cnstr);
          printf("\tPART_TYP: %s\n", $mir.PART_TYP.cnstr);
          printf("\tNODE_NAM: %s\n", $mir.NODE_NAM.cnstr);
          printf("\tTSTR_TYP: %s\n", $mir.TSTR_TYP.cnstr);
          printf("\tJOB_NAM: %s\n", $mir.JOB_NAM.cnstr);
          printf("\tJOB_REV: %s\n", $mir.JOB_REV.cnstr);
          printf("\tSBLOT_ID: %s\n", $mir.SBLOT_ID.cnstr);
          printf("\tOPER_NAM: %s\n", $mir.OPER_NAM.cnstr);
          printf("\tEXEC_TYP: %s\n", $mir.EXEC_TYP.cnstr);
          printf("\tEXEC_VER: %s\n", $mir.EXEC_VER.cnstr);
          printf("\tTEST_COD: %s\n", $mir.TEST_COD.cnstr);
          printf("\tTST_TEMP: %s\n", $mir.TST_TEMP.cnstr);
          printf("\tUSER_TXT: %s\n", $mir.USER_TXT.cnstr);
          printf("\tAUX_FILE: %s\n", $mir.AUX_FILE.cnstr);
          printf("\tPKG_TYP: %s\n", $mir.PKG_TYP.cnstr);
          printf("\tFAMILY_ID: %s\n", $mir.FAMILY_ID.cnstr);
          printf("\tDATE_COD: %s\n", $mir.DATE_COD.cnstr);
          printf("\tFACIL_ID: %s\n", $mir.FACIL_ID.cnstr);
          printf("\tFLOOR_ID: %s\n", $mir.FLOOR_ID.cnstr);
          printf("\tPROC_ID: %s\n", $mir.PROC_ID.cnstr);
          printf("\tOPER_FRQ: %s\n", $mir.OPER_FRQ.cnstr);
          printf("\tSPEC_NAM: %s\n", $mir.SPEC_NAM.cnstr);
          printf("\tSPEC_VER: %s\n", $mir.SPEC_VER.cnstr);
          printf("\tFLOW_ID: %s\n", $mir.FLOW_ID.cnstr);
          printf("\tSETUP_ID: %s\n", $mir.SETUP_ID.cnstr);
          printf("\tDSGN_REV: %s\n", $mir.DSGN_REV.cnstr);
          printf("\tENG_ID: %s\n", $mir.ENG_ID.cnstr);
          printf("\tROM_COD: %s\n", $mir.ROM_COD.cnstr);
          printf("\tSERL_NUM: %s\n", $mir.SERL_NUM.cnstr);
          printf("\tSUPR_NAM: %s\n", $mir.SUPR_NAM.cnstr);
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
}

