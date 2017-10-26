use v6;
use NativeCall;

unit module Parse::STDF::Native;

=begin comment

Caveats and disclaimers:

  - Parse::STDF::Native is ONLY compatible with STDF Version 4 (see STDF specification)

=end comment

constant LIB =  'libstdf.so'; 

enum stdf_runtime_settings is export (
  STDF_SETTING_WRITE_SIZE => 0x001, # Set the output blocksize for writing
  STDF_SETTING_VERSION => 0x002,    # Query the STDF spec version
  STDF_SETTING_BYTE_ORDER => 0x003, # Query the byte order
);

enum dtc_Vn_type is export (
  GDR_B0 => 0,
  GDR_U1 => 1,
  GDR_U2 => 2,
  GDR_U4 => 3,
  GDR_I1 => 4,
  GDR_I2 => 5,
  GDR_I4 => 6,
  GDR_R4 => 7,
  GDR_R8 => 8,
  GDR_Cn => 10,
  GDR_Bn => 11,
  GDR_Dn => 12,
  GDR_N1 => 13,
);

class dtc_Cn is repr('CStruct') is export
{
  has CArray[int8] $.data;
  method cnstr
  {
    # 1st byte of $.data is length followed by text.
    # This method extracts the text and returns a Str.
    my Str $s = "";
    return ( $s ) if ( $!data[0] == 0 );
    for 1..$!data[0] -> $i {  $s ~= $!data[$i].chr; }
    return (chomp($s));
  }
}

class dtc_Bn is repr('CStruct') is export
{
  has CArray[uint8] $.data;
  method bnbuf
  {
    # 1st byte of $.data is length followed by bytes.
    # This function extracts the bytes and returns a Buf.
    my $b = Buf.new;
    return ($b) if ( $!data[0] == 0 );
    for 1..$!data[0] -> $i {  $b[$i-1] = $!data[$i]; }
    return ($b);
  }
}

class dtc_Dn is repr('CStruct') is export
{
  has CArray[uint8] $.data;
  method dnbuf
  {
    # First two bytes = unsigned count of bits to follow
    # This function extracts the bytes from $.data and returns a Buf.
    my $len = (Buf.new($!data[0],$!data[1]).unpack('n') / 8).ceiling;
    my $b = Buf.new;
    return ($b) if ( $len == 0 );
    for 2..$len -> $i {  $b[$i-2] = $!data[$i]; }
    return ($b);
  }
}


class dtc_Tm is repr('CStruct') is export
{
  has uint32 $.data;
  method ctime
  {
    # $!data is a C time_t data type.  This function returns result
    # of native ctime() function.
    my uint32 $timep = $.data;
    return(chomp(ctime($timep)));
  }
}

class dtc_xCn is repr('CStruct') is export
{
  has Pointer[dtc_Cn] $.data;
  method array(Int $sz)
  {
    my @a;
    my $p = nativecast(Pointer[dtc_Cn], $!data);
    for 1..$sz { @a.push(($p++).deref); }
    return(@a);
  }
}

class dtc_xU1 is repr('CStruct') is export
{
  has Pointer[uint8] $.data;
  method array(Int $sz)
  {
    my @a;
    my $p = nativecast(Pointer[uint8], $!data);
    for 1..$sz { @a.push(($p++).deref); }
    return(@a);
  }
}

class dtc_xU2 is repr('CStruct') is export
{
  has Pointer[uint16] $.data;
  method array(Int $sz)
  {
    my @a;
    my $p = nativecast(Pointer[uint16], $!data);
    for 1..$sz { @a.push(($p++).deref); }
    return(@a);
  }
}

class dtc_xR4 is repr('CStruct') is export
{
  has Pointer[num32] $.data;
  method array(Int $sz)
  {
    my @a;
    my $p = nativecast(Pointer[num32], $!data);
    for 1..$sz { @a.push(($p++).deref); }
    return(@a);
  }
}

class dtc_xN1 is repr('CStruct') is export
{
  has Pointer[uint8] $.data;
  method array(Int $sz)
  {
    my @a;
    my $hi;
    my $lo;
    my $p = nativecast(Pointer[uint8], $!data);
    for 1..($sz div 2)
    {
      my $v = ($p++).deref;
      $hi = $v +> 4;
      $lo = $v - ($hi +< 4);
      @a.push($hi);
      @a.push($lo);
    }
    if ( $sz mod 2 ) 
    {
      my $v = ($p).deref; 
      @a.push($v+>4);
    }
    return(@a);
  }
}

class rec_header is repr('CStruct') is export
{
  has Pointer[void] $.stdf_file;
  has uint32 $.state;
  has uint16 $.REC_LEN;
  has uint32 $.REC_TYP;
  has uint32 $.REC_SUB;
}

