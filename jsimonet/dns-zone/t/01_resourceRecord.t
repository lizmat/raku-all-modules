use v6;

use Test;

use lib 'lib';
use DNS::Zone::Grammars::Modern;

my @toTestAreOk = (
	'bla IN A 10.10.0.42',
	"bla A 10.10.0.42",
	'IN AAAA  2000:1000:1000:1000:2000:1000:1000:1000',
	'testttl IN 42s A 10.0.0.42',
	'testttl	 IN     42m A 10.0.0.42', # different spaces,
	'testttl MX 10 bla', # '10 bla' is part of MX RDATA'
	"testmultiline(
	IN(
	42s)
	AAAA
) 1000:1000:1000:1000:2000:1000:1000:1000",
	"testmultiline (
	IN (
	)) AAAA ::1",
	'@ IN SOA ns0.simonator.info. kernel.simonator.info. 2015020801 604800 86400 2419200 604800', # oneline soa,
	'@ IN SOA ns0.simonator.info. kernel.simonator.info. (
	2015020801 ; serial
	604800     ; refresh
	86400      ; retry
	2419200    ; expire
	604800 )   ; negative cache ttl',
	# soa is generally writed in multiline, with comments
	# only one soa by zone definition',
	'1.0.0.10.IN-ADDR.ARPA	IN	PTR	pointed',
	'_sip._tcp.com in srv 0 5 5060 sipserver.example.com.',
);

my @toTestAreNOk = (
	"bla IN A 10.10.0.42\n",
	"bla IN\nA 10.0.0.42", # must have a parenthese to be multi-line
	'bla IN IN A 10.0.0.42',
	'_bla IN IN A 10.0.0.42',
);

plan @toTestAreOk.elems + @toTestAreNOk.elems;

for @toTestAreOk -> $t
{
	ok DNS::Zone::Grammars::Modern.parse($t, rule => 'resourceRecord' ), $t;
}

for @toTestAreNOk -> $t
{
	nok DNS::Zone::Grammars::Modern.parse($t, rule => 'resourceRecord' ), $t;
}
