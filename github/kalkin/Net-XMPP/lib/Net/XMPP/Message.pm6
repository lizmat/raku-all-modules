unit class Net::XMPP::Message;

has $.from = '';
has $.to = '';
has $.type = '';
has $.id = '';
has @.body;

method Str {
    return "<message from='$.from' to='$.to' id='$.id' type='$.type'>" ~ (@.body.map({~$_}).join) ~ "</message>";
}
