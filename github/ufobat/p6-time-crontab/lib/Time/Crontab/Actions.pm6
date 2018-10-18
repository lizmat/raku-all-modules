use Time::Crontab::Set;

class Time::Crontab::Actions {

    my %dow-map = (
        sun => 0,
        mon => 1,
        tue => 2,
        wed => 3,
        thu => 4,
        fri => 5,
        sat => 6,
    );
    my %month-map = (
        jan => 1,
        feb => 2,
        mar => 3,
        apr => 4,
        may => 5,
        jun => 6,
        jul => 7,
        aug => 8,
        sep => 9,
        oct => 10,
        nov => 11,
        dec => 12,
    );

    method dow-number($/) { $/.make: +$/ % 7 }
    method dow-name($/) { $/.make: + %dow-map{ lc(~$/) } }
    method dow-value($/) { $/.make: $/<dow-number>.made // $/<dow-name>.made }
    method dows($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::dow, $/);
    }

    method month-number($/) { $/.make: +$/ }
    method month-name($/) { $/.make: + %month-map{ lc(~$/) } }
    method month-value($/) { $/.make: $/<month-number>.made // $/<month-name>.made }
    method months($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::month, $/);
    }

    method dom-value($/) { $/.make: +$/ }
    method doms($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::dom, $/);
    }

    method hour-value($/) { $/.make: +$/ }
    method hours($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::hour, $/);
    }

    method minute-value($/) { $/.make: +$/ }
    method minutes($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::minute, $/);
    }

    method !make_node(Time::Crontab::Set::Type $type, Match $/) {
        my $prefix = $type.Str;
        my $set = Time::Crontab::Set.new(type => $type);

        for $/{$prefix}.map({ .hash.pairs[0] }) -> $p {
            given $p.key {
                when $prefix ~ '-value'    { $set.enable($p.value.made) }
                when $prefix ~ '-any'      { $set.enable-any() }
                when $prefix ~ '-any-step' {
                    my $step = $p.value{$prefix ~ '-value'}.made;
                    $set.enable-any($step)
                }
                when $prefix ~ '-range'    {
                    my ($from, $to) = $p.value{$prefix ~ '-value'}».made;
                    $set.enable($from, $to);
                }
                when $prefix ~ '-range-step' {
                    my ($from, $to, $step) = $p.value{$prefix ~ '-value'}».made;
                    $set.enable($from, $to, $step);
                }
                when $prefix ~ '-disable' {
                    my $value = $p.value{$prefix~ '-value'}.made;
                    $set.disable($value);
                }
            }
        }
        return $set;
    }

    method TOP($/) {
        my @set = ($/<minutes>.made, $/<hours>.made, $/<doms>.made, $/<months>.made, $/<dows>.made);
        $/.make: @set;
    }
}
