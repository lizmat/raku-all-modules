unit        class Async::Command::Multi:ver<0.0.3>:auth<Mark Devine (mark@markdevine.com)>;

use         Async::Command;

subset CSpec where * ~~ List|Array|Async::Command;

has Int     $.batch is rw = 16;
has CSpec   %.command is required;
has Promise @!promises;
has Real    $.default-time-out = 0;
has         %!result;
has Promise $!master-promise;

method sow () {
    $!master-promise = start {
        for %!command.keys -> $unique-id {
            if %!command{$unique-id}.WHAT ~~ Async::Command {
                %!command{$unique-id}.unique-id = $unique-id without %!command{$unique-id}.unique-id;
                push @!promises, start %!command{$unique-id}.run;
            }
            else {
                my Async::Command $cmd .= new(:command(|%!command{$unique-id}), :$unique-id);
                if $!default-time-out {
                    push @!promises, start $cmd.run(:time-out($!default-time-out));
                }
                else {
                    push @!promises, start $cmd.run;
                }
            }
            if @!promises == $!batch {
                my @reorg-promises;
                await Promise.anyof(@!promises);
                for @!promises -> $promise {
                    if $promise.status ~~ /^Kept$/ {
                        %!result{$promise.result.unique-id} = $promise.result;
                    }
                    else {
                        @reorg-promises.append: $promise;
                    }
                }
                @!promises = @reorg-promises;
            }
        }
        my @results = await @!promises;
        for @results -> $result {
            %!result{$result.unique-id} = $result;
        }
    }
    self;
}

method reap () {
    await $!master-promise;
    return %!result;
}

=finish
