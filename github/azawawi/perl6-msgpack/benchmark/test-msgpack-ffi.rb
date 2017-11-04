#!/usr/bin/env ruby

require 'ffi/msgpack'

puts FFI::MsgPack.version

SIZE     = 10 * 1000 * 1000

def test()
	data     = [1] * SIZE
    packed   = FFI::MsgPack.pack( data )
    unpacked = FFI::MsgPack.unpack( packed )
end

for i in 1..10 do
    puts i
    test()
end

# vim: set ts=4 sw=4:
