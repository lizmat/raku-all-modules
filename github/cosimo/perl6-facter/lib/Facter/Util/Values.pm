=begin pod

=head1 NAME

Facter::Util::Values

=head1 DESCRIPTION

A util module for facter containing helper methods

=end pod

class Facter::Util::Values {

    method convert ($value) {
        # value = value.to_s if value.is_a?(Symbol)
        # value = value.downcase if value.is_a?(String)
        $value.Str.lc;
    }

}

