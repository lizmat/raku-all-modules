use v6;
use Test;
use IO::Prompter;

class StubIO is IO::Handle {
    has @.input handles (:push<push>, :get<shift>, :queue-input<push>);
    has @.output handles (:print<push>);
    multi method t() { Bool::True; }
}

plan *;

{
    my $stub = StubIO.new(:input("10", "20", "fdfd", "40"));

    my @results;
    prompt :in($stub), :out($stub), -> Str $i {
        isa-ok $i, Str, "Block gets Str as specified";
        @results.push($i);
    };
    
    is ~@results, ~(10, 20, "fdfd", 40), "Got the correct results";
}

{
    my $stub = StubIO.new(:input("10", "20", "fdfd", "40"));

    my @results;
    prompt :in($stub), :out($stub), -> Int $i {
        isa-ok $i, Int, "Block gets Int as specified";
        @results.push($i);
    };
    
    is ~@results, ~(10, 20, 40), "Got the correct results";
}

{
    my $stub = StubIO.new(:input("10", "20.2", "fdfd", "40e20"));

    my @results;
    prompt :in($stub), :out($stub), -> Num $i {
        isa-ok $i, Num, "Block gets Num as specified";
        @results.push($i);
    };
    
    is ~@results, ~(10, 20.2, 40e20), "Got the correct results";
}

{
    my $stub = StubIO.new(:input("yes", "no", "green", "no", "yes"));

    my @results;
    prompt :in($stub), :out($stub), -> Bool $i {
        isa-ok $i, Bool, "Block gets Bool as specified";
        @results.push($i);
    };
    
    is ~@results, ~(Bool::True, Bool::False, Bool::False, Bool::True), "Got the correct results";
}

{
    my $stub = StubIO.new(:input("10", "20", "fdfd", "40", "Hello!"));

    my @results;
    prompt :in($stub), :out($stub), -> Str $i where /\D/ {
        isa-ok $i, Str, "Block gets Str as specified";
        @results.push($i);
    };
    
    is ~@results, ~("fdfd", "Hello!"), "Got the correct results";
}

# MUST: Figure out how to get this working again
# {
#     subset Coefficient of Num where 0..1;
#     
#     my $stub = StubIO.new(:input("10", "0.5", "fdfd", "0.0", "1", "Hello!"));
# 
#     my @results;
#     prompt :in($stub), :out($stub), -> Coefficient $i {
#         isa-ok $i, Coefficient, "Block gets Coefficient as specified";
#         @results.push($i);
#     };
#     
#     is ~@results, ~(0.5, 0.0, 1), "Got the correct results";
# }

done-testing;
