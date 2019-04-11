use NativeCall;
use LogP6::Writer;
use LogP6::WriterConf::Pattern;

#| Class for sender log message to journald service.
role LogP6::Writer::Journald::Systemd {
	#|[Send message to journald.
	#| @fields - journald fields in format '<filed-name>=<field-value>']
	method send(*@fields) { ... }
}

class LogP6::Writer::Journald does LogP6::Writer {
	has Str:D $.pattern is required;
	has Positional $.journald-parts is required;
	has LogP6::Writer::Journald::Systemd:D $.systemd is required;

	has @!pieces;

	submethod TWEAK() {
		@!pieces := Grammar.parse($!pattern, actions => Actions).made;
	}

	method write($context) {
		$!systemd.send(
			'MESSAGE=' ~ @!pieces>>.show($context).join(''),
			|$.journald-parts>>.show($context)
		);
	}
}

class LogP6::Writer::Journald::Systemd::Native
		does LogP6::Writer::Journald::Systemd
{
	sub send01(Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send02(Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send03(Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send04(Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send05(Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send06(Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send07(Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send08(Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send09(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send10(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send11(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send12(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send13(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send14(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send15(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send16(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send17(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send18(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send19(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send20(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send21(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send22(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send23(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send24(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send25(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send26(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send27(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send28(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send29(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send30(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send31(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send32(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send33(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send34(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }
	sub send35(Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str, Str --> int32)
			is native('systemd') is symbol('sd_journal_send') { * }

	has @!send-array = [Any,
		&send01, &send02, &send03, &send04, &send05, &send06, &send07, &send08, &send09, &send10,
		&send11, &send12, &send13, &send14, &send15, &send16, &send17, &send18, &send19, &send20,
		&send21, &send22, &send23, &send24, &send25, &send26, &send27, &send28, &send29, &send30,
		&send31, &send32, &send33, &send34, &send35];

	method send(*@fields) {
		my $grep = @fields.grep(*.defined).List;
		@!send-array[$grep.elems](|$grep, Str);
	}
}
