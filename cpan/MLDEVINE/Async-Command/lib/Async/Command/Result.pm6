unit        class Async::Command::Result:ver<0.0.3>:auth<Mark Devine (mark@markdevine.com)>;

has Str     @.command;
has Int     $.exit-code = 1;
has Str     $.stderr-results is required;
has Str     $.stdout-results is required;
has Real    $.time-out = 0;
has Bool    $.timed-out = False;
has Str     $.unique-id;

=finish
