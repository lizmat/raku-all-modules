unit class X::CucumisSextus::FeatureParseFailure is Exception;

has $.message;

method new($message) {
    return self.bless(message => $message);
}