class rec_unknown is repr('CStruct') is export
{
  HAS rec_header $.header;
  has Pointer[void] $.data;
}

class rec_far is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.CPU_TYPE;
  has uint8 $.STDF_VER;
}

class rec_dtr is repr('CStruct') is export
{
  HAS rec_header $.header;
  HAS dtc_Cn $.TEXT_DAT;
}

class rec_sdr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_GRP;
  has uint8 $.SITE_CNT;
  HAS dtc_xU1 $.SITE_NUM;
  HAS dtc_Cn $.HAND_TYP;
  HAS dtc_Cn $.HAND_ID;
  HAS dtc_Cn $.CARD_TYP;
  HAS dtc_Cn $.CARD_ID;
  HAS dtc_Cn $.LOAD_TYP;
  HAS dtc_Cn $.LOAD_ID;
  HAS dtc_Cn $.DIB_TYP;
  HAS dtc_Cn $.DIB_ID;
  HAS dtc_Cn $.CABL_TYP;
  HAS dtc_Cn $.CABL_ID;
  HAS dtc_Cn $.CONT_TYP;
  HAS dtc_Cn $.CONT_ID;
  HAS dtc_Cn $.LASR_TYP;
  HAS dtc_Cn $.LASR_ID;
  HAS dtc_Cn $.EXTR_TYP;
  HAS dtc_Cn $.EXTR_ID;
}

class rec_mir is repr('CStruct') is export
{
  HAS rec_header $.header;
  HAS dtc_Tm $.SETUP_T;
  HAS dtc_Tm $.START_T;
  has uint8 $.STAT_NUM;
  has int8 $.MODE_COD;
  has int8 $.RTST_COD;
  has int8 $.PROT_COD;
  has uint16 $.BURN_TIM;
  has int8 $.CMOD_COD;
  HAS dtc_Cn $.LOT_ID;
  HAS dtc_Cn $.PART_TYP;
  HAS dtc_Cn $.NODE_NAM;
  HAS dtc_Cn $.TSTR_TYP;
  HAS dtc_Cn $.JOB_NAM;
  HAS dtc_Cn $.JOB_REV;
  HAS dtc_Cn $.SBLOT_ID;
  HAS dtc_Cn $.OPER_NAM;
  HAS dtc_Cn $.EXEC_TYP;
  HAS dtc_Cn $.EXEC_VER;
  HAS dtc_Cn $.TEST_COD;
  HAS dtc_Cn $.TST_TEMP;
  HAS dtc_Cn $.USER_TXT;
  HAS dtc_Cn $.AUX_FILE;
  HAS dtc_Cn $.PKG_TYP;
  HAS dtc_Cn $.FAMILY_ID;
  HAS dtc_Cn $.DATE_COD;
  HAS dtc_Cn $.FACIL_ID;
  HAS dtc_Cn $.FLOOR_ID;
  HAS dtc_Cn $.PROC_ID;
  HAS dtc_Cn $.OPER_FRQ;
  HAS dtc_Cn $.SPEC_NAM;
  HAS dtc_Cn $.SPEC_VER;
  HAS dtc_Cn $.FLOW_ID;
  HAS dtc_Cn $.SETUP_ID;
  HAS dtc_Cn $.DSGN_REV;
  HAS dtc_Cn $.ENG_ID;
  HAS dtc_Cn $.ROM_COD;
  HAS dtc_Cn $.SERL_NUM;
  HAS dtc_Cn $.SUPR_NAM;
}

class rec_pcr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint32 $.PART_CNT;
  has uint32 $.RTST_CNT;
  has uint32 $.ABRT_CNT;
  has uint32 $.GOOD_CNT;
  has uint32 $.FUNC_CNT;
}

class rec_mrr is repr('CStruct') is export
{
  HAS rec_header $.header;
  HAS dtc_Tm $.FINISH_T;
  has int8 $.DISP_COD;
  HAS dtc_Cn $.USR_DESC;
  HAS dtc_Cn $.EXC_DESC;
}

class rec_ptr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint32 $.TEST_NUM;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint8 $.TEST_FLG;
  has uint8 $.PARM_FLG;
  has num32 $.RESULT;
  HAS dtc_Cn $.TEST_TXT;
  HAS dtc_Cn $.ALARM_ID;
  has uint8 $.OPT_FLAG;
  has int8 $.RES_SCAL;
  has int8 $.LLM_SCAL;
  has int8 $.HLM_SCAL;
  has num32 $.LO_LIMIT;
  has num32 $.HI_LIMIT;
  HAS dtc_Cn $.UNITS;
  HAS dtc_Cn $.C_RESFMT;
  HAS dtc_Cn $.C_LLMFMT;
  HAS dtc_Cn $.C_HLMFMT;
  has num32 $.LO_SPEC;
  has num32 $.HI_SPEC;
}

