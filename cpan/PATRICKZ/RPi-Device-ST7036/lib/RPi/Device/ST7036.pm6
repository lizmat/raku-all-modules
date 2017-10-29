use v6;

use NativeCall;
use RPi::Wiring::Pi;
use RPi::Wiring::SPI;

use RPi::Device::ST7036::Setup;


subset Pin of UInt where 0 <= * <= 26;
subset Offset of UInt where 0 <= * < 80;
subset Contrast of UInt where 0 <= * < 64;
subset InstrTable of UInt where 0|1|2;


class RPi::Device::ST7036 {

enum DoubleHeight <
    Off
    OneTwo
    TwoThree
>;

enum ShiftObject <
    Screen
    Cursor
>;

enum Direction <
    Right
    Left
>;

has Pin $!rs-pin is required; # register select. 0 = instruction register, 1 = data register
has Pin $!reset-pin is required;
has $!spi-channel is required where 0|1;
has RPi::Device::ST7036::Setup $!setup is required;

has Contrast $!contrast = 32;
has Bool $!display-on = True;
has Bool $!cursor = False;
has Bool $!cursor-blink = False;
has DoubleHeight $!double-height = Off;
has InstrTable $!curr-instr-table = 0;

has @!row-offsets = ((0x00), (0x00, 0x40), (0x00, 0x10, 0x20))[$!setup.rows - 1];

submethod BUILD(
    Pin :$!rs-pin,
    Pin :$!reset-pin,
    :$!spi-channel where 0|1,
    RPi::Device::ST7036::Setup :$!setup,
    Contrast :$!contrast = 32,
    Bool :$!display-on = True,
    Bool :$!cursor = False,
    Bool :$!cursor-blink = False,
    DoubleHeight :$!double-height = Off)
{ }

# Instruction templates.
method !cmd-clearDisplay() {
    self!send-command: \
    0b00000001;

    sleep 0.001_08;
}

method !cmd-returnHome()   {
    self!send-command: \
    0b00000010;

    sleep 0.001_08;
}

method !cmd-entryModeSet( Bool $shiftLeft, Bool $shiftDisplay ) {
    self!send-command: \
       0b00000100
    +| 0b00000010 * (!$shiftLeft   ?? 1 !! 0)                              # I/D
    +| 0b00000001 * ($shiftDisplay ?? 1 !! 0);                             # S

    sleep 0.000_026_3;
}

method !cmd-displayOnOff() {
    self!send-command: \
       0b00001000                                                          # function select
    +| 0b00000100 * ($!display-on   ?? 1 !! 0)                             # D
    +| 0b00000010 * ($!cursor      ?? 1 !! 0)                              # C
    +| 0b00000001 * ($!cursor-blink ?? 1 !! 0);                            # B

    sleep 0.000_026_3;
}

method !cmd-functionSet() {
    self!send-command: \
       0b00100000                                                          # function select
    +| 0b00010000 # 8-bit mode. On when using SPI.                         # DL
    +| 0b00001000 * ($!setup.rows == 2 && $!double-height == Off
                  || $!setup.rows == 3     ?? 1 !! 0)                      # N
    +| 0b00000100 * ($!double-height != Off ?? 1 !! 0)                     # DH
    +| 0b00000011 +& $!curr-instr-table;                                   # IS2 / IS1

    sleep 0.000_026_3;
}

method !cmd-setDDRAMAddress( UInt $address where 0 <= * <= 0b01111111 ) {
    self!send-command: \
       0b10000000                                                          # function select
    +| 0b01111111 +& $address;                                             # AC6 - AC0

    sleep 0.000_026_3;
}

method !cmd-cursorDisplayShift( ShiftObject $obj, Direction $dir ) {
    self!select-instr-table: 0;

    self!send-command: \
       0b00010000                                                          # function select
    +| 0b00001000 * ($obj == Screen ?? 1 !! 0)                             # S/C
    +| 0b00000100 * ($dir == Right  ?? 1 !! 0);                            # R/L

    sleep 0.000_026_3;
}

method !cmd-setCGRAMAddress( UInt $address where 0 <= * <= 0b00111111 ) {
    self!select-instr-table: 0;

    self!send-command: \
       0b01000000                                                          # function select
    +| 0b00111111 +& $address;                                             # AC5 - AC0

    sleep 0.000_026_3;
}

method !cmd-biasSet() {
    self!select-instr-table: 1;

    self!send-command: \
       0b00010100                                                          # function select
    +| 0b00001000 * ($!setup.bias14    ?? 1 !! 0)                          # BS
    +| 0b00000001 * ($!setup.rows == 3 ?? 1 !! 0);                         # FX

    sleep 0.000_026_3;
}

method !cmd-setIconAddress( UInt $address where 0 <= * <= 0b00001111 ) {
    self!select-instr-table: 1;

    self!send-command: \
       0b01000000                                                          # function select
    +| 0b00001111 +& $address;                                             # AC3 - AC0

    sleep 0.000_026_3;
}

method !cmd-powerIconControlContrast() {
    self!select-instr-table: 1;

    self!send-command: \
       0b01010000                                                          # function select
    +| 0b00001000 * (0) # TODO: ICON Display? What is that?                # Ion
    +| 0b00000100 * ($!setup.boosterOn ?? 1 !! 0)                          # Bon
    +| 0b00000011 +& ($!contrast +> 4);                                    # C5 - C4

    sleep 0.000_026_3;
}

method !cmd-followerControl() {
    self!select-instr-table: 1;

    self!send-command: \
       0b01100000                                                          # function select
    +| 0b00001000 * ($!setup.followerOn ?? 1 !! 0)                         # Fon
    +| 0b00000111 +& $!setup.follower;                                     # Rab2 - Rab0

    sleep 0.000_026_3;
    
    # Wait for power stabilization >200ms.
    sleep 0.25;
}

method !cmd-contrastSet() {
    self!select-instr-table: 1;

    self!send-command: \
       0b01110000                                                          # function select
    +| 0b00001111 +& $!contrast;                                           # C3 - C0

    sleep 0.000_026_3;
}

method !cmd-doubleHeight() {
    self!select-instr-table: 2;

    self!send-command: \
       0b00010000                                                          # function select
    +| 0b00001000 * ($!double-height == OneTwo ?? 1 !! 0);                 # UD

    sleep 0.000_026_3;
}

method !select-instr-table( UInt $instr-table where 0|1|2 ) {
    if $!curr-instr-table != $instr-table {
        $!curr-instr-table = $instr-table;
        self!cmd-functionSet;
    }
}

method !send-command( uint8 $cmd ) {
    digitalWrite $!rs-pin, LOW;
    wiringPiSPIDataRW($!spi-channel, CArray[uint8].new($cmd), 1);
}

method !send-data( uint8 $cmd ) {
    digitalWrite $!rs-pin, HIGH;
    wiringPiSPIDataRW($!spi-channel, CArray[uint8].new($cmd), 1);
}

method !tobin( uint8 $num --> Str ) {
    my $no = $num;
    my $res = '0b';
    for 7...0 -> $digit {
        $res ~= $no div (2 ** $digit) ?? 1 !! 0;
        $no = $no mod (2 ** $digit);
    }
    $res
}


method init() {
    pinMode $!rs-pin, OUTPUT;
    pinMode $!reset-pin, OUTPUT;
    digitalWrite $!reset-pin, HIGH;

    self!cmd-functionSet;
    self!cmd-biasSet;
    self!cmd-powerIconControlContrast;
    self!cmd-followerControl;
    self!cmd-contrastSet;
    self!cmd-displayOnOff;
    self!cmd-clearDisplay;
    self!cmd-entryModeSet: False, False;
}

method reset() { ... }
method set-bias( $bias ) { ... }
method set-contrast( Contrast $contrast ) { ... }

method set-display-mode( $enable=True, $cursor=False, $blink=False ) {
    ...
}

method set-cursor-offset( Offset $offset ) { ... }

method set-cursor-position( Row $row, Col $col ) { ... }

method home() {
    self!cmd-returnHome;
}

method clear() {
    self!cmd-clearDisplay;
}

method write( Str $text ) {
    for $text.comb -> $char {
        self!send-data: $char.ord;
        sleep 0.000_026_3;
    }
}

method cursor-left() { ... }

method cursor-right() { ... }

method shift-left() { ... }

method shift-right() { ... }

method double-height( $enable, $position ) { ... }

}

