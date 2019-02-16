use v6;
use App::AizuOnlineJudge::Submittable;

unit class App::AizuOnlineJudge::BasicCourse:ver<0.0.2>;
also does App::AizuOnlineJudge::Submittable;

has $.code;
has $.problem-number;
has $.user;
has $.language;
has %!form;

submethod BUILD(Str :$!code, Cool :$!problem-number, Str :$!user, Str :$!language, Bool :$mockable = False) {
    self.validate-code($!code);
    self.validate-language($!language);
    self.validate-problem-number($!problem-number);
    self.login(user => $!user, password => self.get-password(:$mockable)) unless $mockable;

    %!form = %(
        problemId => sprintf("%04d", $!problem-number),
        language => $!language,
        sourceCode => $!code.IO.slurp;
    );
}

method run {
    my Str $token = self.post-code(:%!form);
    self.ask-result($token).say;
}

method validate-problem-number($problem-number --> Bool) {
    if $problem-number.chars != 4 {
        die "ERROR: Invalid problem-number was specified";
    }
    if not $problem-number ~~ m/\d ** 4/ {
        die "ERROR: Invalid problem-number was specified";
    }
    return True;
}
