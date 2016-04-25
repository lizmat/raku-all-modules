use v6;

unit module DBDish::ODBC::Native;
use NativeCall :ALL;
use NativeHelpers::Blob;
use nqp;

sub MyLibName {
    my $pref_ver = v2;
    if %*ENV<DEBIAN_FRONTEND> { # I'm on travis
	$pref_ver = v1;
    }
    %*ENV<DBDISH_ODBC_LIB> || guess_library_name(('odbc', $pref_ver));
}
constant LIB = &MyLibName;

package GLOBAL::X::DBDish {
    our class ODBCNatErr is Exception {
	has $.state;
	has $.native;
	has $.native-message;
	has $.handle;
	method message {
	    "ODBC: $!native-message ($!state)[$!native]";
	}
    }
}

class ODBCErr is Capture is export { }

my \SQL_OV_ODBC3    = 3;
my \SQL_OV_ODBC3_80 = 380;

# Status
constant SQL_SUCCESS_MASK is export = 0xFFFFFFFE;
constant SQL_SUCCESS           is export   = 0;
constant SQL_SUCCESS_WITH_INFO is export   = 1;
constant SQL_NO_DATA           is export = 100;

# ATTRs
constant SQL_ATTR_ODBC_VERSION = 200;

constant SQL_FETCH_NEXT         is export =  1;
constant SQL_FETCH_FIRST        is export =  2;
constant SQL_FETCH_FIRST_USER   is export = 31;
constant SQL_FETCH_FIRST_SYSTEM is export = 32;

constant SQL_NULL_DATA is export = -1;
constant SQL_NTS       is export = -3;

# Params type
constant SQL_PARAM_TYPE_UNKNOWN        =  0;
constant SQL_PARAM_INPUT               =  1;
constant SQL_PARAM_INPUT_OUTPUT        =  2;
constant SQL_RESULT_COL                =  3;
constant SQL_PARAM_OUTPUT              =  4;
constant SQL_RETURN_VALUE              =  5;
constant SQL_PARAM_INPUT_OUTPUT_STREAM =  8;
constant SQL_PARAM_OUTPUT_STREAM       = 16;

#/* SQL data type codes */
enum SQLTypes is export (
    :SQL_GUID(	       -11),
    :SQL_BIT(		-7),
    :SQL_TINYINT(	-6),
    :SQL_BIGINT(	-5),
    :SQL_LONGVARBINARY(	-4),
    :SQL_VARBINARY(	-3),
    :SQL_BINARY(	-2),
    :SQL_LONGVARCHAR(	-1),
    :SQL_UNKNOWN_TYPE(   0),
    :SQL_CHAR(		 1),
    :SQL_NUMERIC(        2),
    :SQL_DECIMAL(        3),
    :SQL_INTEGER(        4),
    :SQL_SMALLINT(       5),
    :SQL_FLOAT(          6),
    :SQL_REAL(           7),
    :SQL_DOUBLE(         8),
    :SQL_DATETIME(       9),
    :SQL_VARCHAR(       12),
    :SQL_TYPE_DATE(     91),
    :SQL_TYPE_TIME(     92),
    :SQL_TYPE_TIMESTAMP(93),
);

constant %SQLType-Conv is export = map({
    +SQLTypes::{.key} => .value;
}, (
    :SQL_GUID(	        Str),
    :SQL_BIT(	       Bool),
    :SQL_TINYINT(	Int),
    :SQL_BIGINT(	Int),
    :SQL_LONGVARBINARY(	Buf),
    :SQL_VARBINARY(	Buf),
    :SQL_BINARY(	Buf),
    :SQL_LONGVARCHAR(	Buf),
    :SQL_UNKNOWN_TYPE(  Any),
    :SQL_CHAR(	        Str),
    :SQL_NUMERIC(       Rat),
    :SQL_DECIMAL(       Rat),
    :SQL_INTEGER(       Int),
    :SQL_SMALLINT(      Int),
    :SQL_FLOAT(         Num),
    :SQL_REAL(          Num),
    :SQL_DOUBLE(        Num),
    :SQL_DATETIME(      Str),
    :SQL_VARCHAR(       Str),
    :SQL_TYPE_DATE(     Str),
    :SQL_TYPE_TIME(     Str),
    :SQL_TYPE_TIMESTAMP(Str),
)).hash;

