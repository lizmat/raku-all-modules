
use v6;

#TODO remove lib
use lib 'lib';
use MsgPack;
use MsgPack::Native;

# Low-level API
say "Version:  " ~ msgpack_version;
say "Minor:    " ~ msgpack_version_major;
say "Minor:    " ~ msgpack_version_minor;
say "Revision: " ~ msgpack_version_revision;

# High-level API
say "Version: " ~ MsgPack::version.perl;
