subset Row of UInt where 1|2|3;
subset Col of UInt where 0 <= * < 80;

class RPi::Device::ST7036::Setup {
    has Row $.rows is required;
    has Col $.cols is required;
    has Bool $.v33 is required;
    has Bool $.bias14 is required;
    has Bool $.boosterOn is required;
    has Bool $.followerOn is required;
    has UInt $.follower is required where 0 <= * < 8;

    my RPi::Device::ST7036::Setup $.DOGM081_5V .= new(
        rows => 1,
        cols => 8,
        v33 => False,
        bias14 => True, 
        boosterOn => False,
        followerOn => True,
        follower => 2
    );

    my RPi::Device::ST7036::Setup $.DOGM081_3_3V .= new(
        rows => 1,
        cols => 8,
        v33 => True,
        bias14 => False, 
        boosterOn => True,
        followerOn => True,
        follower => 5
    );
}

