use v6;
use lib 'lib';
use Test;

plan 4;

use FileSystem::Capacity::VolumesInfo;
ok 1, "use FileSystem::Capacity::VolumesInfo worked!";
use-ok 'FileSystem::Capacity::VolumesInfo';

use FileSystem::Capacity::DirSize;
ok 1, "use FileSystem::Capacity::DirSize worked!";
use-ok 'FileSystem::Capacity::DirSize';