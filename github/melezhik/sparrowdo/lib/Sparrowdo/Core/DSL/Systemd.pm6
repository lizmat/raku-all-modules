use v6;

unit module Sparrowdo::Core::DSL::Systemd;

use Sparrowdo;

use Sparrowdo::Core::DSL::Template;

sub systemd-service( $name, %opts? ) is export {

    my %params = %opts;

    my $templ = "

[Unit]
Description=[% name %]
After=network.target

[Service]
Type=simple
User=[% user %]
WorkingDirectory=[% workdir %]
ExecStart=[% command %]
Restart=on-failure

[Install]
WantedBy=multi-user.target
";

  template-create "/etc/systemd/system/$name.service", %(
    source => $templ,
    variables => %opts,
    on_change => "echo reload systemctl daemon; systemctl daemon-reload"
  );
  
}




