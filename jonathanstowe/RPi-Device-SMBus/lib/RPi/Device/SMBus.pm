use v6;
use NativeCall;

=begin pod

=head1 NAME

RPi::Device::SMBus - SMBus/i²c interface for Raspberry Pi

=head1 SYNOPSIS

=begin code

    use RPi::Device::SMBus;

    # Obviously you will need to actually read the data sheet of your device.
    my RPi::Device::SMBus $smbus = RPi::Device::SMBus.new(device => '/dev/i2c-1', address => 0x54);

    $smbus.write-byte(0x10);

    ....


=end code

=head1 DESCRIPTION

This is an SMBus/i²c interface that has been written and tested for the Raspberry Pi, however it uses a fairly generic
POSIX interface so if your platform exposes the i²c interface as a character special device it may work.

In order to use this you will need to install and configure the i2c-dev kernel module and tools.  On a default Debian
image you should be able to just do:

    sudo apt-get install libi2c-dev i2c-tools

And then edit the C</etc/modules> to add the modules by adding:

       i2c-dev
       i2c-bcm2708

And then rebooting.

Typicaly the i2c device will be C</dev/i2c-1> on a Raspberry Pi rev B. or v2 or C</dev/i2c-0> on older versions.

You can determine the bus address of your device by doing:

    sudo i2cdetect -y 1  # replace the 1 with a 0 for older versions

(Obviously the device should be connected, consult the manual for your device about this.)

Which should give you the hexadecimal address of your device.  Some devices may not respond, so you may want to either check
the data sheet of your device or read the C<i2cdetect> manual page to get other options.

=head1 METHODS

Not all devices will necessarily support all of the methods, here.  You should consult the data sheet for your device to
determine which commands (passed as the C<Command $command> - an unsigned 8 bit integer) should be used as they will differ
for all devices.

=head2 method new

    method new(:$device!, :$address!) returns RPi::Device::SMBus

This is the constructor of the class. The named parameters are both required: C<device> is an the full path (e.g C</dev/i2c-1>) 
of the character special device that represents your i2c bus, and C<address> should be the 7 bit numeric address (i.e. an integer
less that 128) of the device on the bus.

An exception may be thrown if the device cannot be opened, or it does not support the required ioctls that an i2c device should.

=head2 method write-quick

    method write-quick(Byte $value) returns Int

This sends a single bit to the device, at the place of the Read/Write bit returning an integer to indicate the result

=head2 method read-byte

    method read-byte() returns Int

This reads a single byte from the device, without the need to specify a register C<Command>.  This may only be implemented by
the simplest devices, but it can be used as a short hand for C<read-byte-data> but re-using the previous Command.

=head2 method write-byte

    method write-byte(Byte $value) returns Int

This is the reverse of read-byte, it will send the single byte to the device.

=head2  method read-byte-data

    method read-byte-data(Command $command) returns Int

This reads a single byte from the device register specified by C<$command>.

=head2 method write-byte-data

    method write-byte-data(Command $command, Byte $value) returns Int

This writes the single byte C<$value> to the device register C<$command>, returning an int which will be -1 on failure.

=head2 read-word-data

    method read-word-data(Command $command) returns Int

This reads the 16 bit word from the register specified by<$command>.

=head2 method write-word-data

    method write-word-data(Command $command, Word $value) returns Int

This writes the 16 bit word C<$value> to the register specified by C<$command> returning an int (which will be -1 on failure.)

=head2 method process-call

    method process-call(Command $command, Word $value) returns Int

This writes the 16 bit word C<$value> to the command register C<$command> and then reads it back (presumably the device will
have changed it.)

=head2  method read-block-data

    method read-block-data(Command $command) returns Block

This reads the command register C<$value> and returns the C<Block> (an array containing up to 32 unsigned 8 bit integers.)

=head2 method write-block-data

    method write-block-data(Command $command, Block $block) returns Int

This writes the C<Block> C<$block> (An array of unsigned bytes,) the the command register C<$command> and returns an integer
to indicate the success of the call.

=head2 method read-i2c-block-data

    method read-i2c-block-data(Command $command, Int $length) returns Block

This is similar to C<read-block-data> but the C<$length> of the number of bytes to be read can be provided, some systems may not
support anything other than 32.

=head2 method write-i2c-block-data

    method write-i2c-block-data(Command $command, Block $block ) returns Int

This is similiar to C<write-block-data> to the extent that the Perl 6 interface is identical.

=head2 method block-process-call

    method block-process-call(Command $command, Block $block) returns Block

This sends the specified C<Block> (Array of unsigned bytes) to the Command register C<$command> and reads up to 32 bytes
back which are returned as a C<Block>

=end pod

class RPi::Device::SMBus:ver<0.0.1>:auth<github:jonathanstowe> {

    use NativeHelpers::Array;

    class X::Open is Exception {
        has Str $.message;
    }

    class X::IO is Exception {
        has Str $.message;
    }

    constant BLOCK_MAX = 32;
    constant HELPER = %?RESOURCES<libraries/i2chelper>.Str;

