use v6;
unit class Growl::GNTP;

has Str $.host = '127.0.0.1';
has Int $.port = 23053;

method register(
    Str   :$application!,
    Array :$notifications!,
) {
    my $sock = IO::Socket::INET.new(
        host => self.host,
        port => self.port,
    );
    my $count = @$notifications.elems;
    my $form = qq:heredoc 'EOT';
GNTP/1.0 REGISTER NONE
EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));
    $form = qq:heredoc 'EOT';
Application-Name: {{$application}}
Notifications-Count: {{$count.Str}}

EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));

    for @$notifications {
        $form = qq:heredoc 'EOT';
Notification-Name: {{.{'name'}||'default'}}
Notification-Display-Name: {{.{'display-name'}||'default'}}
Notification-Enabled: {{.{'enabled'}||'True'}}

EOT
        $sock.print($form.subst(/\n/, "\r\n", :g));
    }
    $sock.print("\r\n\r\n");
    my $line = $sock.get();
    if $line ~~ 'ERROR' {
        my $bt = '';
        while (my $line = $sock.get()) {
            last if $line.trim eq '';
            $bt ~= "{{$line.trim}}\n";
        }
        die $bt;
    }
    $sock.close;
}

method notify(
    Str  :$application!,
    Str  :$name!,
    Str  :$title!,
    Str  :$text!,
    Str  :$id? = '',
    Bool :$sticky? = False,
    Int  :$priority? = 1,
    Str  :$icon? = '',
) {
    my $sock = IO::Socket::INET.new(
        host => self.host,
        port => self.port,
    );
    my $form = qq:heredoc 'EOT';
GNTP/1.0 NOTIFY NONE
EOT
    $sock.print($form.subst(/\n/, "\r\n", :g));
    $form = qq:heredoc 'EOT';
Application-Name: {{$application}}
Notification-Name: {{$name}}
Notification-Title: {{$title}}
Notification-ID: {{$id}}
Notification-Priority: {{$priority}}
Notification-Sticky: {{$sticky.Str}}
Notification-Text: {{$text}}
Notification-Icon: {{$icon}}
Notification-Display-Name: {{"default"}}
EOT
    $sock.print($form.subst(/\n/, "\r\r\n", :g));
    $sock.print("\r\n");
    my $line = $sock.get();
    if $line ~~ 'ERROR' {
        my $bt = '';
        while (my $line = $sock.get()) {
            last if $line.trim eq '';
            $bt ~= "{{$line.trim}}\n";
        }
        die Growl::GNTP::Exception.new(
            method       => 'NOTIFY',
            error-string => $bt,
        );
    }
    $sock.close;
}

class Growl::GNTP::Exception is Exception {
    has $.method;
    has $.error-string;
}

=begin pod

=head1 NAME

Growl::GNTP - blah blah blah

=head1 SYNOPSIS

  use Growl::GNTP;

=head1 DESCRIPTION

Growl::GNTP is ...

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Yasuhiro Matsumoto <mattn.jp@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
