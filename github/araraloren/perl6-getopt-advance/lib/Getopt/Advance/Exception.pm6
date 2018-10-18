
unit module Getopt::Advance::Exception;

class X::GA::Exception is Exception {
    has Str $.message;
}

class X::GA::ParseError is X::GA::Exception { }

sub ga-parse-error(Str $msg) is export {
    X::GA::ParseError
    .new(message => $msg)
    .throw;
}

constant &ga-try-next is export = &ga-parse-error;

class X::GA::OptionError is X::GA::Exception { }

sub ga-option-error(Str $msg) is export {
    X::GA::OptionError
    .new(message => $msg)
    .throw;
}

class X::GA::GroupError is X::GA::Exception { }

sub ga-group-error(Str $msg) is export {
    X::GA::GroupError
    .new(message => $msg)
    .throw;
}

class X::GA::NonOptionError is X::GA::Exception { }

sub ga-non-option-error(Str $msg) is export {
    X::GA::NonOptionError
    .new(message => $msg)
    .throw;
}

constant &ga-invalid-value is export = &ga-option-error;

class X::GA::Error is X::GA::Exception { }

sub ga-raise-error(Str $msg) is export {
    X::GA::Error
    .new(message => $msg)
    .throw;
}

class X::GA::WantPrintHelper is X::GA::Exception { }

sub ga-want-helper() is export {
    X::GA::WantPrintHelper.new().throw;
}

class X::GA::WantPrintAllHelper is X::GA::Exception { }

sub ga-want-all-helper() is export {
    X::GA::WantPrintAllHelper.new().throw;
}
