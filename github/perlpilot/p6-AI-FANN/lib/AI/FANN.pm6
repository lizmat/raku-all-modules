class AI::FANN {

    has Bool $.shortcut;            # shortcuts can skip layers
    has Bool $.sparse;              # Not fully connected
    has Num $.connection_rate;      # 1 == fully connected, 0.5 == 50% connected, etc.

    
}
