Host Configurations
===================

macOS: DNS
----------

Default setup on macOS is that we have two DNS servers created by Platform tool. One for the queries from host side and nother for docker containers.

1. Create file ``/etc/resolver/localhost`` ::
      
      nameserver 127.0.0.1

#. Test your setup (after ``platform create``) ::
      
      $ ping proxy.localhost
      PING proxy.localhost (127.0.0.1): 56 data bytes
      64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.041 ms
      64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.046 ms

In future we'll probably use https://github.com/mal/docker-for-mac-host-bridge to get real working docker network available on host side, but the time when platform got first dns server implementation this was too unstable.

Linux: DNS
----------

Platform tries to create DNS service on port 53, but which is on most systems already used by dnsmasq. Platform in this case will try to open service on next open port and then we can configure system's dnsmasq to use platform DNS server for default ``.localhost`` network addresses. 

1. Create file ``/etc/NetworkManager/dnsmasq.d/localhost`` ::
      
      server=/localhost/127.0.0.1#54

#. Restart NetworkManager ::
      
      $ sudo service NetworkManager restart

#. Test your setup (after ``platform create``) ::
      
      $ ping dns.localhost
      PING dns.localhost (172.17.0.2) 56(84) bytes of data.
      64 bytes from 172.17.0.2: icmp_seq=1 ttl=64 time=0.021 ms
      64 bytes from 172.17.0.2: icmp_seq=2 ttl=64 time=0.049 ms