    subset I2C-Address of Int where * < 128;
    subset DevicePath  of Str where { $_.IO ~~ :e };

    subset Byte    of Int where   {  $_ >= 0 && $_ <= 255 };
    subset Word    of Int where   {  $_ >= 0 && $_ < 65536 };
    subset Command of Int where   {  $_ >= 0 && $_ <= 255 };
    subset Block   of Array where { $_.elems <= 32 && all($_.list) < 256 };

    has I2C-Address $.address is required;
    has DevicePath  $.device  is required;

    has Int $!fd;

    method !fd() returns Int {
        if not $!fd.defined {
            $!fd = self!open($!device, $!address);
        }
        $!fd;
    }

    sub rpi_dev_smbus_open(Str $file, int32 $address) returns int32 is native(HELPER) { * }

    method !open(Str $file, Int $address ) returns Int {
        explicitly-manage($file);
        my Int $fd = rpi_dev_smbus_open($file, $address);
        if $fd < 0 {
            X::Open.new(message => "Error opening the device").throw;
        }
        $fd;
    }

    sub rpi_dev_smbus_write_quick(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-quick(Byte $value) returns Int {
        rpi_dev_smbus_write_quick(self!fd, $value);
    }

    sub rpi_dev_smbus_read_byte(int32 $file) returns  int32 is native(HELPER) { * }

    method read-byte() returns Int {
        rpi_dev_smbus_read_byte(self!fd);
    }

    sub rpi_dev_smbus_write_byte(int32 $file, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-byte(Byte $value) returns Int {
        rpi_dev_smbus_write_byte(self!fd, $value);
    }

    sub rpi_dev_smbus_read_byte_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }

    method read-byte-data(Command $command) returns Int {
        rpi_dev_smbus_read_byte_data(self!fd, $command);
    }

    sub rpi_dev_smbus_write_byte_data(int32 $file, uint8 $command, uint8 $value) returns  int32 is native(HELPER) { * }

    method write-byte-data(Command $command, Byte $value) returns Int {
        rpi_dev_smbus_write_byte_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_read_word_data(int32 $file, uint8 $command) returns  int32 is native(HELPER) { * }

    method read-word-data(Command $command) returns Int {
        rpi_dev_smbus_read_word_data(self!fd, $command);
    }

    sub rpi_dev_smbus_write_word_data(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }

    method write-word-data(Command $command, Word $value) returns Int {
        rpi_dev_smbus_write_word_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_process_call(int32 $file, uint8 $command, uint16 $value) returns  int32 is native(HELPER) { * }

    # writes a Word and returns a value
    method process-call(Command $command, Word $value) returns Int {
        rpi_dev_smbus_write_word_data(self!fd, $command, $value);
    }

    sub rpi_dev_smbus_read_block_data(int32 $file, uint8 $command, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method read-block-data(Command $command) returns Block {
        my CArray[uint8] $out-buf = CArray[uint].new;
        $out-buf[BLOCK_MAX + 1] = 0;

        my $len = rpi_dev_smbus_read_block_data(self!fd, $command, $out-buf);

        if $len < 0 {
            X::IO.new(message => "'read_block_data' failed").throw;
        }

        my @array = copy-to-array($out-buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;
    }

    sub rpi_dev_smbus_write_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method write-block-data(Command $command, Block $block) returns Int {
        my CArray $buf = copy-to-carray($block, uint8);
        rpi_dev_smbus_write_block_data(self!fd, $command, $block.elems, $buf);
    }

    sub rpi_dev_smbus_read_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method read-i2c-block-data(Command $command, Int $length) returns Block {
        my CArray[uint8] $out-buf = CArray[uint].new;
        $out-buf[BLOCK_MAX + 1] = 0;

        my $len = rpi_dev_smbus_read_i2c_block_data(self!fd, $command, $length, $out-buf);

        if $len < 0 {
            X::IO.new(message => "'read_i2c_block_data' failed").throw;
        }

        my @array = copy-to-array($out-buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;
    }

    sub rpi_dev_smbus_write_i2c_block_data(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method write-i2c-block-data(Command $command, Block $block ) returns Int {
        my CArray[uint8] $buf = copy-to-carray($block, uint8);
        rpi_dev_smbus_write_i2c_block_data(self!fd, $command, $block.elems, $buf);
    }

    sub rpi_dev_smbus_block_process_call(int32 $file, uint8 $command, uint8 $length, CArray[uint8] $values) returns  int32 is native(HELPER) { * }

    multi method block-process-call(Command $command, Block $block) returns Block {
        my CArray[uint8] $buf = copy-to-carray($block, uint8);
        my $len = rpi_dev_smbus_block_process_call(self!fd, $command, $block.elems, $buf);
        if $len < 0 {
            X::IO.new(message => "'block_process_call' failed").throw;
        }

        my @array = copy-to-array($buf, $len + 1);
        # this is the actual length
        my $ll = @array.shift;
        @array;

    }

}
# vim: expandtab shiftwidth=4 ft=perl6
