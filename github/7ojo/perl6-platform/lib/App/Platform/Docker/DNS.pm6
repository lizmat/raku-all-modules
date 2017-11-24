use v6;
use App::Platform::Container;
use App::Platform::Util::OS;

role App::Platform::Docker::DNS is App::Platform::Container {
    
    has Str $.name = 'DNS';
    has Str $.projectdir = 'service/dns';

    method start {
        my App::Platform::Docker::DNS $service;
        given App::Platform::Util::OS.detect() {
            when 'macos' {
                require App::Platform::Docker::DNS::MacOS;
                $service = App::Platform::Docker::DNS::MacOS.new(:$.network, :$.domain, :$.data-path);
            }
            when 'windows' {
                require App::Platform::Docker::DNS::Windows;
                $service = App::Platform::Docker::DNS::Windows.new(:$.network, :$.domain, :$.data-path);
            }
            default {
                require App::Platform::Docker::DNS::Linux;
                $service = App::Platform::Docker::DNS::Linux.new(:$.network, :$.domain, :$.data-path, :$.dns-port);
            }
        }
        $service.start();
    }

    method stop {
        given App::Platform::Util::OS.detect() {
            when 'macos' {
                require App::Platform::Docker::DNS::MacOS;
                return App::Platform::Docker::DNS::MacOS.new(:$.network, :$.domain, :$.data-path).stop;
            }
            when 'windows' {
                require App::Platform::Docker::DNS::Windows;
                return App::Platform::Docker::DNS::Windows.new(:$.network, :$.domain, :$.data-path).stop;
            }
            default {
                my $proc = run <docker stop -t 0>, 'platform-' ~ self.name.lc, :out, :err;
                self.last-result = self.result-as-hash($proc);
                return self;
            }
        }
    }

}

