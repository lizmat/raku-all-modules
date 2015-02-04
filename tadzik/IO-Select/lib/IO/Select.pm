pir::loadlib__Ps('select');

class IO::Select {
    has $!pmc;

    submethod BUILD {
        $!pmc := pir::new__Ps('Select');
    }

    method add($handle) {
        my Mu $fh := nqp::getattr(
            nqp::decont($handle), $handle.WHAT, '$!PIO'
        );
        my $mode = 4;
        if nqp::can($fh, 'mode') {
            $mode += 2 if nqp::p6box_s($fh.mode) eq 'w';
            $mode += 1 if nqp::p6box_s($fh.mode) eq 'r';
        } else {
            $mode += 3; # XXX We just assume it's IO::Socket or so
        }
        $!pmc.update($fh, $handle, nqp::unbox_i($mode));
        True;
    }

    # The following methods all return lists of the objects that
    # were added with the add method.
    # The timeout is in seconds.

    method can_read($timeout as Num) {
        $!pmc.can_read(nqp::unbox_n($timeout));
    }

    method can_write($timeout as Num) {
        $!pmc.can_write(nqp::unbox_n($timeout));
    }

    method has_exception($timeout as Num) {
        $!pmc.has_exception(nqp::unbox_n($timeout));
    }

    # This method returns a list of three lists containing the objects
    # that were added with the add method.
    method select($timeout as Num) {
        $!pmc.select(nqp::unbox_n($timeout));
    }
}
