#!/usr/bin/perl6
use v6;
use IO::Prompt;

my $question = asker('Give me one?',type=>Int);
while asker('Do some calculation?') {
    my $a = $question.ask;
    my $b = $question.ask;
    say "$a * $b = " ~ $a*$b;
}
say '------------------------------';

my $q;
$q = asker( 'No default?' );
say ? $q;
say + $q;
say ~ $q;
say $q.ask_yn;
say '------------------------------';

my $a;
$a = ask( "Defaults to 42?", 42 );
say $a.perl;
say '------------------------------';

$a = ask( "Defaults to 42, type Num?", 42, :type(Num) );
say $a.perl;
say '------------------------------';

$a = ask( "Defaults to false?", Bool::False );
say $a.perl;
say '------------------------------';

$a = ask( "No default but type Bool?", :type(Bool) );
say $a.perl;
say '------------------------------';


## OO style ##
my $prompt = IO::Prompt.new();

$a = $prompt.ask( "Dot notation?", Bool::False );
say $a.perl;
say '------------------------------';

# $a = ask $prompt: "Indirect object notation?";
# say $a.perl;
# say '------------------------------';


## You can override the IO methods for testing purposes
class IO::Prompt::Testable is IO::Prompt {
    method !do_say( Str $question ) returns Bool {
        say "Testable saying    '$question'";
        say 'Please do not continue questioning';
        return Bool::False; # do not continue
    }
    method !do_prompt( Str $question ) returns Str {
        say "Testable saying    '$question'";
        say "Testable answering 'daa'";
        return 'daa';
    }
}

my $prompt_test = IO::Prompt::Testable.new();
$a = $prompt_test.ask_yn( "Testable, defaults to false?", Bool::False );
say $a.perl;
say '------------------------------';


## You can override the language class attributes
class IO::Prompt::Finnish is IO::Prompt {
    our Str $.lang_prompt_Yn        = 'K/e';
    our Str $.lang_prompt_yN        = 'k/E';
    our Str $.lang_prompt_yn        = 'k/e';
    our Str $.lang_prompt_yn_retry  = 'Sano kyllä tai ei';
    our     $.lang_prompt_match_y   = m/ ^^ <[kK]> /;
    our     $.lang_prompt_match_n   = m/ ^^ <[eE]> /;
    our Str $.lang_prompt_int       = 'Int';
    our Str $.lang_prompt_int_retry = 'Anna kokonaisluku';
    our Str $.lang_prompt_num       = 'Num';
    our Str $.lang_prompt_num_retry = 'Anna luku';
    our Str $.lang_prompt_str       = 'Str';
    our Str $.lang_prompt_str_retry = 'Anna merkkijono';
}

my $prompt_fi = IO::Prompt::Finnish.new();
$a = $prompt_fi.ask( "Suomeksi Bool?", :type(Bool) );
say $a.perl;
say '------------------------------';
$a = $prompt_fi.ask( "Suomeksi Num?", :type(Num) );
say $a.perl;
say '------------------------------';
$a = $prompt_fi.ask( "Suomeksi Str?", :type(Str) );
say $a.perl;
say '------------------------------';


# vim: ft=perl6
