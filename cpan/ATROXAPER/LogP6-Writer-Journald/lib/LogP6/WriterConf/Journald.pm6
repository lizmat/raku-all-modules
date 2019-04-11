use LogP6::WriterConf::Pattern;
use LogP6::WriterConf;
use LogP6::Level;
use LogP6::Writer::Journald;

my $priorities = [];
$priorities[Level::trace.Int] = 'PRIORITY=7'; # journald DEBUG
$priorities[Level::debug.Int] = 'PRIORITY=6'; # journald INFO
$priorities[Level::info.Int]  = 'PRIORITY=5'; # journald NOTICE
$priorities[Level::warn.Int]  = 'PRIORITY=4'; # journald WARNING
$priorities[Level::error.Int] = 'PRIORITY=3'; # journald ERR
$priorities .= List;

class Journald::Priority does LogP6::WriterConf::Pattern::PatternPart {
	method show($context) { $priorities[$context.level] }
}

class Journald::CodeFile does LogP6::WriterConf::Pattern::PatternPart {
	method show($context) { 'CODE_FILE=' ~ $context.callframe.file }
}

class Journald::CodeLine does LogP6::WriterConf::Pattern::PatternPart {
	method show($context) { 'CODE_LINE=' ~ $context.callframe.line }
}

class Journald::CodeFunc does LogP6::WriterConf::Pattern::PatternPart {
	method show($context) { 'CODE_FUNC=' ~ $context.callframe.code.name }
}

class Journald::MDC does LogP6::WriterConf::Pattern::PatternPart {
	method show($context) {
		my $result = $context.mdc.kv.map(-> $k, $v {$k ~ '=' ~ $v}).List;
		return |$result[0..30] if $result.elems > 30;
		return |$result;
	}
}

class LogP6::WriterConf::Journald does LogP6::WriterConf {
	has Str $.name;
	has Str $.pattern;
	has Bool $.auto-exceptions;
	has Bool $.use-priority;
	has Bool $.use-code-file;
	has Bool $.use-code-line;
	has Bool $.use-code-func;
	has Bool $.use-mdc;
	has LogP6::Writer::Journald::Systemd $.systemd;

	method name(--> Str) {
		$!name;
	}

	method clone-with-name($name --> LogP6::WriterConf:D) {
		self.clone(:$name);
	}

	method self-check(--> Nil) {
		return without $!pattern;
		X::LogP6::PatternIsNotValid.new(:$!pattern).throw
				unless so Grammar.parse($!pattern);
	}

	method make-writer(*%defaults --> LogP6::Writer:D) {
		my $auto-ex = $!auto-exceptions // %defaults<default-auto-exceptions>;
		my $pattern = $!pattern // %defaults<default-pattern>;
		$pattern ~= %defaults<default-x-pattern> if $auto-ex;

		my $systemd = $!systemd // LogP6::Writer::Journald::Systemd::Native.new;

		my $parts = [];
		$parts.push(Journald::Priority) if $!use-priority;
		$parts.push(Journald::CodeFile) if $!use-code-file;
		$parts.push(Journald::CodeLine) if $!use-code-line;
		$parts.push(Journald::CodeFunc) if $!use-code-func;
		$parts.push(Journald::MDC) if $!use-mdc;

		LogP6::Writer::Journald
				.new(:$pattern, :$systemd, :journald-parts($parts.List));
	}

	method close() {
		# do nothing
	}
}