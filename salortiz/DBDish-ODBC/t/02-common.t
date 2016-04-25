use v6;
use Test;
need DBIish::CommonTesting;

DBIish::CommonTesting.new(
    :dbd<ODBC>,
    opts => {
	:conn-str('Driver=PostgreSQL;database=dbdishtest;uid=postgres')
    }
).run-tests;
