use JSON::Fast;
use NativeCall;
use NativeLibs;

sub LIBMYSQL {
    NativeLibs::Searcher.at-runtime(
        Rakudo::Internals.IS-WIN ?? 'mysql' !! 'mysqlclient',
        'mysql_init', 16..20).();
}

sub mysql_get_client_version(--> uint32) is export is native(LIBMYSQL) {}
sub mysql_get_client_info(--> Str) is export is native(LIBMYSQL) {}

class DB::MySQL::Error is Exception
{
    has Int $.code;
    has Str $.message;
}

sub out-of-memory() { die DB::MySQL::Error.new(message => 'Out of Memory') }

enum mysql-option <MYSQL_OPT_CONNECT_TIMEOUT MYSQL_OPT_COMPRESS
    MYSQL_OPT_NAMED_PIPE MYSQL_INIT_COMMAND MYSQL_READ_DEFAULT_FILE
    MYSQL_READ_DEFAULT_GROUP MYSQL_SET_CHARSET_DIR
    MYSQL_SET_CHARSET_NAME MYSQL_OPT_LOCAL_INFILE MYSQL_OPT_PROTOCOL
    MYSQL_SHARED_MEMORY_BASE_NAME MYSQL_OPT_READ_TIMEOUT
    MYSQL_OPT_WRITE_TIMEOUT MYSQL_OPT_USE_RESULT
    MYSQL_OPT_USE_REMOTE_CONNECTION MYSQL_OPT_USE_EMBEDDED_CONNECTION
    MYSQL_OPT_GUESS_CONNECTION MYSQL_SET_CLIENT_IP MYSQL_SECURE_AUTH
    MYSQL_REPORT_DATA_TRUNCATION MYSQL_OPT_RECONNECT
    MYSQL_OPT_SSL_VERIFY_SERVER_CERT MYSQL_PLUGIN_DIR
    MYSQL_DEFAULT_AUTH MYSQL_OPT_BIND MYSQL_OPT_SSL_KEY
    MYSQL_OPT_SSL_CERT MYSQL_OPT_SSL_CA MYSQL_OPT_SSL_CAPATH
    MYSQL_OPT_SSL_CIPHER MYSQL_OPT_SSL_CRL MYSQL_OPT_SSL_CRLPATH
    MYSQL_OPT_CONNECT_ATTR_RESET MYSQL_OPT_CONNECT_ATTR_ADD
    MYSQL_OPT_CONNECT_ATTR_DELETE MYSQL_SERVER_PUBLIC_KEY
    MYSQL_ENABLE_CLEARTEXT_PLUGIN
    MYSQL_OPT_CAN_HANDLE_EXPIRED_PASSWORDS MYSQL_OPT_SSL_ENFORCE
    MYSQL_OPT_MAX_ALLOWED_PACKET MYSQL_OPT_NET_BUFFER_LENGTH
    MYSQL_OPT_TLS_VERSION MYSQL_OPT_SSL_MODE
    MYSQL_OPT_GET_SERVER_PUBLIC_KEY>;

enum mysql-type
(
    MYSQL_TYPE_DECIMAL     => 0,
    MYSQL_TYPE_TINY        => 1,
    MYSQL_TYPE_SHORT       => 2,
    MYSQL_TYPE_LONG        => 3,
    MYSQL_TYPE_FLOAT       => 4,
    MYSQL_TYPE_DOUBLE      => 5,
    MYSQL_TYPE_NULL        => 6,
    MYSQL_TYPE_TIMESTAMP   => 7,
    MYSQL_TYPE_LONGLONG    => 8,
    MYSQL_TYPE_INT24       => 9,
    MYSQL_TYPE_DATE        => 10,
    MYSQL_TYPE_TIME        => 11,
    MYSQL_TYPE_DATETIME    => 12,
    MYSQL_TYPE_YEAR        => 13,
    MYSQL_TYPE_NEWDATE     => 14,
    MYSQL_TYPE_VARCHAR     => 15,
    MYSQL_TYPE_BIT         => 16,
    MYSQL_TYPE_JSON        => 245,
    MYSQL_TYPE_NEWDECIMAL  => 246,
    MYSQL_TYPE_ENUM        => 247,
    MYSQL_TYPE_SET         => 248,
    MYSQL_TYPE_TINY_BLOB   => 249,
    MYSQL_TYPE_MEDIUM_BLOB => 250,
    MYSQL_TYPE_LONG_BLOB   => 251,
    MYSQL_TYPE_BLOB        => 252,
    MYSQL_TYPE_VAR_STRING  => 253,
    MYSQL_TYPE_STRING      => 254
);

