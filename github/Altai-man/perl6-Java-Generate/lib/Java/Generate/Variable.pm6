use Java::Generate::Statement;
use Java::Generate::Utils;

unit module Java::Generate::Variable;

class InstanceVariable does Java::Generate::Statement::Variable is export {
    has AccessLevel $.access;

    method generate(--> Str) {
        my $code = "{$!access}{@!modifiers ?? ' ' ~ @!modifiers.join(', ') !! '' } {$!type} {$!name}";
        $code ~  ($!default ?? " = {$!default.generate};" !! ";")
    }

    method reference(--> Str) { "this.{$!name}" }
}

class StaticVariable does Java::Generate::Statement::Variable is export {
    has AccessLevel $.access = '';
    has Str $.class;

    method generate(--> Str) {
        my $code = "{$!access} static{@!modifiers ?? ' ' ~ @!modifiers.join(', ') !! '' } {$!type} {$!name}";
        $code ~  ($!default ?? " = {$!default.generate};" !! ";")
    }

    method reference(--> Str) {
        "{$!class}.{$!name}"
    }
}

class InterfaceField does Java::Generate::Statement::Variable is export {
    method generate(--> Str) {
        die "Interface field '{$!name}' must have an initializer" unless $!default;
        "{$!type} {$!name} = {$!default ~~ Variable ?? $!default.reference() !! $!default.generate()};"
    }
}
