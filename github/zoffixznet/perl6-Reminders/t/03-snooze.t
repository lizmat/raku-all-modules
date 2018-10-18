use lib <lib>;
use Test;
use Temp::Path;
plan 4;

use Reminders;

subtest '.snooze: Reminder::Rem:D, :in' => {
    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk',      :1in;
    $rem.add: 'get starship fuel', :1in;

    my @stuff;
    react whenever $rem {
        @stuff.push: ~$_;
        once { $rem.snooze: $_, :1in; $rem.done; }
    }

    is-deeply @stuff, [«'pick up milk' 'get starship fuel' 'pick up milk'»],
        'right reminders';
}

subtest '.snooze: ID, :in' => {
    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk',      :1in;
    $rem.add: 'get starship fuel', :1in;

    my @stuff;
    react whenever $rem {
        @stuff.push: ~$_;
        once { $rem.snooze: .id, :1in; $rem.done; }
    }

    is-deeply @stuff, [«'pick up milk' 'get starship fuel' 'pick up milk'»],
        'right reminders';
}

subtest '.snooze: Reminder::Rem:D, :when' => {
    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk',      :1in;
    $rem.add: 'get starship fuel', :1in;

    my @stuff;
    react whenever $rem {
        @stuff.push: ~$_;
        once { $rem.snooze: $_, :when(now+1); $rem.done; }
    }

    is-deeply @stuff, [«'pick up milk' 'get starship fuel' 'pick up milk'»],
        'right reminders';
}

subtest '.snooze: ID, :when' => {
    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk',      :1in;
    $rem.add: 'get starship fuel', :1in;

    my @stuff;
    react whenever $rem {
        @stuff.push: ~$_;
        once { $rem.snooze: .id, :when(now+1); $rem.done; }
    }

    is-deeply @stuff, [«'pick up milk' 'get starship fuel' 'pick up milk'»],
        'right reminders';
}
