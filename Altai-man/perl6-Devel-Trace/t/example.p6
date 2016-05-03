use v6;


print "Statement 1 at line 4\n";
print "Statement 2 at line 5\n";
print "Call to sub x returns ", &x(), " at line 6.\n";

if 5 > 3 {
    say "True";
} else {
    say "False";
}

if 6 > 10 {
    say "False";
}

exit 0;

sub x {
    print "In sub x at line 21.\n";
    return 13;
}
