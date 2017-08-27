use Cro::Service;
use Cro::ZeroMQ::Socket::Pull;
use Cro::ZeroMQ::Socket::Push;
use Cro::ZeroMQ::Socket::Rep;
use Cro::ZeroMQ::Socket::Sub;

class Cro::ZeroMQ::Service does Cro::Service {
    method rep(:$connect, :$bind, :$high-water-mark,
               *@components) {
        Cro.compose(
            service-type => self.WHAT,
            Cro::ZeroMQ::Socket::Rep.new(:$connect, :$bind, :$high-water-mark),
            |@components)
    }

    method router(:$connect, :$bind, :$high-water-mark,
                  *@components) {
        Cro.compose(
            service-type => self.WHAT,
            Cro::ZeroMQ::Socket::Router.new(:$connect, :$bind, :$high-water-mark),
            |@components);
    }

    method pull(:$connect, :$bind, :$high-water-mark,
                *@components) {
        Cro.compose(
            service-type => self.WHAT,
            Cro::ZeroMQ::Socket::Pull.new(:$connect, :$bind, :$high-water-mark),
            |@components);
    }

    method pull-push(:$pull-bind, :$pull-connect,
                     :$push-bind, :$push-connect,
                     :$push-high-water-mark, :$pull-high-water-mark,
                     *@components) {
        Cro.compose(
            service-type => self.WHAT,
            Cro::ZeroMQ::Socket::Pull.new(bind => $pull-bind,
                                          connect => $pull-connect,
                                          high-water-mark => $pull-high-water-mark),
            |@components,
            Cro::ZeroMQ::Socket::Push.new(bind => $push-bind,
                                          connect => $push-connect,
                                          high-water-mark => $push-high-water-mark)
        );
    }

    method sub(:$connect, :$bind, :$high-water-mark,
               :$subscribe, :$unsubscribe,
               *@components) {
        Cro.compose(
            service-type => self.WHAT,
            Cro::ZeroMQ::Socket::Sub.new(:$connect, :$bind, :$high-water-mark,
                                         :$subscribe, :$unsubscribe),
            |@components);
    }
}
