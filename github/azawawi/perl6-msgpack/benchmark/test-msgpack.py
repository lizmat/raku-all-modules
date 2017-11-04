#!/usr/bin/env python

import msgpack

def test():
    SIZE     = 10000000;
    data     = [1] * SIZE
    packed   = msgpack.packb(data)
    unpacked = msgpack.unpackb(packed)

for i in range(1,10 + 1):
    test();
