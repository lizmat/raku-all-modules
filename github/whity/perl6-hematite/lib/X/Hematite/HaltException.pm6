use X::Hematite::DetachException;

unit class X::Hematite::HaltException is X::Hematite::DetachException;

has %.attributes = ();

submethod BUILD(*%args) {
    %!attributes = %args;
    return self;
}

method FALLBACK(Str $name) {
    return %.attributes{$name};
}

method message() returns Str {
    return 'halt exception';
}