constant SQL_C_CHAR = +SQL_CHAR;
constant SQL_C_BINARY = +SQL_BINARY;

enum con_attrs is export (
    :SQL_ATTR_ACCESS_MODE(	  101),
    :SQL_ATTR_AUTOCOMMIT(	  102),
    :SQL_ATTR_CONNECTION_TIMEOUT( 113),
    :SQL_ATTR_CURRENT_CATALOG(	  109),
    :SQL_ATTR_DISCONNECT_BEHAVIOR(114),
    :SQL_ATTR_ENLIST_IN_DTC(	 1207),
    :SQL_ATTR_ENLIST_IN_XA(      1208),
    :SQL_ATTR_LOGIN_TIMEOUT(	  103),
    :SQL_ATTR_ODBC_CURSORS(	  110),
    :SQL_ATTR_PACKET_SIZE(	  112),
    :SQL_ATTR_QUIET_MODE(	  111),
    :SQL_ATTR_TRACE(		  104),
    :SQL_ATTR_TRACEFILE(	  105),
    :SQL_ATTR_TRANSLATE_LIB(	  106),
    :SQL_ATTR_TRANSLATE_OPTION(	  107),
    :SQL_ATTR_TXN_ISOLATION(	  108)
);

#/* Information requested by SQLGetInfo() */
enum InfoType is export (
    :SQL_MAX_DRIVER_CONNECTIONS(           0),
    :SQL_MAXIMUM_DRIVER_CONNECTIONS(       0),
    :SQL_MAX_CONCURRENT_ACTIVITIES(        1),
    :SQL_MAXIMUM_CONCURRENT_ACTIVITIES(    1),
    :SQL_DATA_SOURCE_NAME(                 2),
    :SQL_FETCH_DIRECTION(                  8),
    :SQL_SERVER_NAME(                     13),
    :SQL_SEARCH_PATTERN_ESCAPE(           14),
    :SQL_DBMS_NAME(                       17),
    :SQL_DBMS_VER(                        18),
    :SQL_ACCESSIBLE_TABLES(               19),
    :SQL_ACCESSIBLE_PROCEDURES(           20),
    :SQL_CURSOR_COMMIT_BEHAVIOR(          23),
    :SQL_DATA_SOURCE_READ_ONLY(           25),
    :SQL_DEFAULT_TXN_ISOLATION(           26),
    :SQL_IDENTIFIER_CASE(                 28),
    :SQL_IDENTIFIER_QUOTE_CHAR(           29),
    :SQL_MAX_COLUMN_NAME_LEN(             30),
    :SQL_MAXIMUM_COLUMN_NAME_LENGTH(      30),
    :SQL_MAX_CURSOR_NAME_LEN(             31),
    :SQL_MAXIMUM_CURSOR_NAME_LENGTH(      31),
    :SQL_MAX_SCHEMA_NAME_LEN(             32),
    :SQL_MAXIMUM_SCHEMA_NAME_LENGTH(      32),
    :SQL_MAX_CATALOG_NAME_LEN(            34),
    :SQL_MAXIMUM_CATALOG_NAME_LENGTH(     34),
    :SQL_MAX_TABLE_NAME_LEN(              35),
    :SQL_SCROLL_CONCURRENCY(              43),
    :SQL_TXN_CAPABLE(                     46),
    :SQL_TRANSACTION_CAPABLE(             46),
    :SQL_USER_NAME(                       47),
    :SQL_TXN_ISOLATION_OPTION(            72),
    :SQL_TRANSACTION_ISOLATION_OPTION(    72),
    :SQL_INTEGRITY(                       73),
    :SQL_GETDATA_EXTENSIONS(              81),
    :SQL_NULL_COLLATION(                  85),
    :SQL_ALTER_TABLE(                     86),
    :SQL_ORDER_BY_COLUMNS_IN_SELECT(      90),
    :SQL_SPECIAL_CHARACTERS(              94),
    :SQL_MAX_COLUMNS_IN_GROUP_BY(         97),
    :SQL_MAXIMUM_COLUMNS_IN_GROUP_BY(     97),
    :SQL_MAX_COLUMNS_IN_INDEX(            98),
    :SQL_MAXIMUM_COLUMNS_IN_INDEX(        98),
    :SQL_MAX_COLUMNS_IN_ORDER_BY(         99),
    :SQL_MAXIMUM_COLUMNS_IN_ORDER_BY(     99),
    :SQL_MAX_COLUMNS_IN_SELECT(          100),
    :SQL_MAXIMUM_COLUMNS_IN_SELECT(      100),
    :SQL_MAX_COLUMNS_IN_TABLE(           101),
    :SQL_MAX_INDEX_SIZE(                 102),
    :SQL_MAXIMUM_INDEX_SIZE(             102),
    :SQL_MAX_ROW_SIZE(                   104),
    :SQL_MAXIMUM_ROW_SIZE(               104),
    :SQL_MAX_STATEMENT_LEN(              105),
    :SQL_MAXIMUM_STATEMENT_LENGTH(       105),
    :SQL_MAX_TABLES_IN_SELECT(           106),
    :SQL_MAXIMUM_TABLES_IN_SELECT(       106),
    :SQL_MAX_USER_NAME_LEN(              107),
    :SQL_MAXIMUM_USER_NAME_LENGTH(       107),
    :SQL_OJ_CAPABILITIES(                115),
    :SQL_OUTER_JOIN_CAPABILITIES(        115),
    :SQL_XOPEN_CLI_YEAR(               10000),
    :SQL_CURSOR_SENSITIVITY(           10001),
    :SQL_DESCRIBE_PARAMETER(           10002),
    :SQL_CATALOG_NAME(                 10003),
    :SQL_COLLATION_SEQ(                10004),
    :SQL_MAX_IDENTIFIER_LEN(           10005),
    :SQL_MAXIMUM_IDENTIFIER_LENGTH(    10005),
);

# ODBC Handlers handling ;-)
enum HANDLE_TYPE (
    ENV => 1, DBC => 2, STMT => 3, DESC => 4
);

class SQL_HANDLE is repr('CPointer') {
    method h-type { 0 }
    method AllocHandle(SQL_HANDLE:U: SQL_HANDLE $parent) {
	sub SQLAllocHandle(int16, SQL_HANDLE, SQL_HANDLE is rw --> int16)
	    is native(LIB) { * }

	$parent.handle-res(SQLAllocHandle(self.h-type, $parent, my \prot = self.new));
	prot;
    }

    method FreeHandle(--> True) {
	sub SQLFreeHandle(int16, SQL_HANDLE --> int16) is native(LIB) { * };

	SQLFreeHandle(self.h-type, self);
    }

    method dispose() {
	self.FreeHandle;
    }

    method handle-res($code, :$throw) {
	sub SQLGetDiagRec(
	    int16, SQL_HANDLE, int16, utf8, int32 is rw,
	    utf8, int32, int32 is rw --> int16) is native(LIB) { * }

	if $code +& SQL_SUCCESS_MASK {
	    my ODBCErr $rep;
	    if self { # On allocated handle
		my $ret = SQL_SUCCESS;
		my utf8 $state .= allocate(5);
		my int32 $native;
		my utf8 $message .= allocate(256);
		my int32 $etl;
		my $i = 0;
		$ret = SQLGetDiagRec(
		    self.h-type, self, ++$i, $state, $native,
		    $message, $message.elems, $etl
		);
		X::DBDish::ODBCNatErr.new(
		    :$state, :$native, :native-message($message),
		    :handle(self.^name)
		).fail if $throw;
		$rep .= new(
		    :list(~$state, ~$message.subbuf(^$etl)),
		    :hash(%(:$code))
		);
	    }
	    else { fail "Can't allocate the ENV Handle" }
	    $rep;
	}
	else { Nil }
    }
}