enum mysql-fetch-returns (
    MYSQL_NO_DATA => 100,
    MYSQL_DATA_TRUNCATED => 101
);

my constant my_bool = int8;

constant ptrsize is export = nativesizeof(Pointer);
constant intptr is export = ptrsize == 8 ?? uint64 !! uint32;

sub malloc(size_t --> Pointer) is native {}
sub realloc(Pointer, size_t --> Pointer) is native {}
sub calloc(size_t, size_t --> Pointer) is native {}
sub free(Pointer) is native {}
sub memcpy(Pointer,Blob,size_t --> Pointer) is native {}

class MYSQL_BIND is repr('CStruct')
{
    has intptr           $.length is rw;
    has intptr           $.is_null is rw;
    has intptr           $.buffer is rw;
    has intptr           $.error is rw;
    has Pointer[uint8]   $.row_ptr;
    has Pointer          $.store_param_func;
    has Pointer          $.fetch_result;
    has Pointer          $.skip_result;
    has ulong            $.buffer_length is rw;
    has ulong            $.offset;
    has ulong            $.length_value;
    has uint32           $.param_number is rw;
    has uint32           $.pack_length;
    has uint32           $.buffer_type is rw;
    has my_bool          $.error_value;
    has my_bool          $.is_unsigned;
    has my_bool          $.long_data_user;
    has my_bool          $.is_null_value;
    has Pointer          $.extension;

    method bufptr() { Pointer.new($!buffer) }

    method len() { nativecast(Pointer[uint64], Pointer.new($!length)).deref }
}

class MYSQL_RES is repr('CPointer') {...}

role DB::MySQL::Native::Bind does Positional
{
    has Int $.count;
    has Pointer $.binds;
    has Pointer $.lengths;

    submethod BUILD(:$!count)
    {
        if $!count > 0
        {
            $!binds = calloc($!count, nativesizeof(MYSQL_BIND)) // out-of-memory;
            $!lengths = calloc($!count, ptrsize) // out-of-memory;

            for ^$!count -> $i
            {
                with self[$i]
                {
                    .length = Pointer.new($!lengths + $i*ptrsize);
                }
            }
        }
    }

    method AT-POS(Int $field)   # CArray[MYSQL_BIND] doesn't like me
    {
        nativecast(MYSQL_BIND,
                   Pointer.new($!binds + $field * nativesizeof(MYSQL_BIND)))
    }

    method bindfree()
    {
        for ^$!count -> $i
        {
            with self[$i]
            {
                free(.bufptr) if .buffer_length && .bufptr;
            }
        }
        free($_) with $!binds;
        free(nativecast(Pointer,$_)) with $!lengths;
        $!binds = Nil;
        $!lengths = Nil;
        $!count = 0;
    }

    method free() { self.bindfree }

    submethod DESTROY() { self.bindfree }
}

class DB::MySQL::Native::ParamsBind does DB::MySQL::Native::Bind
{
    method bind-params(@args)
    {
        my \n = @args.elems;
        loop (my $i = 0; $i < n; $i++)
        {
            $.bind($i, @args[$i])
        }
    }

    multi method bind(Int:D $i, Blob:D $b, Int $type = MYSQL_TYPE_BLOB)
    {
        with self[$i]
        {
            if $b.bytes > 0
            {
                if .buffer_length == 0
                {
                    .buffer = malloc($b.bytes);
                    .buffer_length = $b.bytes;
                }
                elsif .buffer_length < $b.bytes
                {
                    .buffer = realloc(Pointer.new(.buffer), $b.bytes);
                    .buffer_length = $b.bytes;
                }

                .buffer = memcpy(Pointer.new(.buffer), $b, $b.bytes)
            }
            .buffer_type = $type;
            nativecast(CArray[ulong], Pointer.new(.length))[0] = $b.bytes;
        }
    }

