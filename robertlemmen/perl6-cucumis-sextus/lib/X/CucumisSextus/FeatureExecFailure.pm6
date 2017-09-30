unit class X::CucumisSextus::FeatureExecFailure is Exception;

has $.message;

method new($message) {
    return self.bless(message => $message);
}