class SQLENV is SQL_HANDLE is export is repr('CPointer') {
    method h-type { ENV }
    method Alloc() {
	my $env = ::?CLASS.AllocHandle(SQL_HANDLE);
	$env.handle-res(
	    $env.SetEnvAttr(SQL_ATTR_ODBC_VERSION, Pointer.new(SQL_OV_ODBC3), 0)
	):throw || $env;
    }

    method SetEnvAttr(int32 $attr, Pointer $val, int32 $len --> int16)
	is symbol('SQLSetEnvAttr') is native(LIB) { * }

    method Drivers(Int $dir) {
	sub SQLDrivers(SQLENV:D, uint16, utf8, int16, int16 is rw,
	    utf8, int16, int16 is rw --> int16) is native(LIB) { * }

	my utf8 $drv_desc .= allocate( 255);
	my utf8 $drv_attr .= allocate(1024);
	self.handle-res(
	    SQLDrivers(self, $dir, $drv_desc,  255, my int16 $etl1,
				   $drv_attr, 1024, my int16 $etl2)
	) || do {
	    (~$drv_desc.subbuf(^$etl1), ~$drv_attr.subbuf(^$etl2))
	};
    }

    method DataSources(Int $dir) {
	sub SQLDataSources(SQLENV:D, uint16, utf8, int16, int16 is rw,
	    utf8, int16, int16 is rw --> int16) is native(LIB) { * }

	my utf8 $drv_desc .= allocate( 255);
	my utf8 $drv_attr .= allocate(1024);
	self.handle-res(
	    SQLDataSources(self, $dir, $drv_desc,  255, my int16 $etl1,
				       $drv_attr, 1024, my int16 $etl2)
	) || do {
	    (~$drv_desc.subbuf(^$etl1), ~$drv_attr.subbuf(^$etl2))
	};
    }

}

class SQLDBC is SQL_HANDLE is export is repr('CPointer') {
    method h-type { DBC }
    method Alloc(SQLENV $parent) {
	::?CLASS.AllocHandle($parent);
    }
    method SetConnectAttr(int32, Pointer, int32 $len --> int16)
	is symbol('SQLSetConnectAttr') is native(LIB) { * }

    method Connect(Str $cs, Str $database, Str $user, Str $pass) {
	sub SQLConnect(SQLDBC:D, Str, int16, Str, int16, Str, int16 --> int16)
	    is native(LIB) { * }
	sub SQLDriverConnect(SQLDBC:D, Pointer, Str, int16, utf8, int16,
	    int32 is rw, int32 --> int16)
	    is native(LIB) { * }

	my utf8 $ret .= allocate(1024);
	my int32 $etl;
	self.handle-res(
	    $cs.defined
		?? SQLDriverConnect(self, Pointer, $cs, SQL_NTS, $ret, 1024, $etl, 0)
	        !! SQLConnect(self, $database, SQL_NTS, $user, SQL_NTS, $pass, SQL_NTS)
	) || Str($ret.subbuf(^$etl));
    }

    method Disconnect(--> int16) is symbol('SQLDisconnect') is native(LIB) { * }

    method GetInfo(InfoType) {
	sub SQLGetInfo(SQLDBC:D, int16, Pointer, int16, int16 is rw --> int16)
	    is native(LIB) { * }

	#TODO
    }
}

class SQLSTMT is SQL_HANDLE is export is repr('CPointer') {
    method h-type { STMT }
    method Alloc(SQLDBC $parent) {
	::?CLASS.AllocHandle($parent);
    }
    method ExecDirect(Str $statement) {
	sub SQLExecDirect(SQLSTMT:D, Str, int16 --> int16) is native(LIB) { * }

	self.handle-res(SQLExecDirect(self, $statement, SQL_NTS)) || True;
    }

    method Prepare(Str $statement) {
	sub SQLPrepare(SQLSTMT:D, Str, int16 --> int16) is native(LIB) { * }

	self.handle-res(SQLPrepare(self, $statement, SQL_NTS)) || True;
    }

