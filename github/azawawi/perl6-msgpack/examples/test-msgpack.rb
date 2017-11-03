#!/usr/bin/env ruby

require 'msgpack'

def test()
	size     = 10 * 1000 * 1000
	data     = [1] * size
    packed   = MessagePack.pack( data )
    unpacked = MessagePack.unpack( packed )
end

for i in 1..10 do
    test()
end

# vim: set ts=4 sw=4:
