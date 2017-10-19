use lib <lib>;
use Reminders;

my Reminders $rem .= new;
say "Setting up some reminders up to 20 seconds in the future";
$rem.add: '5 seconds passed',  :5in;
$rem.add: '15 seconds passed', :when(now+15), :who<Zoffix>, :where<#perl6>;

react whenever $rem {
    say "Reminder: $^reminder";
    once $rem.add('One more thing, bruh', :15in).done;
}

# OUTPUT (exits after printing last line):
# Reminder: 5 seconds passed
# Reminder: Zoffix@#perl6 15 seconds passed
# Reminder: One more thing, bruh
