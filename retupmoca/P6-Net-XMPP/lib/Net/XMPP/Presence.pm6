class Net::XMPP::Presence;

has $.from = '';
has $.to = '';
has $.type = '';
has $.id = '';
has @.body;

method Str {
    return "<presence from='$.from' to='$.to' id='$.id' type='$.type'>" ~ (@.body.map({~$_}).join) ~ "</presence>";
}