=begin pod

=head1 NAME

RPi::Device::ST7036 - Support for the ST7036 dot matrix display.

=head1 SYNOPSIS

    use RPi::Wiring::Pi;
    use RPi::Wiring::SPI;
    use RPi::Device::ST7036;

    wiringPiSPISetup 0, 1_000_000;

    my RPi::Device::ST7036 $lcd .= new(
        setup       => RPi::Device::ST7036::Setup.DOGM081_3_3V,
        rs-pin      => 25,
        spi-channel => 0
    );

    $lcd.init;

    $lcd.write: 'Shiny!';


=head1 DESCRIPTION

Display driver for ST7036 based matrix displays.

=head1 METHODS

=head2 new

Takes the following parameters:

=item rs-pin

RPi pin number connected to the register select pin of the display.
This library uses the Wiring Pi pin numbering.

=item spi-channel

The SPI channel the display is connected to. Either 0 or 1.

=item setup

An RPi::Device::ST7036::Setup object. Instances of this class contain all
configuration options that are always the same for a specific display.

If you have a display for which there is not yet an entry in the Setup
class ready to use, please write one and create a pull request!

=item cursor

Whether to display a cursor.

=item cursor-blink

Whether the cursor should blink.

=item contrast

A contrast value between 0 and 63.

=item double-height

Whether a double hight line should be used (irrelevant for single line
displays).

=item display-on

Whether the display should be turned on initially.

=head2 init

Initialize the display. Must be called before anything else works.

=head2 write

Write some text on the display.

=head2 home

Return the cursor to position 0.

=head2 clear

Clear the display.

=end pod

