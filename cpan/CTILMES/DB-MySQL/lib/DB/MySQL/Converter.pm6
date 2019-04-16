use NativeCall;
use JSON::Fast;
use DB::MySQL::Native;

sub malloc(size_t --> Pointer) is native {}

sub mysql-value-Blob(Pointer $bufptr, Int $length)
{
    buf8.new(nativecast(CArray[int8], $bufptr)[^$length])
}

sub mysql-value-Str(Pointer $bufptr, Int $length)
{
    mysql-value-Blob($bufptr, $length).decode
}

sub mysql-value-int8(Pointer $bufptr, Int $length)
{
    nativecast(Pointer[int8], $bufptr).deref
}

sub mysql-value-int16(Pointer $bufptr, Int $length)
{
    nativecast(Pointer[int16], $bufptr).deref
}

sub mysql-value-int32(Pointer $bufptr, Int $length)
{
    nativecast(Pointer[int32], $bufptr).deref
}

sub mysql-value-int64(Pointer $bufptr, Int $length)
{
    nativecast(Pointer[int64], $bufptr).deref
}

sub mysql-value-Int(Pointer $bufptr, Int $length)
{
    mysql-value-Str($bufptr, $length).Int
}

sub mysql-value-Rat(Pointer $bufptr, Int $length)
{
    mysql-value-Str($bufptr, $length).Rat
}

sub mysql-value-Num(Pointer $bufptr, Int $length)
{
    mysql-value-Str($bufptr, $length).Num
}

sub mysql-value-Null(Pointer $bufptr, Int $length)
{
    Any
}

sub mysql-value-Date(Pointer $bufptr, Int $length)
{
    Date.new(mysql-value-Str($bufptr, $length))
}

sub mysql-value-DateTime(Pointer $bufptr, Int $length)
{
    DateTime.new(mysql-value-Str($bufptr, $length).split(' ')
                 .join('T')):timezone($*TZ)
}

sub mysql-value-JSON(Pointer $bufptr, Int $length)
{
    from-json(mysql-value-Str($bufptr, $length))
}

my %types = Map.new: map( { +mysql-type::{.key} => .value },
(
    MYSQL_TYPE_DECIMAL =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Rat,
        strvalue => &mysql-value-Rat,
        nullvalue => Rat
    ),
    MYSQL_TYPE_TINY =>
    %(
        bufsize  => 1,
        buftype  => MYSQL_TYPE_TINY,
        binvalue => &mysql-value-int8,
        strvalue => &mysql-value-Int,
        nullvalue => Int
    ),
    MYSQL_TYPE_SHORT =>
    %(
        bufsize  => 1,
        buftype  => MYSQL_TYPE_SHORT,
        binvalue => &mysql-value-int16,
        strvalue => &mysql-value-Int,
        nullvalu => Int
    ),
    MYSQL_TYPE_LONG =>
    %(
        bufsize  => 4,
        buftype  => MYSQL_TYPE_LONGLONG,
        binvalue => &mysql-value-int32,
        strvalue => &mysql-value-Int,
        nullvalue => Int
    ),
    MYSQL_TYPE_FLOAT =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Num,
        strvalue => &mysql-value-Num,
        nullvalue => Num
    ),
    MYSQL_TYPE_DOUBLE =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Num,
        strvalue => &mysql-value-Num,
        nullvalue => Num
    ),
    MYSQL_TYPE_NULL =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_NULL,
        binvalue => &mysql-value-Null,
        strvalue => &mysql-value-Null,
        nullvalue => Any
    ),
    MYSQL_TYPE_TIMESTAMP =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-DateTime,
        strvalue => &mysql-value-DateTime,
        nullvalue => DateTime
    ),
    MYSQL_TYPE_LONGLONG =>
    %(
        bufsize  => 8,
        buftype  => MYSQL_TYPE_LONGLONG,
        binvalue => &mysql-value-int64,
        strvalue => &mysql-value-Int,
        nullvalue => Int
    ),
    MYSQL_TYPE_INT24 =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Int,
        strvalue => &mysql-value-Int,
        nullvalue => Int
    ),
    MYSQL_TYPE_DATE =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Date,
        strvalue => &mysql-value-Date,
        nullvalue => Date
    ),
    MYSQL_TYPE_DATETIME =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-DateTime,
        strvalue => &mysql-value-DateTime,
        nullvalue => DateTime
    ),
    MYSQL_TYPE_YEAR =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Int,
        strvalue => &mysql-value-Int,
        nullvalue => Int
    ),
    MYSQL_TYPE_JSON =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-JSON,
        strvalue => &mysql-value-JSON,
        nullvalue => Any
    ),
    MYSQL_TYPE_NEWDECIMAL =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Rat,
        strvalue => &mysql-value-Rat,
        nullvalue => Rat
    ),
    MYSQL_TYPE_TINY_BLOB =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_TINY_BLOB,
        binvalue => &mysql-value-Blob,
        strvalue => &mysql-value-Blob,
        nullvalue => Blob
    ),
    MYSQL_TYPE_MEDIUM_BLOB =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_MEDIUM_BLOB,
        binvalue => &mysql-value-Blob,
        strvalue => &mysql-value-Blob,
        nullvalue => Blob
    ),
    MYSQL_TYPE_LONG_BLOB =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_LONG_BLOB,
        binvalue => &mysql-value-Blob,
        strvalue => &mysql-value-Blob,
        nullvalue => Blob
    ),
    MYSQL_TYPE_BLOB =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_BLOB,
        binvalue => &mysql-value-Blob,
        strvalue => &mysql-value-Blob,
        nullvalue => Blob
    ),
    MYSQL_TYPE_STRING =>
    %(
        bufsize  => 0,
        buftype  => MYSQL_TYPE_STRING,
        binvalue => &mysql-value-Str,
        strvalue => &mysql-value-Str,
        nullvalue => Str
    ),
));

class DB::MySQL::Converter
{
    method value($type, $bufptr, $len)
    {
        with %types{$type} //
             %types{+mysql-type::{MYSQL_TYPE_STRING}}
        {
            $bufptr ?? .<strvalue>($bufptr, $len) !! .<nullvalue>
        }
    }

    method bind-value($type, MYSQL_BIND $bind, Bool :$null)
    {
        with %types{$type} //
             %types{+mysql-type::{MYSQL_TYPE_STRING}}
        {
            ($bind.bufptr && !$null)
                ?? .<binvalue>($bind.bufptr, $bind.len)
                !! .<nullvalue>
        }
    }

    method make-buffer(MYSQL_BIND $bind, MYSQL_FIELD $field)
    {
        with %types{$field.type} //
             %types{+mysql-type::{MYSQL_TYPE_STRING}}
        {
            $bind.buffer_type = .<buftype>;
            $bind.buffer_length = .<bufsize> || $field.length;
            $bind.buffer = malloc($_) with $bind.buffer_length;
        }
    }
}
