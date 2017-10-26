#!/usr/bin/env perl6

use v6;
use Parse::STDF;
use experimental :pack;

sub MAIN( Str $stdf )
{
  try
  {
    my $s = Parse::STDF.new( stdf => $stdf );
    while $s.get_record
    {
      printf("Record %s ( %d, %d ) %d bytes:\n", $s.recname, $s.header.REC_TYP, $s.header.REC_SUB, $s.header.REC_LEN);
      given ( $s.recname )
      {
        when "FAR"
        {
          my $far = $s.far;
          printf("\tCPU_TYPE: %d\n", $far.CPU_TYPE);
          printf("\tSTDF_VER: %d\n", $far.STDF_VER);
        }
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
        }
        when "SDR"
        {
          my $sdr = $s.sdr;
          printf("\tHEAD_NUM: %d\n", $sdr.HEAD_NUM);
          printf("\tSITE_GRP: %d\n", $sdr.SITE_GRP);
          printf("\tSITE_CNT: %d\n", $sdr.SITE_CNT);
          print "\tSITE_NUM: ", $sdr.SITE_NUM.array($sdr.SITE_CNT), "\n";
          printf("\tHAND_TYP: %s\n", $sdr.HAND_TYP.cnstr);
          printf("\tHAND_ID: %s\n", $sdr.HAND_ID.cnstr);
          printf("\tCARD_TYP: %s\n", $sdr.CARD_TYP.cnstr);
          printf("\tCARD_ID: %s\n", $sdr.CARD_ID.cnstr);
          printf("\tLOAD_TYP: %s\n", $sdr.LOAD_TYP.cnstr);
          printf("\tLOAD_ID: %s\n", $sdr.LOAD_ID.cnstr);
          printf("\tDIB_TYP: %s\n", $sdr.DIB_TYP.cnstr);
          printf("\tDIB_ID: %s\n", $sdr.DIB_ID.cnstr);
          printf("\tCABL_TYP: %s\n", $sdr.CABL_TYP.cnstr);
          printf("\tCABL_ID: %s\n", $sdr.CABL_ID.cnstr);
          printf("\tCONT_TYP: %s\n", $sdr.CONT_TYP.cnstr);
          printf("\tCONT_ID: %s\n", $sdr.CONT_ID.cnstr);
          printf("\tLASR_TYP: %s\n", $sdr.LASR_TYP.cnstr);
          printf("\tLASR_ID: %s\n", $sdr.LASR_ID.cnstr);
          printf("\tEXTR_TYP: %s\n", $sdr.EXTR_TYP.cnstr);
          printf("\tEXTR_ID: %s\n", $sdr.EXTR_ID.cnstr);
        }
        when "PCR"
        {
          my $pcr = $s.pcr;
          printf("\tHEAD_NUM: %d\n", $pcr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $pcr.SITE_NUM);
          printf("\tPART_CNT: %d\n", $pcr.PART_CNT);
          printf("\tRTST_CNT: %d\n", $pcr.RTST_CNT);
          printf("\tABRT_CNT: %d\n", $pcr.ABRT_CNT);
          printf("\tGOOD_CNT: %d\n", $pcr.GOOD_CNT);
          printf("\tFUNC_CNT: %d\n", $pcr.FUNC_CNT);
        }
        when "MRR"
        {
          my $mrr = $s.mrr;
          printf("\tFINISH_T: %s\n", $mrr.FINISH_T.ctime);
          printf("\tDISP_COD: %s\n", $mrr.DISP_COD.chr);
          printf("\tUSR_DESC: %s\n", $mrr.USR_DESC.cnstr);
          printf("\tEXC_DESC: %s\n", $mrr.EXC_DESC.cnstr);
        }
        when "WIR"
        {
          my $wir = $s.wir;
          printf("\tHEAD_NUM: %d\n", $wir.HEAD_NUM);
          printf("\tSITE_GRP: %d\n", $wir.SITE_GRP);
          printf("\tSTART_T: %s\n", $wir.START_T.ctime);
          printf("\tWAFER_ID: %s\n", $wir.WAFER_ID.cnstr);
        }
        when "PIR"
        {
          my $pir = $s.pir;
          printf("\tHEAD_NUM: %d\n", $pir.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $pir.SITE_NUM);
        }
        when "PRR"
        {
          my $prr = $s.prr;
          printf("\tHEAD_NUM: %d\n", $prr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $prr.SITE_NUM);
          printf("\tPART_FLG: %d\n", $prr.PART_FLG);
          printf("\tNUM_TEST: %d\n", $prr.NUM_TEST);
          printf("\tHARD_BIN: %d\n", $prr.HARD_BIN);
          printf("\tSOFT_BIN: %d\n", $prr.SOFT_BIN);
          printf("\tX_COORD: %i\n", $prr.X_COORD);
          printf("\tY_COORD: %i\n", $prr.Y_COORD);
          printf("\tTEST_T: %d\n", $prr.TEST_T);
          printf("\tPART_ID: %s\n", $prr.PART_ID.cnstr);
          printf("\tPART_TXT: %s\n", $prr.PART_TXT.cnstr);
          printf("\tPART_FIX: %s\n", $prr.PART_FIX.bnbuf.unpack('H*')); 
        }
        when "PTR"
        {
          my $ptr = $s.ptr;
          printf("\tTEST_NUM: %d\n", $ptr.TEST_NUM);
          printf("\tHEAD_NUM: %d\n", $ptr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $ptr.SITE_NUM);
          printf("\tTEST_FLG: %s\n", Buf.new($ptr.TEST_FLG).unpack('H*'));
          printf("\tPARM_FLG: %s\n", Buf.new($ptr.PARM_FLG).unpack('H*'));
          printf("\tRESULT: %f\n", $ptr.RESULT);
          printf("\tTEST_TXT: %s\n", $ptr.TEST_TXT.cnstr);
          printf("\tALARM_ID: %s\n", $ptr.ALARM_ID.cnstr);
          printf("\tOPT_FLAG: %s\n", Buf.new($ptr.OPT_FLAG).unpack('H*'));
          printf("\tRES_SCAL: %f\n", $ptr.RES_SCAL);
          printf("\tLLM_SCAL: %f\n", $ptr.LLM_SCAL);
          printf("\tHLM_SCAL: %f\n", $ptr.HLM_SCAL);
          printf("\tLO_LIMIT: %f\n", $ptr.LO_LIMIT);
          printf("\tUNITS: %s\n", $ptr.UNITS.cnstr);
          printf("\tC_RESFMT: %s\n", $ptr.C_RESFMT.cnstr);
          printf("\tC_LLMFMT: %s\n", $ptr.C_LLMFMT.cnstr);
          printf("\tLO_SPEC: %f\n", $ptr.LO_SPEC);
          printf("\tHI_SPEC: %f\n", $ptr.HI_SPEC);
        }
        when "DTR"
        {
          my $dtr = $s.dtr;
          printf("\tTEXT_DAT: %s\n", $dtr.TEXT_DAT.cnstr);
        }
        when "ATR"
        {
          my $atr = $s.atr;
          printf("\tMID_TIM: %s\n", $atr.MOD_TIM.ctime);
          printf("\tCMD_LINE: %s\n", $atr.CMD_LINE.cnstr);
        }
        when "HBR"
        {
          my $hbr = $s.hbr;
          printf("\tHEAD_NUM: %d\n", $hbr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $hbr.SITE_NUM);
          printf("\tHBIN_NUM: %d\n", $hbr.HBIN_NUM);
          printf("\tHBIN_CNT: %d\n", $hbr.HBIN_CNT);
          printf("\tHBIN_PF: %s\n", $hbr.HBIN_PF.chr);
          printf("\tHBIN_NAM: %s\n", $hbr.HBIN_NAM.cnstr);
        }
        when "SBR"  
        {
          my $sbr = $s.sbr;
          printf("\tHEAD_NUM: %d\n", $sbr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $sbr.SITE_NUM);
          printf("\tSBIN_NUM: %d\n", $sbr.SBIN_NUM);
          printf("\tSBIN_CNT: %d\n", $sbr.SBIN_CNT);
          printf("\tSBIN_PF: %s\n", $sbr.SBIN_PF.chr);
          printf("\tSBIN_NAM: %s\n", $sbr.SBIN_NAM.cnstr);
        }
        when "PMR"
        {
          my $pmr = $s.pmr;
          printf("\tPMR_INDX: %d\n", $pmr.PMR_INDX);
          printf("\tCHAN_TYP: %d\n", $pmr.CHAN_TYP);
          printf("\tCHAN_NAM: %s\n", $pmr.CHAN_NAM.cnstr);
          printf("\tPHY_NAM: %s\n", $pmr.PHY_NAM.cnstr);
          printf("\tLOG_NAM: %s\n", $pmr.LOG_NAM.cnstr);
          printf("\tHEAD_NUM: %d\n", $pmr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $pmr.SITE_NUM);
        }
        when "PGR"
        {
          my $pgr = $s.pgr;
          printf("\tGRP_INDX: %d\n", $pgr.GRP_INDX);
          printf("\tGRP_NAM: %s\n", $pgr.GRP_NAM.cnstr);
          printf("\tINDX_CNT: %d\n", $pgr.INDX_CNT);
          print "\tPMR_INDX: ", $pgr.PMR_INDX.array($pgr.INDX_CNT), "\n";
        }
        when "PLR"
        {
          my $plr = $s.plr;
          printf("\tGRP_CNT: %d\n", $plr.GRP_CNT);
          print "\tGRP_INDX: ", $plr.GRP_INDX.array($plr.GRP_CNT), "\n";
          print "\tGRP_MODE: ", $plr.GRP_MODE.array($plr.GRP_CNT), "\n";
          print "\tGRP_RADX: ", $plr.GRP_RADX.array($plr.GRP_CNT), "\n";
          print "\tPGM_CHAR: ", $plr.PGM_CHAR.array($plr.GRP_CNT).map(*.cnstr), "\n";
          print "\tRTN_CHAR: ", $plr.RTN_CHAR.array($plr.GRP_CNT).map(*.cnstr), "\n";
          print "\tPGM_CHAL: ", $plr.PGM_CHAL.array($plr.GRP_CNT).map(*.cnstr), "\n";
          print "\tRTN_CHAL: ", $plr.RTN_CHAL.array($plr.GRP_CNT).map(*.cnstr), "\n";
        }
        when "RDR"
        {
          my $rdr = $s.rdr;
          printf("\tNUM_BINS: %d\n", $rdr.NUM_BINS);
          print "\tRTST_BIN: ", $rdr.RTST_BIN.array($rdr.NUM_BINS), "\n";
        }
        when "WRR"
        {
          my $wrr = $s.wrr;
          printf("\tHEAD_NUM: %d\n", $wrr.HEAD_NUM);
          printf("\tSITE_GRP: %d\n", $wrr.SITE_GRP);
          printf("\tFINISH_T: %s\n", $wrr.FINISH_T.ctime);
          printf("\tPART_CNT: %d\n", $wrr.PART_CNT);
          printf("\tRTST_CNT: %d\n", $wrr.RTST_CNT);
          printf("\tABRT_CNT: %d\n", $wrr.ABRT_CNT);
          printf("\tGOOD_CNT: %d\n", $wrr.GOOD_CNT);
          printf("\tFUNC_CNT: %d\n", $wrr.FUNC_CNT);
          printf("\tWAFER_ID: %s\n", $wrr.WAFER_ID.cnstr);
          printf("\tFABWF_ID: %s\n", $wrr.FABWF_ID.cnstr);
          printf("\tFRAME_ID: %s\n", $wrr.FRAME_ID.cnstr);
          printf("\tMASK_ID: %s\n", $wrr.MASK_ID.cnstr);
          printf("\tUSR_DESC: %s\n", $wrr.USR_DESC.cnstr);
          printf("\tEXC_DESC: %s\n", $wrr.EXC_DESC.cnstr);
        }
        when "WCR"
        {
          my $wcr = $s.wcr;
          printf("\tWAFR_SIZ: %f\n", $wcr.WAFR_SIZ);
          printf("\tDIE_HT: %f\n", $wcr.DIE_HT);
          printf("\tDIE_WID: %f\n", $wcr.DIE_WID);
          printf("\tWF_UNITS: %d\n", $wcr.WF_UNITS);
          printf("\tWF_FLAT: %s\n", $wcr.WF_FLAT.chr);
          printf("\tCENTER_X: %d\n", $wcr.CENTER_X);
          printf("\tCENTER_Y: %d\n", $wcr.CENTER_Y);
          printf("\tPOS_X: %s\n", $wcr.POS_X.chr);
          printf("\tPOS_Y: %s\n", $wcr.POS_Y.chr);
        }
        when "TSR"
        {
          my $tsr = $s.tsr;
          printf("\tHEAD_NUM: %d\n", $tsr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $tsr.SITE_NUM);
          printf("\tTEST_TYP: %s\n", $tsr.TEST_TYP.chr);
          printf("\tTEST_NUM: %d\n", $tsr.TEST_NUM);
          printf("\tEXEC_CNT: %d\n", $tsr.EXEC_CNT);
          printf("\tFAIL_CNT: %d\n", $tsr.FAIL_CNT);
          printf("\tALRM_CNT: %d\n", $tsr.ALRM_CNT);
          printf("\tTEST_NAM: %s\n", $tsr.TEST_NAM.cnstr);
          printf("\tSEQ_NAME: %s\n", $tsr.SEQ_NAME.cnstr);
          printf("\tTEST_LBL: %s\n", $tsr.TEST_LBL.cnstr); 
          printf("\tOPT_FLAG: %s\n", Buf.new($tsr.OPT_FLAG).unpack('H*'));
          printf("\tTEST_TIM: %f\n", $tsr.TEST_TIM);
          printf("\tTEST_MIN: %f\n", $tsr.TEST_MIN);
          printf("\tTEST_MAX: %f\n", $tsr.TEST_MAX);
          printf("\tTST_SUMS: %f\n", $tsr.TST_SUMS);
          printf("\tTST_SQRS: %f\n", $tsr.TST_SQRS);
        }
        when "MPR"
        {
          my $mpr = $s.mpr;
          printf("\tTEST_NUM: %d\n", $mpr.TEST_NUM);
          printf("\tHEAD_NUM: %d\n", $mpr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $mpr.SITE_NUM);
          printf("\tTEST_FLG: %s\n", Buf.new($mpr.TEST_FLG).unpack('H*'));
          printf("\tPARM_FLG: %s\n", Buf.new($mpr.PARM_FLG).unpack('H*'));
          printf("\tRTN_ICNT: %d\n", $mpr.RTN_ICNT);
          printf("\tRSLT_CNT: %d\n", $mpr.RSLT_CNT);
          print "\tRTN_STAT: ", $mpr.RTN_STAT.array($mpr.RTN_ICNT), "\n";
          print "\tRTN_RSLT: ", $mpr.RTN_RSLT.array($mpr.RSLT_CNT), "\n";
          printf("\tTEST_TXT: %s\n", $mpr.TEST_TXT.cnstr);
          printf("\tALARM_ID: %s\n", $mpr.ALARM_ID.cnstr);
          printf("\tOPT_FLAG: %s\n", Buf.new($mpr.OPT_FLAG).unpack('H*'));
          printf("\tRES_SCAL: %d\n", $mpr.RES_SCAL);
          printf("\tLLM_SCAL: %d\n", $mpr.LLM_SCAL);
          printf("\tHLM_SCAL: %d\n", $mpr.HLM_SCAL);
          printf("\tLO_LIMIT: %f\n", $mpr.LO_LIMIT);
          printf("\tHI_LIMIT: %f\n", $mpr.HI_LIMIT);
          printf("\tSTART_IN: %f\n", $mpr.START_IN);
          printf("\tINCR_IN: %f\n", $mpr.INCR_IN);
          print "\tRTN_INDX: ", $mpr.RTN_INDX.array($mpr.RTN_ICNT), "\n";
          printf("\tUNITS: %s\n", $mpr.UNITS.cnstr);
          printf("\tUNITS_IN: %s\n", $mpr.UNITS_IN.cnstr);
          printf("\tC_RESFMT: %s\n", $mpr.C_RESFMT.cnstr);
          printf("\tC_LLMFMT: %s\n", $mpr.C_LLMFMT.cnstr);
          printf("\tC_HLMFMT: %s\n", $mpr.C_HLMFMT.cnstr);
          printf("\tLO_SPEC: %f\n", $mpr.LO_SPEC);
          printf("\tHI_SPEC: %f\n", $mpr.HI_SPEC);
        }
        when "FTR"
        {
          my $ftr = $s.ftr;
          printf("\tTEST_NUM: %d\n", $ftr.TEST_NUM);
          printf("\tHEAD_NUM: %d\n", $ftr.HEAD_NUM);
          printf("\tSITE_NUM: %d\n", $ftr.SITE_NUM);
          printf("\tTEST_FLG: %s\n", Buf.new($ftr.TEST_FLG).unpack('H*'));
          printf("\tOPT_FLAG: %s\n", Buf.new($ftr.OPT_FLAG).unpack('H*'));
          printf("\tCYCL_CNT: %d\n", $ftr.CYCL_CNT);
          printf("\tREL_VADR: %d\n", $ftr.REL_VADR);
          printf("\tREPT_CNT: %d\n", $ftr.REPT_CNT);
          printf("\tNUM_FAIL: %d\n", $ftr.NUM_FAIL);
          printf("\tXFAIL_AD: %d\n", $ftr.XFAIL_AD);
          printf("\tYFAIL_AD: %d\n", $ftr.YFAIL_AD);
          printf("\tVECT_OFF: %d\n", $ftr.VECT_OFF);
          printf("\tRTN_ICNT: %d\n", $ftr.RTN_ICNT);
          printf("\tPGM_ICNT: %d\n", $ftr.PGM_ICNT);
          print "\tRTN_INDX: ", $ftr.RTN_INDX.array($ftr.RTN_ICNT), "\n";
          print "\tRTN_STAT: ", $ftr.RTN_STAT.array($ftr.RTN_ICNT), "\n";
          print "\tPGM_INDX: ", $ftr.PGM_INDX.array($ftr.PGM_ICNT), "\n";
          print "\tPGM_STAT: ", $ftr.PGM_STAT.array($ftr.PGM_ICNT), "\n";
          printf("\tFAIL_PIN: %s\n", $ftr.FAIL_PIN.dnbuf.unpack('H*'));
          printf("\tVECT_NAM: %s\n", $ftr.VECT_NAM.cnstr);
          printf("\tTIME_SET: %s\n", $ftr.TIME_SET.cnstr);
          printf("\tOP_CODE: %s\n", $ftr.OP_CODE.cnstr);
          printf("\tTEST_TXT: %s\n", $ftr.TEST_TXT.cnstr);
          printf("\tALARM_ID: %s\n", $ftr.ALARM_ID.cnstr);
          printf("\tPROG_TXT: %s\n", $ftr.PROG_TXT.cnstr);
          printf("\tRSLT_TXT: %s\n", $ftr.RSLT_TXT.cnstr);
          printf("\tPATG_NUM: %d\n", $ftr.PATG_NUM);
          printf("\tSPIN_MAP: %s\n", $ftr.SPIN_MAP.dnbuf.unpack('H*'));
        }
        when "BPS"
        {
          my $bps = $s.bps;
          printf("\tSEQ_NAME: %s\n", $bps.SEQ_NAME.cnstr);
        }
        when "EPS"
        {
          my $eps = $s.eps;
        }
        when "GDR"
        {
          my $gdr = $s.gdr;
          printf("\tFLD_CNT: %s\n", $gdr.FLD_CNT);
          printf("\tGDR_DATA:\n");
          for 0..$gdr.FLD_CNT-1 -> $i
          {
            my $field = $gdr.field($i);
            given ( $field.type )
            {
              when Parse::STDF::Native::GDR_B0 { printf("\t\tB0: (pad)\n"); }
              when Parse::STDF::Native::GDR_U1 { printf("\t\tU1: %d\n", $field.data.U1); }
              when Parse::STDF::Native::GDR_U2 { printf("\t\tU2: %d\n", $field.data.U2); }
              when Parse::STDF::Native::GDR_U2 { printf("\t\tU4: %d\n", $field.data.U4); }
              when Parse::STDF::Native::GDR_U1 { printf("\t\tI1: %d\n", $field.data.I1); }
              when Parse::STDF::Native::GDR_U2 { printf("\t\tI2: %d\n", $field.data.I2); }
              when Parse::STDF::Native::GDR_U2 { printf("\t\tI4: %d\n", $field.data.I4); }
              when Parse::STDF::Native::GDR_R4 { printf("\t\tR4: %f\n", $field.data.R4); }
              when Parse::STDF::Native::GDR_R8 { printf("\t\tR8: %f\n", $field.data.R8); }
              when Parse::STDF::Native::GDR_Cn { printf("\t\tCn: %s\n", $field.data.Cn.cnstr); }
              when Parse::STDF::Native::GDR_Bn { printf("\t\tBn: %s\n", $field.data.Bn.bnbuf.unpack('H*')); } 
              when Parse::STDF::Native::GDR_Dn { printf("\t\tDn: %s\n", $field.data.Dn.dnbuf.unpack('H*')); } 
              when Parse::STDF::Native::GDR_N1 { printf("\t\tN1: %s\n", $field.data.N1.unpack('H*')); }
              default {}
            }
          }
        }
        default
        {
          my $e = sprintf("Bytes: %i, TYP: 0x%X [%i], SUB: 0x%X [%i]", $s.header.REC_LEN, $s.header.REC_TYP, 
                  $s.header.REC_TYP, $s.header.REC_SUB, $s.header.REC_SUB);
          die "ERROR: unrecognized rec => $e";
        }
      }
    }
    CATCH
    {
      when X::Parse::STDF { say $_.message; }
      default { say $_; }
    }
  }
}

