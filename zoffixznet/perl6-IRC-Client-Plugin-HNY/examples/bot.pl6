use lib <
    /home/zoffix/CPANPRC/IRC-Client/lib
    /home/zoffix/services/lib/IRC-Client/lib
    /home/zoffix/services/lib/WWW-Google-Time/lib
    lib
>;
use IRC::Client;
use IRC::Client::Plugin::HNY;

.run with IRC::Client.new:
    :host(%*ENV<HNY_HOST> // 'irc.freenode.net')
    :password('secret.txt'.IO.slurp.trim)
    :nick<HNYBot>
    :channels<#perl6 #zofbot #freenode-newyears>
    :debug
    :plugins[
        IRC::Client::Plugin::HNY.new,
    ];
