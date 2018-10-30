use v6;
use FileSystem::Capacity::VolumesInfo;
use Package::Updates;

unit module System::DiskAndUpdatesAlerts;

sub send-alerts(:$smtp-server, :$smtp-port, :$from, :$to, :$disk-limit-percent) is export {

  my $hostname = qx[hostname];
  my $alert-disk = False;
  my $color = '#eee';
  my $report = '';

  my $disk-header = '<p><b>Mount points capacity</b></p><table><thead><th>Location</th><th>Total</th><th>Used</th><th>%Used</th><th>Free</th></thead><tbody>';

  # disk

  my %vols-human = volumes-info(:human);

  my $disk-body = '';

  for %vols-human.sort(*.key)>>.kv -> ($location, $data) {

    my $used-percent = $data<used%>;
    $used-percent ~~ s/\%//;

    if $used-percent >= $disk-limit-percent {

      $alert-disk = True;

      if $color eq '#eee' { $color = '#fff'; } else { $color = '#eee'; }

      $disk-body ~= "<tr bgcolor=$color><td>" ~ $location ~ "</td><td align='right'>" ~ $data<size> ~ "<td align='right'>" ~ $data<used> ~ "</td><td align='right'>" ~ $data<used%> ~ "</td><td align='right'>" ~ $data<free> ~ "</td></tr>";

    }
  }

  if $alert-disk {

    $report ~= $disk-header ~ $disk-body ~ '</tbody></table>';

  } else {
    $report ~= "<p>All mounted points have less of $disk-limit-percent% of capacity.</p>";
  }

  # updates

  my $alert-updates = False;

  my $updates-header = '<p><b>Pending Updates</b></p><table><thead><th>Package</th><th>Current</th><th>New</th></thead><tbody>';
  my $updates-body = '';

  my %updates = get-updates();

  for %updates.sort(*.key)>>.kv -> ($name, $data) {

    if $data<new> { $alert-updates = True };

    if $color eq '#eee' { $color = '#fff'; } else { $color = '#eee'; }

    $updates-body ~= "<tr bgcolor=$color><td>" ~ $name ~ "</td><td align='right'>" ~ $data<current> ~ "<td align='right'>" ~ $data<new> ~ '</td></tr>';
  }

  if $alert-updates {

    $report ~= '<br />' ~ $updates-header ~ $updates-body;

  } else {

    $report ~= '<p>No new packages available.</p>';
  }

  # sending email

  my $message = qq:to/HTML/;
  From: $from
  To: $to
  Subject: $hostname - Disk Capacity and Updates
  Content-Type: text/html; charset=utf-8

  <style>
  body \{font-family: arial;\}
  p \{font-family: arial;\}
  table\{border-collapse: collapse;\}
  th\{
         border: 1px solid #aaa;
         background-color: #ccc;
         padding: 3px;
         padding-left:10px;
         padding-right:10px;
  \}

  td\{
         border: 1px solid #aaa;
         padding: 3px;
         padding-left:10px;
         padding-right:10px;
  \}
  </style>
  $report
  HTML

  # send mail

  await IO::Socket::Async.connect($smtp-server, $smtp-port).then( -> $p {
      if $p.status {
          given $p.result {
              react {
                  whenever .Supply() -> $v {

                      if $v ~~ /^220/ {
                          .print("EHLO $smtp-server\r\nMAIL FROM:<$from>\r\nRCPT TO:<$to>\r\nDATA\r\n" ~ $message ~ "\r\n.\r\n");
                      }

                      if $v ~~ /^250/ {
                          .print("QUIT\r\n");
                          done;
                      }
                  }
              }
              .close;
          }
      }
  });
}
