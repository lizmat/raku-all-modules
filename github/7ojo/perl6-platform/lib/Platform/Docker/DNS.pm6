use v6;
use Platform::Container;
use Platform::Util::OS;

role Platform::Docker::DNS is Platform::Container {
    
    has Str $.name = 'DNS';
    has Str $.projectdir = 'service/dns';

    method start {
        my Platform::Docker::DNS $service;
        given Platform::Util::OS.detect() {
            when 'macos' {
                require Platform::Docker::DNS::MacOS;
                $service = Platform::Docker::DNS::MacOS.new(:$.network, :$.domain, :$.data-path);
            }
            when 'windows' {
                require Platform::Docker::DNS::Windows;
                $service = Platform::Docker::DNS::Windows.new(:$.network, :$.domain, :$.data-path);
            }
            default {
                require Platform::Docker::DNS::Linux;
                $service = Platform::Docker::DNS::Linux.new(:$.network, :$.domain, :$.data-path, :$.dns-port);
            }
        }
        $service.start();
    }

    method stop {
        given Platform::Util::OS.detect() {
            when 'macos' {
                require Platform::Docker::DNS::MacOS;
                return Platform::Docker::DNS::MacOS.new(:$.network, :$.domain, :$.data-path).stop;
            }
            when 'windows' {
                require Platform::Docker::DNS::Windows;
                return Platform::Docker::DNS::Windows.new(:$.network, :$.domain, :$.data-path).stop;
            }
            default {
                my $proc = run <docker stop -t 0>, 'platform-' ~ self.name.lc, :out, :err;
                self.last-result = self.result-as-hash($proc);
                return self;
            }
        }
    }

}

