TODO
====

Package                             | Improvements
----------------------------------- | ----------------------------
`Net::Packet::Ethernet`             | Add test for `encode()`.
`Net::Packet::EtherType`            | Add more enum values.
`Net::Packet::IP_proto`             | Add more enum values.
`Net::Packet::ARP`                  | Add test for `encode()`.
`Net::Packet::ARP::HardwareType`    | Add more enum values.
`Net::Packet::ICMP`                 | `$.type` and `$.code` should be enums.
`Net::Packet::*`                    | Add documentation for `$.frame` and `$.data` to each module that inherits from `Net::Packet::Base`

