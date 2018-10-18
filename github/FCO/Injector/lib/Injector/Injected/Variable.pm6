use Injector::Bind;
use Injector::Injected;
unit role Injector::Injected::Variable does Injector::Injected;

method var {…}

method prepare-inject(Injector::Bind $injected-bind) {
    self.injected-bind = $injected-bind;
    self.block.add_phaser("ENTER", {
        #note "Inject on variable {$v.name} of type {$v.var.^name}";
        self.var = self.injected-bind.get-obj without self.var;
    })
}
