
use v6;

#TODO remove lib
use lib 'lib';
use MsgPack;
use MsgPack::Native;

# Low-level API
say "Version:  " ~ msgpack_version;
say "Major:    " ~ msgpack_version_major;
say "Minor:    " ~ msgpack_version_minor;

# High-level API
say "Version: " ~ MsgPack::version.perl;
