module Threads;

class Task {
    has Mu $!task;
    has $.code;

    method schedule {
        my Mu $do := nqp::getattr(
            pir::perl6_decontainerize__PP($!code), Code, '$!do'
        );
        my Mu $task := pir::new__PSP('Task', $do);
        nqp::bindattr(self, Task, '$!task', $task);
        pir::schedule__0P($task);

        return self; # allow chaining
    }

    method join {
        pir::wait__0P($!task);
    }

    method kill {
        $!task.kill();
        1;
    }
}

sub async(&code) is export {
    my $wrapper = sub (Mu) {
        &code()
    };

    return Task.new(code => $wrapper).schedule
}
