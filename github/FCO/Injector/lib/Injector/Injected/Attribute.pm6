use Injector::Bind;
use Injector::Injected;
unit role Injector::Injected::Attribute does Injector::Injected;

method package {…}

method prepare-inject(Injector::Bind $injected-bind) {
    self.injected-bind = $injected-bind;
    if not self.package.^find_method("inject-attributes") {
        self.package.^add_method("inject-attributes", method (\SELF:) {
            for self.^attributes.grep: Injector::Injected -> $attr {
                #note "Inject on attribute {self.name} of type {self.type.^name}";
                $attr.set_value: SELF, $attr.injected-bind.get-obj without $attr.get_value: SELF
            }
        });
        if self.package.^find_method("TWEAK") -> &tweak {
            &tweak.wrap: method (|) { self.inject-attributes; nextsame }
        } else {
            self.package.^add_method("TWEAK", method (|) {self.inject-attributes})
        }
    }
}
