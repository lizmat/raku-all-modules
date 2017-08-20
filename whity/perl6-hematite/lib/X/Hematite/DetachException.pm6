use X::Hematite::Exception;

unit class X::Hematite::DetachException is X::Hematite::Exception;

method message() returns Str {
    return 'detach exception';
}
