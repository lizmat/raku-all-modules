#| A generic modifier for a StatsBearer stat
class RPG::Base::StatModifier {
    has $.stat   is required;
    has $.change is required;
}
