# Perl6 Bitcoin Client

This is a client for accessing the Bitcoin [REST API](https://github.com/bitcoin/bitcoin/blob/master/doc/REST-interface.md)

A Bitcoin Full Node with activated REST-API is needed.

To activate the API set the flag *rest* to **1** in
[bitcoin.conf](https://en.bitcoin.it/wiki/Running_Bitcoin) and open the port **8332**.

For more info on how to setup a Bitcoin Full Node visit [this page](http://blog.brakmic.com/running-a-full-bitcoin-node-on-raspberry-pi-3/).

# Functions

* [getTx(TX-HASH)](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L34)

* [getBlock(BLOCK-HASH)](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L46)

* [getHeaders(COUNT, BLOCK-HASH)](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L57)

* [getChainInfo()](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L69)

* [getMemPool()](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L78)

*  [getUtxos(UTXOS)](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/lib/Bitcoin/RPC/Client.pm6#L88)

Check the [example script](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/examples/client.p6) for more information about available functions.

## Installation

`zef install .`

## LICENSE

[Artistic License 2.0](https://github.com/brakmic/Perl6-Bitcoin-Client/blob/master/LICENSE)
