use v6;

unit class RPi::GpioDirect;

has $!gpio;

constant @physToGPIO = <
  -1  -1
   2  -1
   3  -1
   4  14
  -1  15
  17  18
  27  -1
  22  23
  -1  24
  10  -1
   9  25
  11   8
  -1   7
   0   1
   5  -1
   6  12
  13  -1
  19  16
  26  20
  -1  21
>;

constant @physNames = <
   3.3v     5v
   SDA.1    5v
   SCL.1    GND
   GPIO.4   TxD
   GND      RxD
   GPIO.17  GPIO.18
   GPIO.27  GND
   GPIO.22  GPIO.23
   3.3v     GPIO.24
   MOSI     GND
   MISO     GPIO.25
   SCLK     CE0
   GND      CE1
   SDA.0    SCL.0
   GPIO.5   GND
   GPIO.6   GPIO.12
   GPIO.13  GND
   GPIO.19  GPIO.16
   GPIO.26  GPIO.20
   GND      GPIO.21
>;

my @gpio-pins = grep { @physToGPIO[$_ - 1] != -1 }, 1..40;

enum Function is export < In Out Alt5 Alt4 Alt0 Alt1 Alt2 Alt3 >;
enum PullMode is export < None Down Up >;
enum GpioValue is export < Off On >;

# Base addresses for GPIO registers
constant GP-SET = 7;
constant GP-CLEAR = 10;
constant GP-LEVEL = 13;
constant GP-EVENT-DETECT-STATUS = 16;
constant GP-RISING-EDGE-DETECT = 19;
constant GP-FALLING-EDGE-DETECT = 22;
constant GP-PIN-HIGH-DETECT = 25;
constant GP-PIN-LOW-DETECT = 28;
constant GP-PIN-ASYNC-RISING-EDGE = 31;
constant GP-PIN-ASYNC-FALLING-EDGE = 34;
constant GP-PUD-MODE = 37;
constant GP-PUD-CLOCK = 38;

enum FILE-MODE is export (
  O-RDWR => 0x2,
  O-SYNC => 0o4010000
);

enum MAP-PROT is export (
  PROT-READ => 0x1,
  PROT-WRITE => 0x2,
  PROT-EXEC => 0x4
);

enum MAP-FLAGS  is export (
  MAP-SHARED => 0x1,
  MAP-PRIVATE => 0x2,
  MAP-ANONYMOUS => do given $*DISTRO.name {
    when 'macosx' { 0x1000 }
    when 'raspbian' { 0x20 }
    default { die "Unknown distro {$*DISTRO.name}" }
  }
);

use NativeCall;

sub open(Str $name, int32 $flags) returns int32 is native {*}
sub close(int32 $fd) returns int32 is native {*}

# void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
sub mmap(Pointer $addr, int32 $length, int32 $prot, int32 $flags, int32 $fd, int32 $offset)
  returns CArray[int32] is native {*}

# int munmap(void *addr, size_t length);
sub munmap(CArray[int32], int32) returns int32 is native {*}

sub strerror(int32) returns Str is native {*}
my $errno := cglobal('libc.so.6', 'errno', int32);

submethod BUILD {
    my $fd = open('/dev/gpiomem', O-RDWR +| O-SYNC);
    die('open failed: ' ~ strerror($errno)) if $fd == -1;

    my $mem = mmap(Pointer, 4096, PROT-READ +| PROT-WRITE, MAP-SHARED, $fd, 0);
    die('mmap failed: ' ~ strerror($errno)) if nativecast(int32, $mem) == -1;
    close $fd;

    $!gpio := $mem;
}

method gpio-pins() {
    @gpio-pins;
}

method pin-name($pin) {
    die("$pin is not a valid pin number. Pins are 1..40") unless 1 <= $pin <=40;
    @physNames[$pin - 1];
}

method pin-gpio($pin) {
    die("$pin is not a valid pin number. Pins are 1..40") unless 1 <= $pin <=40;
    my $gp = @physToGPIO[$pin - 1];
    die("Pin $pin is not a GPIO it is {self.pin-name($pin)}") if $gp == -1;
    $gp;
}

method read(Int $pin) returns GpioValue {
    my $gp = self.pin-gpio($pin);
    return -1 if $gp == -1;
    $!gpio[GP-LEVEL] +& (1 +< ($gp +& 31)) > 0 ?? On !! Off;
}

method write(Int $pin, GpioValue $value) {
    my $gp = self.pin-gpio($pin);
    $!gpio[$value ?? GP-SET !! GP-CLEAR] = (1 +< ($gp +& 31));
}

method function(Int $pin) returns Function {
    my $gp = self.pin-gpio($pin);
    Function($!gpio[$gp div 10] +> (($gp % 10) * 3) +& 7);
}

method set-function(Int $pin, Function $mode) {
    my $gp = self.pin-gpio($pin);
    my Int $register = $gp div 10;
    my Int $shift = ($gp % 10) * 3;
    my Int $offmask = +^ (0x7 +< $shift);
    my Int $orig = $!gpio[$register];
    $!gpio[$register] = ($orig +& $offmask) +| ($mode +< $shift);
}

method set-pull(Int $pin, PullMode $pud) {
    my $gp = self.pin-gpio($pin);
    $!gpio[GP-PUD-MODE] = $pud;
    for 1..150 { }
    $!gpio[GP-PUD-CLOCK] = (1 +< $gp);
    for 1..150 { }
    $!gpio[GP-PUD-MODE] = 0;
    $!gpio[GP-PUD-CLOCK] = 0;
}

method close {
  my int $status = munmap($!gpio, 4096);
  die('munmap failed: ' ~ strerror($errno)) if $status == -1;
  $!gpio := Mu;
}
