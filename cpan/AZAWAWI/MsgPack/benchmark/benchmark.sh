#!/bin/sh

echo "Python 2 (msgpack)"
time -p ./test-msgpack.py
# echo ""
# echo "Perl 5 (Data::MessagePack)"
# time -p ./test-msgpack.pl
#echo ""
#echo "Perl 6"
#time -p ./test-msgpack.pl6
echo ""
echo "Ruby (msgpack)"
time -p ./test-msgpack.rb
echo ""
echo "C"
time -p ./speed_test_uint32_array
