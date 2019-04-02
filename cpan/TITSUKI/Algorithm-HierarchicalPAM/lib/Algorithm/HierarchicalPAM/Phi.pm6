use v6.c;
use NativeCall;
unit class Algorithm::HierarchicalPAM::Phi:ver<0.0.1>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/hpam>.Str;

my sub hpam_create_phi(int32, int32, num64 --> Algorithm::HierarchicalPAM::Phi) is native($library) { * }
my sub hpam_delete_phi(Algorithm::HierarchicalPAM::Phi) is native($library) { * }
my sub hpam_phi_allocate(Algorithm::HierarchicalPAM::Phi, int32, int32) is native($library) { * }
my sub hpam_phi_deallocate(Algorithm::HierarchicalPAM::Phi, int32, int32) is native($library) { * }
my sub hpam_phi_weight(Algorithm::HierarchicalPAM::Phi, int32, int32 --> num64) is native($library) { * }
my sub hpam_phi_num_topic(Algorithm::HierarchicalPAM::Phi --> int32) is native($library) { * }
my sub hpam_phi_num_word_type(Algorithm::HierarchicalPAM::Phi --> int32) is native($library) { * }

method new(Int :$num-sub-topic!, Int :$num-word-type!, Num :$beta!) {
    hpam_create_phi($num-sub-topic, $num-word-type, $beta);
}

method allocate(Int $sub-topic, Int $word-type) {
    hpam_phi_allocate(self, $sub-topic, $word-type);
}

method deallocate(Int $sub-topic, Int $word-type) {
    hpam_phi_deallocate(self, $sub-topic, $word-type);
}

method num-topics {
    hpam_phi_num_topic(self);
}

method num-word-types {
    hpam_phi_num_word_type(self);
}

method weight(Int $sub-topic, Int $word-type --> Num) {
    hpam_phi_weight(self, $sub-topic, $word-type);
}

submethod DESTROY {
    hpam_delete_phi(self)
}
