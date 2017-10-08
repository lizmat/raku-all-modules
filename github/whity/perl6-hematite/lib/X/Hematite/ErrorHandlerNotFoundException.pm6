use X::Hematite::Exception;

unit class X::Hematite::ErrorHandlerNotFoundException is X::Hematite::Exception;

has Str $!name;

submethod BUILD(Str :$name) {
    $!name = $name;
}

method message() {
    return "ErrorHandlerNotFoundException({ $!name })";
}
