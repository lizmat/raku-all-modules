role Net::AMQP::Payload::ArgumentSerialization;

method serialize-arg($type, $value, $buf? is copy, $bitsused? = 0) {
    given $type {
        when 'boolean' {
            if $value {
                $buf = buf8.new(1);
            } else {
                $buf = buf8.new(0);
            }
        }
        when 'bit' {
            if $bitsused == 0 {
                if $value {
                    $buf = buf8.new(1);
                } else {
                    $buf = buf8.new(0);
                }
            } else {
                if $value {
                    $buf = buf8.new($buf[0] +| (1 +< $bitsused));
                    #$buf[0] = $buf[0] +| (1 +< $bitsused);
                }
            }
        }
        when 'octeti' {
            die;
        }
        when 'octet' {
            $buf = pack('C', $value);
        }
        when 'shorti' {
            die;
        }
        when 'short' {
            $buf = pack('n', $value);
        }
        when 'longi' {
            die;
        }
        when 'long' {
            $buf = pack('N', $value);
        }
        when 'longlongi' {

        }
        when 'longlong' {
            $buf = pack('N', $value +> 32);
            $buf ~= pack('N', $value +& 0xFFFF);
        }
        when 'float' {
            die;
        }
        when 'double' {
            die;
        }
        when 'decimal' {
            die;
        }
        when 'shortstring' {
            if $value.chars > 255 {
                die;
            }
            $buf = pack('C', $value.chars);
            $buf ~= $value.encode;
        }
        when 'longstring' {
            if $value.chars > (2**32 - 1) {
                die;
            }
            $buf = pack('N', $value.chars);
            $buf ~= $value.encode;
        }
        when 'timestamp' {
            $buf = pack('N', $value +> 32);
            $buf ~= pack('N', $value +& 0xFFFF);
        }
        when 'array' {
            die;
        }
        when 'table' {
            $buf = buf8.new();

            for $value.kv -> $k, $v {
                $buf ~= self.serialize-arg("shortstring", $k);
                if $v ~~ Bool {
                    $buf ~= 't'.encode;
                    $buf ~= self.serialize-arg("boolean", $v);
                } elsif $v ~~ Hash {
                    $buf ~= 'F'.encode;
                    $buf ~= self.serialize-arg("table", $v);
                } elsif $v ~~ Array {
                    $buf ~= 'A'.encode;
                    $buf ~= self.serialize-arg("array", $v);
                } elsif $v ~~ Int && $v >= 0 {
                    $buf ~= 'l'.encode;
                    $buf ~= self.serialize-arg("longlong", +$v);
                } elsif $v ~~ Int && $v < 0 {
                    $buf ~= 'L'.encode;
                    $buf ~= self.serialize-arg("longlongi", +$v);
                } else {
                    $buf ~= 'S'.encode;
                    $buf ~= self.serialize-arg("longstring", ~$v);
                }
            }
            $buf = pack('N', $buf.bytes) ~ $buf;
        }
    }

    return $buf;
}

method deserialize-arg($type, $data, $bitcount = 0) {
    given $type {
        when 'boolean' {
            return ?$data.unpack('C'), 1;
        }
        when 'bit' {
            return (($data.unpack('C') +> $bitcount) +& 1, 1);
        }
        when 'octeti' {
            die;
        }
        when 'octet' {
            return ($data.unpack('C'), 1);
        }
        when 'shorti' {
            die;
        }
        when 'short' {
            return ($data.unpack('n'), 2);
        }
        when 'longi' {
            die;
        }
        when 'long' {
            return ($data.unpack('N'), 4);
        }
        when 'longlongi' {
            die;
        }
        when 'longlong' {
            return (($data.unpack('N') +< 32) +| $data.subbuf(4).unpack('N'), 8);
        }
        when 'float' {
            die;
        }
        when 'double' {
            die;
        }
        when 'decimal' {
            die;
        }
        when 'shortstring' {
            my $len = $data.unpack('C');
            return $data.subbuf(1, $len).decode, $len + 1;
        }
        when 'longstring' {
            my $len = $data.unpack('N');
            return $data.subbuf(4, $len).decode, $len + 4;
        }
        when 'timestamp' {
            return (($data.unpack('N') +< 32) +| $data.subbuf(4).unpack('N'), 8);
        }
        when 'array' {
            die;
        }
        when 'table' {
            my %result;
            my $len = $data.unpack('N');
            my $tablebuf = $data.subbuf(4, $len);
            while $tablebuf.bytes {
                my $namelen = $tablebuf.unpack('C');
                my $name = $tablebuf.subbuf(1, $namelen).decode;

                my $type = $tablebuf.subbuf(1+$namelen, 1).decode;
                $tablebuf .= subbuf(2+$namelen);
                my $value;
                my $size;
                given $type {
                    when 't' {
                        ($value, $size) = self.deserialize-arg('boolean', $tablebuf);
                    }
                    when 'b' {
                        ($value, $size) = self.deserialize-arg('octeti', $tablebuf);
                    }
                    when 'B' {
                        ($value, $size) = self.deserialize-arg('octet', $tablebuf);
                    }
                    when 'U' {
                        ($value, $size) = self.deserialize-arg('shorti', $tablebuf);
                    }
                    when 'u' {
                        ($value, $size) = self.deserialize-arg('short', $tablebuf);
                    }
                    when 'I' {
                        ($value, $size) = self.deserialize-arg('longi', $tablebuf);
                    }
                    when 'i' {
                        ($value, $size) = self.deserialize-arg('long', $tablebuf);
                    }
                    when 'L' {
                        ($value, $size) = self.deserialize-arg('longlongi', $tablebuf);
                    }
                    when 'l' {
                        ($value, $size) = self.deserialize-arg('longlong', $tablebuf);
                    }
                    when 'f' {
                        ($value, $size) = self.deserialize-arg('float', $tablebuf);
                    }
                    when 'd' {
                        ($value, $size) = self.deserialize-arg('double', $tablebuf);
                    }
                    when 'D' {
                        ($value, $size) = self.deserialize-arg('decimal', $tablebuf);
                    }
                    when 's' {
                        ($value, $size) = self.deserialize-arg('shortstring', $tablebuf);
                    }
                    when 'S' {
                        ($value, $size) = self.deserialize-arg('longstring', $tablebuf);
                    }
                    when 'A' {
                        ($value, $size) = self.deserialize-arg('array', $tablebuf);
                    }
                    when 'T' {
                        ($value, $size) = self.deserialize-arg('timestamp', $tablebuf);
                    }
                    when 'F' {
                        ($value, $size) = self.deserialize-arg('table', $tablebuf);
                    }
                    when 'V' {
                        $size = 0;
                        $value = Nil;
                    }
                }
                %result{$name} = $value;
                $tablebuf .= subbuf($size);
            }
            return ($%result, $len + 4);
        }
    }
}
