class Cro::ZeroMQ::IllegalBind is Exception {
    has $.reason;

    method message() {
        "ZeroMQ Component was initialized incorrectly, $!reason."
    }
}

role Cro::ZeroMQ::Component {
    has $.connect;
    has $.bind;
    has $.high-water-mark;

    method new(:$connect = Nil, :$bind = Nil, :$high-water-mark) {
        die Cro::ZeroMQ::IllegalBind.new(:reason<you need to specify connect or bind>) unless so $connect^$bind;
        self.bless(:$connect, :$bind, :$high-water-mark)
    }
}
