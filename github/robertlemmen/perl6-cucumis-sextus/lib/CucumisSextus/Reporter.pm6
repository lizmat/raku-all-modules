unit role CucumisSextus::Reporter;

method before-run() {}
method skipped-feature($feature) { }
method before-feature($feature) { }
method skipped-scenario($feature, $scenario) { }
method before-scenario($feature, $scenario) { }
method step($feature, $scenario, $step, $result) { }
method after-scenario($feature, $scenario, $result) { }
method after-feature($feature, $result) { }
method after-run() {}

# XXX should have global failed() getter
