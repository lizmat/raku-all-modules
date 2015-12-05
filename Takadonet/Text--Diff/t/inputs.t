use v6;
use Test;
plan 11;
use lib <blib lib>;

eval_lives_ok 'use Text::Diff', 'Can use Text::Diff';
use Text::Diff;

my @A = map {"$_\n"}, < 1 2 3 4 >;
my @B = map {"$_\n"}, < 1 2 3 5 >;

my $A = join "", @A;
my $B = join "", @B;


my $Af = "io_A";
my $Bf = "io_B";

my $fha = open("$Af", :w);
my $fhb = open("$Bf", :w);
$fha.print(@A);
$fhb.print(@B);

$fha.close();
$fhb.close();


my @tests = (
sub {
    ok !(text_diff @A, @A),'no diff';
},
sub {
    my $d = text_diff @A, @B;
    #really need to fix this ugly....
    if $d ~~ /\-4.*\+5/ {
        pass('a valid diff');
    }
    else {
        flunk('Did not find a diff');
    }
     
},
sub {
    ok !(text_diff $A, $A),'no Diff';
},
sub {
    my $d = text_diff $A, $B;
    if $d ~~ /\-4.*\+5/ {
        pass('a valid diff');
    }
    else {
        flunk('Did not find a diff');
    }
},
sub { ok !(text_diff_file $Af, $Af), 'no Diff' },
sub {
    my $d = text_diff_file($Af, $Bf);
    if $d ~~ /\-4.*\+5/ {
        pass('a valid diff');
    }
    else {
        flunk('Did not find a diff');
    }     
},
sub {
    my $fha = open("$Af", :r);
    my $fha2 = open("$Af", :r);
    #passing file handles    
    ok !text_diff $fha, $fha2;
    
    $fha.close();
    $fha2.close(); 
},
sub {
    my $fha = open("$Af", :r);
    my $fhb = open("$Bf", :r);
    #passing file handles
    my $d = text_diff($fha, $fhb);
    if $d ~~ /\-4.*\+5/ {
        pass('a valid diff');
    }
    else {
        flunk('Did not find a diff');
    }     

$fha.close();
$fhb.close();     
},
sub {
    ok !text_diff sub { @A}, sub { @A };
},
sub {
    my $d = text_diff sub { @A }, sub { @B };
    if $d ~~ /\-4.*\+5/ {
        pass('a valid diff');
    }
    else {
        flunk('Did not find a diff');
    }     
},
);

$_.() for @tests;

unlink $Af;
unlink $Bf;
