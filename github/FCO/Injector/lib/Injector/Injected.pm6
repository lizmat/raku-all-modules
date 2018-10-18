use Injector::Bind;
unit role Injector::Injected;
has Bool    $.injected              = True  ;
has         $.injected-bind is rw           ;

method prepare-inject(Injector::Bind $injected-bind) {…}
