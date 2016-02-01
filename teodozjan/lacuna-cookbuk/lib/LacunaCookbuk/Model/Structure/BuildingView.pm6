use v6;

unit class LacunaCookbuk::Model::Structure::BuildingView;

has $.level;
has Any $.pending_build;
has Hash $.upgrade;
has $.repair_costs;
has $.efficiency;

submethod damaged {
    $!efficiency < 100    
}

submethod will_repair_cost {
    return any($!repair_costs.values) != 0;
}