    method NumParams() {
	sub SQLNumParams(SQLSTMT:D, int32 is rw --> int16) is native(LIB) { * }

	my int32 $params;
	self.handle-res(SQLNumParams(self, $params)) || $params;
    }

    method DescribeParam(Int $par) {
	sub SQLDescribeParam(SQLSTMT:D, uint16, int16 is rw, uint64 is rw,
	    uint16 is rw, uint16 is rw --> int16) is native(LIB) { * }

	self.handle-res(SQLDescribeParam(self, $par, my int16 $datatype,
	    my int32 $colsize, my int16 $dd, my int16 $nullable)
	) || do {
	    my $type = %SQLType-Conv{$datatype};
	    if $type === Any {
		warn "ODBC: No typemap defined for type $datatype in parameter $par";
		$type = Str;
	    }
	    Map.new: (:$datatype, :$type, :$colsize, :$dd, :$nullable);
	}
    }

    method BindParameter(Int $par, $type, Blob $data, Buf[int64] $SoI) {
	sub SQLBindParameter(SQLSTMT:D, uint16, int16, int16, int16,
	    int32, int16, Blob, int64, Pointer --> int16) is native(LIB) { * }

	my $BS   = BPointer($SoI, :typed);
	my $PSoI = nativecast(
	    Pointer[int64], Pointer.new(+$BS + ($par - 1) * nativesizeof(int64))
	);
	self.handle-res: SQLBindParameter(
	    self, $par, SQL_PARAM_INPUT,
	    ($type<type> ~~ Blob ?? SQL_C_BINARY !! SQL_C_CHAR),
	    $type<datatype>,
	    $type<colsize>, $type<dd>, $data, 0, $PSoI
	) || True;
    }

    method Execute(--> int16) is symbol('SQLExecute') is native(LIB) { * }

    method NumResultCols() {
	sub SQLNumResultCols(SQLSTMT:D, int32 is rw --> int16) is native(LIB) { * }
	my int32 $cols;
	self.handle-res(SQLNumResultCols(self, $cols)) || $cols;
    }

    method DescribeCol(Int $col) {
	sub SQLDescribeCol(SQLSTMT:D, uint16, utf8, int16, int16 is rw,
	    int16 is rw, int64 is rw, int16 is rw, int16 is rw --> int16)
	    is native(LIB) { * }
	my utf8 $name .= allocate(256);
	self.handle-res(SQLDescribeCol(self, $col, $name, 256, my int16 $etl,
	    my int16 $datatype, my int64 $colsize, my int16 $dd, my int16 $nullable)
	) || do {
	    my $type = %SQLType-Conv{$datatype};
	    if $type === Any {
		warn "ODBC: No typemap defined for type $datatype in column $col";
		$type = Str;
	    }
	    Map.new: ( :name(~$name.subbuf(^$etl)),
		       :$datatype, :$type, :$colsize, :$dd, :$nullable );
	}
    }

    method Fetch(--> int16) is symbol('SQLFetch') is native(LIB) { * }

    method GetData(Int $col, :$raw) {
	sub SQLGetData(SQLSTMT:D, uint16, uint16, Buf, int64, int64 is rw --> int16)
	    is native(LIB) { * }
	my Buf $data .= allocate(4096);
	my int64 $etl;
	self.handle-res(
	    SQLGetData(self, $col,
		($raw ?? SQL_C_BINARY !! SQL_C_CHAR), $data, 4096, $etl
	    )
	) ||  do {
	    if $etl >= 0 {
		$data .= subbuf(^$etl);
		($raw ?? $data !! $data.decode);
	    } else { $raw ?? Buf !! Str }
	}
    }

    method RowCount() {
	sub SQLRowCount(SQLSTMT:D, int64 is rw --> int16) is native(LIB) { * }
	self.handle-res(SQLRowCount(self, my int64 $rows)) || $rows;
    }

    method CloseCursor(--> int16) is symbol('SQLCloseCursor') is native(LIB) { * }
}

class SQLDESC is SQL_HANDLE is export is repr('CPointer') {
    method h-type { DESC }
}

