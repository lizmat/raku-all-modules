use v6.c;

class X::Trait::Env::Required::Not::Set is Exception is export {
    has $.payload;
    method message() {
        $.payload;
    }
}