    multi method bind(Int:D $i, Bool:D $b)
    {
        $.bind($i, Blob[int8].new($b ?? 1 !! 0), MYSQL_TYPE_TINY)
    }

    multi method bind(Int:D $i, Int:D $n)
    {
        $.bind($i, Blob[int64].new($n), MYSQL_TYPE_LONGLONG)
    }

    multi method bind(Int:D $i, DateTime:D $dt)
    {
        # Remove timezone per DBIish
        $.bind($i, $dt.local.Str.subst(/ <[\-\+]>\d\d ':' \d\d /,'').encode)
    }

    multi method bind(Int:D $i, Map:D $m)
    {
        $.bind($i, to-json($m))
    }

    multi method bind(Int:D $i, @a)
    {
        $.bind($i, to-json(@a))
    }

    multi method bind(Int:D $i, Set:D $s)
    {
        $.bind($i, $s.keys.join(','))
    }

    multi method bind(Int:D $i, Str:D() $s)
    {
        $.bind($i, $s.encode, MYSQL_TYPE_STRING)
    }

    multi method bind(Int:D $i, Any:U)
    {
        self[$i].buffer_type = MYSQL_TYPE_NULL;
    }
}

class DB::MySQL::Native::ResultsBind does DB::MySQL::Native::Bind
{
    has CArray[my_bool] $.nulls;
    has CArray[my_bool] $.errors;

    submethod TWEAK()
    {
        if $!count > 0
        {
            my $nulls = calloc($!count, 1) // out-of-memory;
            my $errors = calloc($!count, 1) // out-of-memory;
            $!nulls = nativecast(CArray[my_bool], $nulls);
            $!errors = nativecast(CArray[my_bool], $errors);

            for ^$!count -> $i
            {
                with self[$i]
                {
                    .is_null = Pointer.new($nulls + $i);
                    .error = Pointer.new($errors + $i);
                }
            }
        }
    }

    method free()
    {
        free(nativecast(Pointer,$_)) with $!nulls;
        free(nativecast(Pointer,$_)) with $!errors;
        $!nulls = $!errors = Nil;
        self.bindfree
    }

    submethod DESTROY() { self.free }
}

