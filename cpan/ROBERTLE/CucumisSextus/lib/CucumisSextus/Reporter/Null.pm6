use CucumisSextus::Reporter;

unit class CucumisSextus::Reporter::Null does CucumisSextus::Reporter;

method before-feature($feature) {
}

method before-scenario($feature, $scenario) { 
}

method skipped-feature($feature) { 
}

method skipped-scenario($feature, $scenario) { 
}

method step($feature, $scenario, $step, $result) { 
}

method after-scenario($feature, $scenario, $result) { 
}

method after-run() {
}
