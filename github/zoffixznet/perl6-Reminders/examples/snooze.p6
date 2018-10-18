use lib <lib>;
use Reminders;

my Reminders $rem .= new;
$rem.add: 'one', :who<Zoffix>, :where<space>, :1in;
$rem.add: 'two', :who<Meows>,  :where<perl6>, :2in;

react whenever $rem -> $r {
    say "Reminder: $r.what() [$r.who() / $r.where()]";
    once {
        $rem.snooze: $r, :3in;
        $rem.done;
    }
}

# OUTPUT (exits after printing last line):
# Reminder: one [Zoffix / space]
# Reminder: two [Meows / perl6]
# Reminder: one [Zoffix / space]
