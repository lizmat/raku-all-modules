use MONKEY-TYPING;
augment class Supply {

    multi method time-window($seconds --> Supply) {
        self
            .map(-> $i {[{:time(now), :value($i)},]})
            .produce(-> @arr, @last {
                [ |@arr.skip(@arr.first(:k, {.<time> >= @last.head<time> - $seconds}) // *), |@last ]
            })
            .map(-> $values { @($values)>>.<value> })
        ;
    }

    multi method time-window($seconds, :&transform! --> Supply) {
        callwith($seconds)
            .map(&transform)
        ;
    }
}
