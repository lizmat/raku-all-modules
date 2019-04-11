use Test;

use lib 'lib';
use lib './t/resources/00-config-file';
use LogP6 :configure;
use LogP6::WriterConf::Journald;
use Custom;

plan 4;

writer(LogP6::WriterConf::Journald.new(
	:name<journald-1>, :systemd(Custom::TestSystemd.new), :pattern('%level %msg'),
	:use-priority, :use-code-line, :use-code-file, :use-code-func, :use-mdc,
	:auto-exceptions
));

writer(LogP6::WriterConf::Journald.new(
	:name<journald-2>, :systemd(Custom::TestSystemd.new), :pattern('%msg'),
	:use-priority
));
cliche(:name<journald-1>, :matcher<journald-1>, grooves => ('journald-1', level($trace)));
cliche(:name<journald-2>, :matcher<journald-2>, grooves => ('journald-2', level($trace)));

test('code');

init-from-file('./t/resources/00-config-file/log-p6.json');

test('file');

sub foo($log) {
	$log.warn('boom'); return callframe(0);
}

sub test($type) {
	my $log;
	my $frame;

	$log = get-logger('journald-1');
	$log.mdc-put('OBJ', 'value');
	$log.mdc-put('VAL', 'obj');
	$frame = foo($log);
	is-deeply get-writer('journald-1').systemd.sent.sort,
		('CODE_FILE=' ~ $frame.file, 'CODE_FUNC=' ~ $frame.code.name,
		'CODE_LINE=' ~ $frame.line, 'MESSAGE=WARN boom', 'OBJ=value',
		'PRIORITY=4', 'VAL=obj'), "$type journald-1 sent";

	$log = get-logger('journald-2');
	$log.mdc-put('OBJ', 'value');
	$log.mdc-put('VAL', 'obj');
	$frame = foo($log);
	is-deeply get-writer('journald-2').systemd.sent.sort,
		('MESSAGE=boom', 'PRIORITY=4',), "$type journald-2 sent";
}


done-testing;
