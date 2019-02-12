use v6;
use Test;
use App::AizuOnlineJudge;
use App::AizuOnlineJudge::BasicCourse;
use App::AizuOnlineJudge::IntroductionCourse;
use App::AizuOnlineJudge::Submittable;

{
    dies-ok { my $aoj = App::AizuOnlineJudge::IntroductionCourse.new(code => "t/I.found.that.perl6.is.fun", problem-number => "A", user => "perl6isfun", language => "C++", lesson-id => "ITP1_1", mockable => True); }
    dies-ok { my $aoj = App::AizuOnlineJudge::BasicCourse.new(code => "t/I.found.that.perl6.is.fun", problem-number => "0000", user => "perl6isfun", language => "C++", mockable => True); }
}

{
    lives-ok { my $aoj = App::AizuOnlineJudge::IntroductionCourse.new(code => "t/empty.cpp", problem-number => "A", user => "perl6isfun", language => "C++", lesson-id => "ITP1_1", mockable => True); }
}

{
    lives-ok { my $aoj = App::AizuOnlineJudge::BasicCourse.new(code => "t/empty.cpp", problem-number => "0000", user => "perl6isfun", language => "C++", mockable => True); }
}

{
    my $submittable = class { also does App::AizuOnlineJudge::Submittable; method validate-problem-number($problem-number) {}; method run() {}; };
    dies-ok { $submittable.validate-language("LOLCODE") };
    dies-ok { $submittable.validate-language("RPG") };
    dies-ok { $submittable.validate-language("Perl55") };
    dies-ok { $submittable.validate-language("Scala3") };
    dies-ok { $submittable.validate-language("C+++") };
    dies-ok { $submittable.validate-language("C+") };
    is $submittable.validate-language("Scala"), True;
    is $submittable.validate-language("C++"), True;
}

{
    my $aoj;
    lives-ok { $aoj = App::AizuOnlineJudge::BasicCourse.new(code => "t/empty.cpp", problem-number => "0000", user => "perl6isfun", language => "C++", mockable => True); }
    dies-ok { $aoj.validate-problem-number("10000"); }
    dies-ok { $aoj.validate-problem-number("100"); }
    dies-ok { $aoj.validate-problem-number("A"); }
    lives-ok { $aoj.validate-problem-number("1000"); }
}

{
    my $aoj;
    lives-ok { $aoj = App::AizuOnlineJudge::IntroductionCourse.new(code => "t/empty.cpp", problem-number => "A", user => "perl6isfun", language => "C++", lesson-id => "ITP1_1", mockable => True); }
    dies-ok { $aoj.validate-problem-number("10000"); }
    dies-ok { $aoj.validate-problem-number("100"); }
    dies-ok { $aoj.validate-problem-number("1000"); }
    lives-ok { $aoj.validate-problem-number("A"); }
}


done-testing;
