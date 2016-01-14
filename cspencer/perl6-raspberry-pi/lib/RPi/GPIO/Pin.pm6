class RPi::GPIO::Pin {
  use RPi::Wiring;
  
  has Int $.id;
  has RPiPinMode $!mode;

  method mode(RPiPinMode $mode) {
    $!mode = $mode;
    RPi::Wiring::set-pin-mode(self.id, $mode)
  }
  
  method write(RPiPinValue $value) {
    RPi::Wiring::digital-write(self.id, $value)
  }

  method read() returns Int {
    return RPi::Wiring::digital-read(self.id)
  }
}
