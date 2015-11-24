enum RPiGPIOMode <WIRING BCM>;
enum RPiPinMode  <INPUT OUTPUT>;
enum RPiPinValue <LOW HIGH>;

package RPi::Wiring {
    use NativeCall;

    # Setup Functions
    our sub setup() returns int32 is native('libwiringPi') is symbol('wiringPiSetup') { * };
    our sub setup-gpio() returns int32 is native('libwiringPi') is symbol('wiringPiSetupGpio') { * };
    our sub setup-physical() returns int32 is native('libwiringPi') is symbol('wiringPiSetupPhys') { * };
    our sub setup-sysclass() returns int32 is native('libwiringPi') is symbol('wiringPiSetupSys') { * };

    # Core Functions
    our sub set-pin-mode(int32, int32) is native('libwiringPi') is symbol('pinMode') { * };
    our sub set-pull-up-down(int32, int32) is native('libwiringPi') is symbol('pullUpDnControl') { * };
    our sub digital-write (int32, int32) is native('libwiringPi') is symbol('digitalWrite') { * };
    our sub digital-read (int32) returns int32 is native('libwiringPi') is symbol('digitalRead') { * };
    our sub analog-write (int32, int32) is native('libwiringPi') is symbol('analogWrite') { * };
    our sub analog-read (int32) returns int32 is native('libwiringPi') is symbol('analogRead') { * };
    our sub pwm-write (int32, int32) is native('libwiringPi') is symbol('pwmWrite') { * };

    our sub board-revision() returns int32 is native('libwiringPi') is symbol('piBoardRev') { * };

    our sub milliseconds-since-setup returns uint32 is native('libwiringPi') is symbol('millis') { * };
    our sub microseconds-since-setup returns uint32 is native('libwiringPi') is symbol('micros') { * };

    our sub delay-milliseconds(uint32) is native('libwiringPi') is symbol('delay') { * };
    our sub delay-microseconds(uint32) is native('libwiringPi') is symbol('delayMicroseconds') { * };
    our &delay = &delay-milliseconds;
}
