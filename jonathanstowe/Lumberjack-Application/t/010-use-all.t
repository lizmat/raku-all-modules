#!perl6

use v6;

use Test;
plan 8;

use-ok "Lumberjack::Template::Provider" , "lib/Lumberjack/Template/Provider.pm";
use-ok "Lumberjack::Dispatcher::Proxy"  , "lib/Lumberjack/Dispatcher/Proxy.pm";
use-ok "Lumberjack::Dispatcher::Supply" , "lib/Lumberjack/Dispatcher/Supply.pm";
use-ok "Lumberjack::Application" , "lib/Lumberjack/Application.pm";
use-ok "Lumberjack::Application::Index" , "lib/Lumberjack/Application/Index.pm";
use-ok "Lumberjack::Application::WebSocket" , "lib/Lumberjack/Application/WebSocket.pm";
use-ok "Lumberjack::Application::PSGI" , "lib/Lumberjack/Application/PSGI.pm";
use-ok "Lumberjack::Message::JSON" , "lib/Lumberjack/Message/JSON.pm";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
