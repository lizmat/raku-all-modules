use lib <lib>;
use Test;
use Temp::Path;
plan 10;

use Reminders;
my Reminders $rem .= new: :db-file(make-temp-path);

$rem.add: 'pick up milk',      when => DateTime.new: :2000year;
$rem.add: 'get starship fuel', when => DateTime.new(:2222year),
    :who<Zoffix>, :where<space>;

is-deeply $rem.all».Capture, (
  \(:id(2), :!seen, :what("get starship fuel"),
    :when(Instant.from-posix(7952342400.0, Bool::False)),
    :where<space>, :who<Zoffix>
  ),
), '.all';

is-deeply $rem.all(:all)».Capture, (
  \(:id(2), :!seen, :what("get starship fuel"),
    :when(Instant.from-posix(7952342400.0, Bool::False)),
    :where<space>, :who<Zoffix>
  ),
  \(:id(1), :seen, :what("pick up milk"),
    :when(Instant.from-posix(946684800.0, Bool::False)), :where(""), :who(""))
), '.all: :all';

is-deeply $rem.rem(2).Capture, \(
    :id(2), :!seen, :what("get starship fuel"),
    :when(Instant.from-posix(7952342400.0, Bool::False)),
    :where("space"), :who("Zoffix")
), '.rem: extant ID';

is-deeply $rem.rem(42), Nil, '.rem: non-existent ID';

$rem.mark-seen: 2;
is-deeply $rem.rem(2).seen, True, '.mark-seen: Int';
$rem.mark-unseen: 1;
is-deeply $rem.rem(1).seen, False, '.mark-unseen: Int';

$rem.mark-seen: $rem.rem: 1;
is-deeply $rem.rem(1).seen, True, '.mark-seen: Reminders::Rem';
$rem.mark-unseen: $rem.rem: 2;
is-deeply $rem.rem(2).seen, False, '.mark-unseen: Reminders::Rem';

subtest '.mark-unseen rescheduling' => {
    plan 2;
    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk', :1in;
    react whenever $rem {
        with ++$ {
            when 1 {
                pass 'seen first reminder';
                $rem.mark-unseen: 1, :re-schedule;
                $rem.done;
            }
            pass 'seen rescheduled reminder';
        }
    }
}

subtest '.removed scheduled reminders get removed from schedule' => {
    plan 2;

    my Reminders $rem .= new: :db-file(make-temp-path);
    $rem.add: 'pick up milk',      :2in;
    $rem.add: 'get starship fuel', :10in;

    react whenever $rem {
        pass 'received first reminder... removing rest';
        $rem.remove: 2;
        $rem.done;
    }
    pass 'got out of whenever';
}
