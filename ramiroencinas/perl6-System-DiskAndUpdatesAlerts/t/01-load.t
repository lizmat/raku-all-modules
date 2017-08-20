use v6;
use lib 'lib';
use Test;

plan 2;

use System::DiskAndUpdatesAlerts;
ok 1, "use System::DiskAndUpdatesAlerts worked!";
use-ok 'System::DiskAndUpdatesAlerts';
