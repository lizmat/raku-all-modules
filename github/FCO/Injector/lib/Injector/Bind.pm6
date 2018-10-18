unit role Injector::Bind;

has         $.type              ;
has Str     $.name     = ""     ;
has Capture $.capture  = \()    ;
has Mu      $!obj      = $!type ;
has Bool    $!has-obj  = False  ;

method bind-type {…}
method get-obj   {…}

method gist {
   "{$.bind-type}: name: {$!name.perl}; type: {$!type.^name}; capture: {$!capture.perl}; obj: {$!obj.gist}; {self.WHERE}"
}

method add-obj($obj, Bool :$override) {
	fail "Trying to bind obj but bind already have a object setted. If you realy want to do that, use ':override'"
		if $!has-obj and not $override;
	$!has-obj = True;
	$!obj = $obj
}
method instantiate {
	$!obj.WHAT.bless: |$!capture
}
