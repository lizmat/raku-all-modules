use v6;
unit class Algorithm::AhoCorasick::Node:ver<0.0.10>;

has Set $.matched-string is rw;
has Algorithm::AhoCorasick::Node %.transitions is rw;
has Algorithm::AhoCorasick::Node $.failure is rw;

submethod TWEAK {
    $!matched-string = set();
}