class MYSQL_STMT is repr('CPointer')
{
    method errno(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_stmt_errno') {}

    method error(--> Str)
        is native(LIBMYSQL) is symbol('mysql_stmt_error') {}

    method check(int32 $code = $.errno) is hidden-from-backtrace
    {
        die DB::MySQL::Error.new(:$code, message => $.error) unless $code == 0;
        self
    }

    method prepare(Blob, ulong --> int32)
        is native(LIBMYSQL) is symbol('mysql_stmt_prepare') {}

    method param-count(--> ulong)
        is native(LIBMYSQL) is symbol('mysql_stmt_param_count') {}

    method field-count(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_stmt_field_count') {}

    method bind-param(MYSQL_BIND --> my_bool)
        is native(LIBMYSQL) is symbol('mysql_stmt_bind_param') {}

    method bind-result(MYSQL_BIND --> my_bool)
        is native(LIBMYSQL) is symbol('mysql_stmt_bind_result') {}

    method result-metadata(--> MYSQL_RES)
        is native(LIBMYSQL) is symbol('mysql_stmt_result_metadata') {}

    method execute(--> int32)
        is native(LIBMYSQL) is symbol('mysql_stmt_execute') {}

    method store-result(--> MYSQL_RES)
        is native(LIBMYSQL) is symbol('mysql_store_result') {}

    method affected-rows(--> uint64)
        is native(LIBMYSQL) is symbol('mysql_stmt_affected_rows') {}

    method fetch(--> int32)
        is native(LIBMYSQL) is symbol('mysql_stmt_fetch') {}

    method close(--> int32)
        is native(LIBMYSQL) is symbol('mysql_stmt_close') {}
}

class MYSQL_FIELD is repr('CStruct') does Positional
{
    has	Str	$.name;
    has Str	$.org_name;
    has Str	$.table;
    has Str	$.org_table;
    has Str	$.db;
    has Str	$.catalog;
    has	Str	$.def;
    has ulong	$.length;
    has ulong	$.max_length;
    has uint32	$.name_length;
    has uint32	$.org_name_length;
    has uint32	$.table_length;
    has	uint32	$.org_table_length;
    has uint32	$.db_length;
    has uint32	$.catalog_length;
    has uint32	$.def_length;
    has uint32	$.flags;
    has uint32	$.decimals;
    has uint32	$.charsetnr;
    has int32	$.type;
    has Pointer $.extension;

    method AT-POS(Int $field)
    {
        nativecast(MYSQL_FIELD,
                   Pointer.new(nativecast(Pointer,self)
                               + $field * nativesizeof(MYSQL_FIELD)))
    }
}

class MYSQL_RES
{
    method fields(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_num_fields') {}

    method fetch-field(--> MYSQL_FIELD)
        is native(LIBMYSQL) is symbol('mysql_fetch_field') {}

    method fetch-fields(--> MYSQL_FIELD)
        is native(LIBMYSQL) is symbol('mysql_fetch_fields') {}

    method num-fields(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_num_fields') {}

    method fetch-row(--> CArray[Pointer])
        is native(LIBMYSQL) is symbol('mysql_fetch_row') {}

    method fetch-lengths(--> CArray[ulong])
        is native(LIBMYSQL) is symbol('mysql_fetch_lengths') {}

    method free()
        is native(LIBMYSQL) is symbol('mysql_free_result') {}
}

class DB::MySQL::Native is repr('CPointer')
{
    method client-version(--> uint32) { mysql_get_client_version }

    method client-info(--> Str) { mysql_get_client_info }

    method server-version(--> ulong)
        is native(LIBMYSQL) is symbol('mysql_get_server_version') {}

    method server-info(--> Str)
        is native(LIBMYSQL) is symbol('mysql_get_server_info') {}

    method host-info(--> Str)
        is native(LIBMYSQL) is symbol('mysql_get_host_info') {}

    method proto-info(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_get_proto_info') {}

    method ssl-cipher(--> Str)
        is native(LIBMYSQL) is symbol('mysql_get_ssl_cipher') {}

    method stat(--> Str)
        is native(LIBMYSQL) is symbol('mysql_stat') {}

    method info(--> Str)
        is native(LIBMYSQL) is symbol('mysql_info') {}

    method init(DB::MySQL::Native:U: --> DB::MySQL::Native)
        is native(LIBMYSQL) is symbol('mysql_init') {}

    method mysql_options(int32 $option, Blob $arg --> int32)
        is native(LIBMYSQL) is symbol('mysql_options') {}

    multi method option(mysql-option $option, Str:D $arg)
    {
        $.check($.mysql_options($option, $arg.encode))
    }

    multi method option(mysql-option $option, Int:D $i)
    {
        my CArray[uint32] $arg .= new($i);
        $.check($.mysql_options($option, $arg))
    }

    method errno(--> int32)
        is native(LIBMYSQL) is symbol('mysql_errno') {}

    method error(--> Str)
        is native(LIBMYSQL) is symbol('mysql_error') {}

    method connect(Str $host, Str $user, Str $passwd, Str $db,
                   uint32 $port, Str $unix-socket, ulong $client-flag
                   --> DB::MySQL::Native)
        is native(LIBMYSQL) is symbol('mysql_real_connect') {}

    method close()
        is native(LIBMYSQL) is symbol('mysql_close') {}

    method check(int32 $code = $.errno) is hidden-from-backtrace
    {
        die DB::MySQL::Error.new(:$code, message => $.error) unless $code == 0;
        self
    }

    method ping(--> int32)
        is native(LIBMYSQL) is symbol('mysql_ping') {}

    method insert-id(--> uint64)
        is native(LIBMYSQL) is symbol('mysql_insert_id') {}

    method query(Str --> int32)
        is native(LIBMYSQL) is symbol('mysql_query') {}

    method store-result(--> MYSQL_RES)
        is native(LIBMYSQL) is symbol('mysql_store_result') {}

    method use-result(--> MYSQL_RES)
        is native(LIBMYSQL) is symbol('mysql_use_result') {}

    method affected-rows(--> uint64)
        is native(LIBMYSQL) is symbol('mysql_affected_rows') {}

    method field-count(--> uint32)
        is native(LIBMYSQL) is symbol('mysql_field_count') {}

    method stmt-init(--> MYSQL_STMT)
        is native(LIBMYSQL) is symbol('mysql_stmt_init') {}
}
