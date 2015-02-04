class Net::Packet::Base;

my constant Base is export(:short) ::= Net::Packet::Base;

has Base $.parent is rw;
has $.frame is rw;
has $.data is rw;


