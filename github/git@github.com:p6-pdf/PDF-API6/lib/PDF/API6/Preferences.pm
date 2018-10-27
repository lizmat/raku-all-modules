use PDF::Catalog;
class PDF::API6::Preferences {
    has PDF::Catalog $.catalog handles <OpenAction PageMode PageLayout>;
    method ViewerPreferences handles <HideToolbar HideMenubar HideWindowUI FitWindow CenterWindow DisplayDocTitle Direction NonFullScreenPageMode PrintScaling Duplex> {
        $!catalog.ViewerPreferences //= {};
    }
    method after-fullscreen is rw { self.NonFullScreenPageMode }
}
