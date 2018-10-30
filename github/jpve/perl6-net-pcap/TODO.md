TODO
====

Package            | Improvement
------------------ | ------------------------------
`Net::Pcap`        | Add DESTROY()
                   | Implement more functions from libpcap (see list below).
`Net::Pcap::Dump`  | Add DESTROY()
                   | Add test.
                   | Implement more functions from libpcap (see list below).
`Net::Pcap::C_Buf` | Check returns of C functions, and die on error.



Not yet implemented `libpcap` functions
---------------------------------------

* `pcap_lookupdev`
* `pcap_fopen_offline`
* `pcap_set_snaplen`
* `pcap_snapshot`
* `pcap_set_promisc`
* `pcap_set_rfmon`
* `pcap_can_set_rfmon`
* `pcap_set_timeout`
* `pcap_list_tstamp_types`
* `pcap_free_tstamp_types`
* `pcap_tstamp_type_val_to_name`
* `pcap_tstamp_type_val_to_description`
* `pcap_tstamp_type_name_to_val`
* `pcap_datalink`
* `pcap_file`
* `pcap_is_swapped`
* `pcap_major_version`
* `pcap_minor_version`
* `pcap_list_datalinks`
* `pcap_free_datalinks`
* `pcap_set_datalink`
* `pcap_datalink_val_to_name`
* `pcap_datalink_val_to_description`
* `pcap_datalink_name_to_val`
* `pcap_dispath`
* `pcap_loop`
* `pcap_breakloop`
* `pcap_setnonblock`
* `pcap_getnonblock`
* `pcap_get_selectable_fd`
* `pcap_lookupnet`
* `pcap_offline_filter`
* `pcap_setdirection`
* `pcap_stats`
* `pcap_dump_file`
* `pcap_dump_flush`
* `pcap_dump_ftell`
* `pcap_inject`
* `pcap_sendpacket`
* `pcap_statustostr`
* `pcap_lib_version`

