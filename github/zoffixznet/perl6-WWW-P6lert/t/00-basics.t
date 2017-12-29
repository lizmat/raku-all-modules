use lib <lib>;
use Test::When <online>;
use Testo;

plan 6;

use WWW::P6lert;
my $alerts = WWW::P6lert.new: |(:api-url($_) with %*ENV<WWW_P6LERT_API_URL>);
is $alerts, WWW::P6lert, '.new makes right object';

group '.all' => 3 => {
    (my $all := $alerts.all).cache;
    is $all, Seq, 'returns Seq';
    is $all, *.so, '.all gives some alerts';
    is $all.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
}

group '.since' => 5 => {
    is $alerts.since(1514316067), *.so, '.since with old date gives some alerts';
    is $alerts.since(time + 999999), *.not, 'no alerts in .since with future date';

    group 'UInt time' => 3 => {
        (my $since := $alerts.since: 1514316067).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }

    group 'Date time' => 3 => {
        (my $since := $alerts.since: DateTime.new(1514316067).Date).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }

    group 'DateTime time' => 3 => {
        (my $since := $alerts.since: DateTime.new: 1514316067).cache;
        is $since, Seq, 'returns Seq';
        is $since, *.so, '.all gives some alerts';
        is $since.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
    }
}

group '.last' => 5 => {
    is $alerts.last(2), 2, '.last(2) gives 2 alerts';
    is $alerts.last(1), 1, '.last(1) gives 1 alert';

    (my $last := $alerts.last: 10).cache;
    is $last, Seq, 'returns Seq';
    is $last, *.so, '.all gives some alerts';
    is $last.all, WWW::P6lert::Alert, 'all items are WWW::P6lert::Alert objects';
}

group '.alert' => 6 => {
    my @alerts := $alerts.last(2).List;
    my $alert1 = $alerts.alert: @alerts.head.id;
    my $alert2 = $alerts.alert: @alerts.tail.id;
    is-eqv $alert1, @alerts.head, "got right alert (ID  {@alerts.head.id})";
    is-eqv $alert2, @alerts.tail, "got right alert (ID  {@alerts.tail.id})";

    my $err := $alerts.alert: 999_999;
    is $err, Failure, 'getting non-existent alert gives a Failure';
    is $err.handled, *.not, 'failure is unhandled';
    is $err.exception, WWW::P6lert::X::NotFound, 'failure has right exception';
    is $err.exception, WWW::P6lert::X, 'exception matches with role';
    $err.so;

}

group 'WWW::P6lert::X::Network' => 5 => {
    sub test-err (\desc, \err) {
        group (desc) => 4 => {
            is err, Failure, 'getting non-existent alert gives a Failure';
            is err.handled, *.not, 'failure is unhandled';
            is err.exception, WWW::P6lert::X::Network,
                'failure has right exception';
            is err.exception, WWW::P6lert::X, 'exception matches with role';
            err.so;
        }
    }
    my $broken-alerts := WWW::P6lert.new: :api-url<foos-non-existent>;

    test-err '.all', $broken-alerts.all;
    test-err '.last', $broken-alerts.last: 5;
    test-err '.since(Dateish)', $broken-alerts.since: DateTime.now;
    test-err '.since(UInt)', $broken-alerts.since: 42;
    test-err '.alert', $broken-alerts.alert: 42;
}
