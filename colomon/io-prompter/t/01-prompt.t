use v6;
use Test;
use IO::Prompter;

class StubIO is IO {
    has @.input handles (:push<push>, :get<shift>, :queue-input<push>);
    has @.output handles (:print<push>);
    multi method t() { Bool::True; }
}

plan *;

{
    my $stub = StubIO.new;
    
    $stub.queue-input("Hello!");
    $stub.queue-input("Look at this!");
    is $stub.get(), "Hello!", "Queued input works okay";
    is $stub.get(), "Look at this!", "Queued input works okay, part 2";
    
    $stub.print("Let's see what happens here");
    $stub.print("or here", "here", "here");
    is $stub.output[0], "Let's see what happens here", "Stored output works okay, part 1";
    is $stub.output[1], "or here", "Stored output works okay, part 2";
    is $stub.output[2], "here", "Stored output works okay, part 3";
    is $stub.output[3], "here", "Stored output works okay, part 4";
}

{
    my $stub = StubIO.new(:input("blue", ""));
    my $result = prompt("Color", :in($stub), :out($stub));
    ok $result, "Result is true";
    is $result, "blue", "Successfully input blue";
    is $stub.output[0], "Color: ", "Properly added colon & space at end of prompt";
    is prompt("Color:", :default("Chartreuse"), :in($stub), :out($stub)),
       "Chartreuse", "Successfully got default input";
}

{
    my $stub = StubIO.new(:input("Lolz", "zebra-striped", "white"));
    is prompt("Color:", :must({'not include the letter zed' => {!($_ ~~ /z/)} }), 
                               :in($stub), :out($stub)),
       "white", "Successfully input white";
}

{
    my $stub = StubIO.new(:input("3", ""));
    is prompt("Age", :integer, :in($stub), :out($stub)),
       3, "Successfully input integer 3";
    is $stub.output[0], "Age: ", "Properly added colon & space at end of prompt";
    is prompt("Age:", :integer, :default(42), :in($stub), :out($stub)),
       42, "Successfully got default input";
}

{
    my $stub = StubIO.new(:input("Hello!", "blue 42", "23.3", "4 2", "", "-345", "0", "13"));
    is prompt("Age:", :integer,
                      :must({'be greater than 0' => {$_ > 0} }), 
                      :in($stub), :out($stub)),
       13, "Successfully input integer 13";
}

{
    my $stub = StubIO.new(:input("3.5", ""));
    is prompt("Weight:", :number, :in($stub), :out($stub)),
       3.5, "Successfully input number 3.5";
    is $stub.output[0], "Weight: ", "Properly added space at end of prompt";
    is prompt("Weight:", :number, :default(42), :in($stub), :out($stub)),
       42, "Successfully got default input";
}

{
    my $stub = StubIO.new(:input("Hello!", "blue 42", "4 2", "", "-345", "0", "13.6"));
    is prompt("Weight:", :number,
                                :must({'be greater than 0' => {$_ > 0} }), 
                                :in($stub), :out($stub)),
       13.6, "Successfully input number 13.6";
}

{
    my $stub = StubIO.new(:input("yes", "no"));
    ok prompt("Married?", :yesno, :in($stub), :out($stub)),
       "Successfully got Bool::True";
    is $stub.output[0], "Married? ", "Properly added space at end of prompt";
    nok prompt("Married?", :yesno, :in($stub), :out($stub)),
        "Successfully got Bool::False";
}



done;
