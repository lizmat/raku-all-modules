use v6;

constant %SIGNAL_ACTION = {
    SigBlk => 'Blocked',
    SigIgn => 'Ignored',
    SigCgt => 'Catched',
};

class Linux::Process::SignalInfo:ver<v0.0.2>:auth<github:Gnouc> {

    has Int $.pid is required;
    has %!signal_info;
    has %!signal_data;
    has Str $.error is rw = '';

    method !is_bit_set($mask, $n) returns Bool {
        return ($mask +& (1 +< ($n - 1))).Bool;
    }

    method read() {
        for $.pid.fmt('/proc/%d/status').IO.lines -> $line {
            last if $line eq '';
            my ($type, $value) = $line.split(':');
            if %SIGNAL_ACTION{$type}:exists {
                %!signal_info{$type} = Int('0x' ~ $value.trim);
            }
        }
        CATCH {
            default {
                $.error = .Str;
            }
        }

        return %!signal_info;
    }

    method parse() {
        for %!signal_info.kv -> $action, $mask {
            for $*KERNEL.signals.kv -> $sig_num, $signal {
                next unless $signal ~~ Signal;
                next unless $sig_num;
                next unless self!is_bit_set($mask, $sig_num);
                %!signal_data{$action}.push($signal);
            }
        }
        return %!signal_data;
    }

    method pprint() {
        for %!signal_data.kv -> $k, $v {
            "%SIGNAL_ACTION{$k}: $v.gist()".say;
        }
        return;
    }
}
