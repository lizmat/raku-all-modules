use v6;
use Test;
use Apache::LogFormat::Compiler;

is Apache::LogFormat::Compiler::string-value(""), "-", "string-value return '-' when an empty string is passed"
    or return;

is Apache::LogFormat::Compiler::string-value(Nil), "-", "string-value return '-' when Nil is passed"
    or return;

done-testing;
