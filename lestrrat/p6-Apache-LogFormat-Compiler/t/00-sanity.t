use v6;
use Test;
use Apache::LogFormat::Compiler;

if ! is(Apache::LogFormat::Compiler::string-value(""), "-", "string-value return '-' when an empty string is passed") {
    return
}
if ! is(Apache::LogFormat::Compiler::string-value(Nil), "-", "string-value return '-' when Nil is passed") {
    return
}

done-testing;
