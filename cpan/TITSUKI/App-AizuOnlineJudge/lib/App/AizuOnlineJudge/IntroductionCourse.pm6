use v6;
use App::AizuOnlineJudge::Submittable;

unit class App::AizuOnlineJudge::IntroductionCourse:ver<0.0.1>;
also does App::AizuOnlineJudge::Submittable;

has $.code;
has $.problem-number;
has $.user;
has $.lesson-id;
has $.language;
has %!form;

submethod BUILD(:$!code, :$!problem-number, :$!user, :$!lesson-id, :$!language, Bool :$mockable = False) {
    self.validate-code($!code);
    self.validate-language($!language);
    self.validate-problem-number($!problem-number);
    self.login(user => $!user, password => self.get-password(:$mockable)) unless $mockable;

    my Str $problem-id = $!lesson-id ~ '_' ~ $!problem-number;
    %!form := {
        problemId => $problem-id,
        language => $!language,
        sourceCode => $!code.IO.slurp
    };
}

method run {
    my Str $token = self.post-code(:%!form);
    self.ask-result($token).say;
}

method validate-problem-number($problem-number --> Bool) {
    if $problem-number.chars != 1 {
        die "ERROR: Invalid problem-number was specified";
    }
    if not $problem-number ~~ m/<[A .. Z]> ** 1/ {
        die "ERROR: Invalid problem-number was specified";
    }
    return True;
}
