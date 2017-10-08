use X::Hematite::Exception;

unit class X::Hematite::TemplateNotFoundException is X::Hematite::Exception;

has Str $.path;

submethod BUILD(Str :$path) {
    $!path = $path;
}

method message() {
    return "TemplateNotFoundException({ self.path })";
}
