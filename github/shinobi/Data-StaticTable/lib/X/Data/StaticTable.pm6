use v6;

class X::Data::StaticTable is Exception {
    has Str $.message;
    method new($m) { return self.bless(message=>$m); }
    method message() { return $!message }
}