class rec_pir is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
}

class rec_wir is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_GRP;
  HAS dtc_Tm $.START_T;
  HAS dtc_Cn $.WAFER_ID;
}

class dtc_Vn_ele_data is repr('CUnion') is export 
{
  has uint8 $.B0;
  has uint8 $.U1;
  has uint16 $.U2;
  has uint32 $.U4;
  has int8 $.I1;
  has int16 $.I2;
  has int32 $.I4;
  has num32 $.R4;
  has num64 $.R8;
  HAS dtc_Cn $.Cn;
  HAS dtc_Bn $.Bn;
  HAS dtc_Dn $.Dn;
  has uint8 $.N1;
}

class dtc_Vn_ele is repr('CStruct') is export
{
  has int8 $.type;
  has Pointer[dtc_Vn_ele_data] $.data;
}

class gdr_field is export
{
  has int8 $.type;
  has dtc_Vn_ele_data $.data;
}

class rec_gdr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint16 $.FLD_CNT;
  has Pointer[dtc_Vn_ele] $.GEN_DATA;
  method field(Int $i)
  {
    my $p = nativecast(Pointer[dtc_Vn_ele], $!GEN_DATA);
    for 0..$i-1 {$p++};
    return( gdr_field.new( type => $p.deref.type, data => $p.deref.data.deref ) ); 
  }
}

class rec_prr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint8 $.PART_FLG;
  has uint16 $.NUM_TEST;
  has uint16 $.HARD_BIN;
  has uint16 $.SOFT_BIN;
  has int16 $.X_COORD;
  has int16 $.Y_COORD;
  has uint32 $.TEST_T;
  HAS dtc_Cn $.PART_ID;
  HAS dtc_Cn $.PART_TXT;
  HAS dtc_Bn $.PART_FIX;
}

class rec_atr is repr('CStruct') is export
{
  HAS rec_header $.header;
  HAS dtc_Tm $.MOD_TIM;
  HAS dtc_Cn $.CMD_LINE;
}

class rec_hbr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint16 $.HBIN_NUM;
  has uint32 $.HBIN_CNT;
  has int8 $.HBIN_PF;
  HAS dtc_Cn $.HBIN_NAM;
}

class rec_sbr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint16 $.SBIN_NUM;
  has uint32 $.SBIN_CNT;
  has int8 $.SBIN_PF;
  HAS dtc_Cn $.SBIN_NAM;
}

class rec_pmr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint16 $.PMR_INDX;
  has uint16 $.CHAN_TYP;
  HAS dtc_Cn $.CHAN_NAM;
  HAS dtc_Cn $.PHY_NAM;
  HAS dtc_Cn $.LOG_NAM;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
}

class rec_pgr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint16 $.GRP_INDX;
  HAS dtc_Cn $.GRP_NAM;
  has uint16 $.INDX_CNT;
  HAS dtc_xU2 $.PMR_INDX;
}

class rec_plr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint16 $.GRP_CNT;
  HAS dtc_xU2 $.GRP_INDX;
  HAS dtc_xU2 $.GRP_MODE;
  HAS dtc_xU1 $.GRP_RADX;
  HAS dtc_xCn $.PGM_CHAR;
  HAS dtc_xCn $.RTN_CHAR;
  HAS dtc_xCn $.PGM_CHAL;
  HAS dtc_xCn $.RTN_CHAL;
}

class rec_rdr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint16 $.NUM_BINS;
  HAS dtc_xU2 $.RTST_BIN;
}

class rec_wrr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_GRP;
  HAS dtc_Tm $.FINISH_T;
  has uint32 $.PART_CNT;
  has uint32 $.RTST_CNT;
  has uint32 $.ABRT_CNT;
  has uint32 $.GOOD_CNT;
  has uint32 $.FUNC_CNT;
  HAS dtc_Cn $.WAFER_ID;
  HAS dtc_Cn $.FABWF_ID;
  HAS dtc_Cn $.FRAME_ID;
  HAS dtc_Cn $.MASK_ID;
  HAS dtc_Cn $.USR_DESC;
  HAS dtc_Cn $.EXC_DESC;
}

class rec_wcr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has num32 $.WAFR_SIZ;
  has num32 $.DIE_HT;
  has num32 $.DIE_WID;
  has uint8 $.WF_UNITS;
  has int8 $.WF_FLAT;
  has int16 $.CENTER_X;
  has int16 $.CENTER_Y;
  has int8 $.POS_X;
  has int8 $.POS_Y;
}

