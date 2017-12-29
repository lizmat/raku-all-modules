role WWW::P6lert::X is Exception {}
class WWW::P6lert::X::NotFound does WWW::P6lert::X {
    method message { 'Alert not found' }
}
class WWW::P6lert::X::Network does WWW::P6lert::X {
    has $.error;
    method message { "P6lert API network error occured: $!error" }
}

class WWW::P6lert {
    use WWW;

    has $.api-url = %*ENV<WWW_P6LERT_API_URL> // 'https://alerts.perl6.org/api/v1';

    sub err ($_) {
        .exception.message.starts-with('Error 404')
            ?? WWW::P6lert::X::NotFound.new
            !! WWW::P6lert::X::Network.new: :error(.exception.message);
    }

    class Alert {
        trusts WWW::P6lert;

        has UInt:D $.id       is required;
        has Str:D  $.alert    is required;
        has UInt:D $.time     is required;
        has Str:D  $.creator  is required;
        has Str:D  $.affects  is required;
        has Str:D  $.severity is required;

        method  new { X::Cannot::New.new: :class(::?CLASS) }
        method !new { self.bless: |%_ }
    }

    submethod TWEAK () { $!api-url .= subst: / '/'+ $ /, '' }

    method all {
        (jget "$!api-url/all"
            orelse fail .&err)<alerts>.map: { Alert!Alert::new: |$_ }
    }
    method last(UInt $n where * < 1_000_000) {
        (jget "$!api-url/last/$n"
            orelse fail .&err)<alerts>.map: { Alert!Alert::new: |$_ }
    }
    multi method since (Dateish $time) {
        self.since: $time.DateTime.Instant.to-posix.head.Int
    }
    multi method since (UInt $time) {
        (jget "$!api-url/since/$time"
            orelse fail .&err)<alerts>.map: { Alert!Alert::new: |$_ }
    }
    method alert (UInt $id) {
        Alert!Alert::new: |(jget "$!api-url/alert/$id"
            orelse fail .&err)<alert>
    }
}
