use Testo;
use SupplyTimeWindow;

plan 14;

my Supplier $s1 .= new;

my Promise $fin1 .= new;

start {
    react whenever $s1.Supply.time-window: 3 -> $res {
        given ++$ {
            when 1 {
                is $res, [1]
            }
            when 2 {
                is $res, [1, 2]
            }
            when 3 {
                is $res, [2, 3]
            }
            when 4 {
                is $res, [2, 3, 4]
            }
            when 5 {
                is $res, [2, 3, 4, 5]
            }
            when 6 {
                is $res, [2, 3, 4, 5, 6]
            }
            when 7 {
                is $res, [7]
            }
            default {
                done
            }
        }
    }
    $fin1.keep
}

sub emit-next1 { $s1.emit: ++$ }

sleep 1;

emit-next1;
sleep 1;
emit-next1;
sleep 2;
emit-next1;
emit-next1() xx 3;
sleep 3;
emit-next1;

$s1.emit: -1;

await $fin1;

my Supplier $s2 .= new;

my Promise $fin2 .= new;

start {
    react whenever $s2.Supply.time-window: :transform{ .sum }, 3 -> $res {
        given ++$ {
            when 1 {
                is $res, 1
            }
            when 2 {
                is $res, [+] 1, 2
            }
            when 3 {
                is $res, [+] 2, 3
            }
            when 4 {
                is $res, [+] 2, 3, 4
            }
            when 5 {
                is $res, [+] 2, 3, 4, 5
            }
            when 6 {
                is $res, [+] 2, 3, 4, 5, 6
            }
            when 7 {
                is $res, 7
            }
            default {
                done
            }
        }
    }
    $fin2.keep
}

sub emit-next2 { $s2.emit: ++$ }

sleep 1;

emit-next2;
sleep 1;
emit-next2;
sleep 2;
emit-next2;
emit-next2() xx 3;
sleep 3;
emit-next2;

$s2.emit: -1;

await $fin2;