class rec_tsr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has int8 $.TEST_TYP;
  has uint32 $.TEST_NUM;
  has uint32 $.EXEC_CNT;
  has uint32 $.FAIL_CNT;
  has uint32 $.ALRM_CNT;
  HAS dtc_Cn $.TEST_NAM;
  HAS dtc_Cn $.SEQ_NAME;
  HAS dtc_Cn $.TEST_LBL;
  has uint8 $.OPT_FLAG; 
  has num32 $.TEST_TIM;
  has num32 $.TEST_MIN;
  has num32 $.TEST_MAX;
  has num32 $.TST_SUMS;
  has num32 $.TST_SQRS;
}

class rec_mpr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint32 $.TEST_NUM;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint8 $.TEST_FLG;
  has uint8 $.PARM_FLG;
  has uint16 $.RTN_ICNT;
  has uint16 $.RSLT_CNT;
  HAS dtc_xN1   $.RTN_STAT;
  HAS dtc_xR4   $.RTN_RSLT;
  HAS dtc_Cn $.TEST_TXT;
  HAS dtc_Cn $.ALARM_ID;
  has uint8 $.OPT_FLAG;
  has int8 $.RES_SCAL;
  has int8 $.LLM_SCAL;
  has int8 $.HLM_SCAL;
  has num32 $.LO_LIMIT;
  has num32 $.HI_LIMIT;
  has num32 $.START_IN;
  has num32 $.INCR_IN;
  HAS dtc_xU2 $.RTN_INDX;
  HAS dtc_Cn $.UNITS;
  HAS dtc_Cn $.UNITS_IN;
  HAS dtc_Cn $.C_RESFMT;
  HAS dtc_Cn $.C_LLMFMT;
  HAS dtc_Cn $.C_HLMFMT;
  has num32 $.LO_SPEC;
  has num32 $.HI_SPEC;
}

class rec_ftr is repr('CStruct') is export
{
  HAS rec_header $.header;
  has uint32 $.TEST_NUM;
  has uint8 $.HEAD_NUM;
  has uint8 $.SITE_NUM;
  has uint8 $.TEST_FLG;
  has uint8 $.OPT_FLAG;
  has uint32 $.CYCL_CNT;
  has uint32 $.REL_VADR;
  has uint32 $.REPT_CNT;
  has uint32 $.NUM_FAIL;
  has int32 $.XFAIL_AD;
  has int32 $.YFAIL_AD;
  has int16 $.VECT_OFF;
  has uint16 $.RTN_ICNT;
  has uint16 $.PGM_ICNT;
  HAS dtc_xU2 $.RTN_INDX;
  HAS dtc_xN1 $.RTN_STAT;
  HAS dtc_xU2 $.PGM_INDX;
  HAS dtc_xN1 $.PGM_STAT;
  HAS dtc_Dn $.FAIL_PIN;
  HAS dtc_Cn $.VECT_NAM;
  HAS dtc_Cn $.TIME_SET;
  HAS dtc_Cn $.OP_CODE;
  HAS dtc_Cn $.TEST_TXT;
  HAS dtc_Cn $.ALARM_ID;
  HAS dtc_Cn $.PROG_TXT;
  HAS dtc_Cn $.RSLT_TXT;
  has uint8 $.PATG_NUM;
  HAS dtc_Dn $.SPIN_MAP;
}

class rec_bps is repr('CStruct') is export
{
  HAS rec_header $.header;
  HAS dtc_Cn $.SEQ_NAME;
}

class rec_eps is repr('CStruct') is export
{
  HAS rec_header $.header;
}


#------------------ libstdf library functions --------------------
sub stdf_open(Str) returns Pointer[void] is native(LIB) is export { * }
sub stdf_close(Pointer[void]) returns int32 is native(LIB)  is export { * }
sub stdf_read_record(Pointer[void]) returns Pointer[rec_unknown] is native(LIB) is export { * }
sub stdf_read_record_raw(Pointer[void]) returns Pointer[rec_unknown] is native(LIB) is export { * }
sub stdf_free_record(Pointer[rec_unknown]) is native(LIB) is export { * }
sub stdf_get_setting(Pointer[void], int8, uint32 is rw) is native(LIB) is export { * }
sub stdf_get_rec_name(uint32, uint32) returns Str is native(LIB) is export { * }
sub stdf_parse_raw_record(Pointer[rec_unknown]) returns Pointer[rec_unknown] is native(LIB) is export { * }
#------------------- standard library functions --------------------
sub ctime(uint64 is rw) returns Str is native(Str) is export { * }
