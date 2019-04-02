use v6.c;
use NativeCall;
unit class Algorithm::HierarchicalPAM::Theta:ver<0.0.1>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/hpam>.Str;

my sub hpam_create_theta(int32, int32, int32, num64 --> Algorithm::HierarchicalPAM::Theta) is native($library) { * }
my sub hpam_delete_theta(Algorithm::HierarchicalPAM::Theta) is native($library) { * }
my sub hpam_theta_allocate(Algorithm::HierarchicalPAM::Theta, int32, int32, int32) is native($library) { * }
my sub hpam_theta_deallocate(Algorithm::HierarchicalPAM::Theta, int32, int32, int32) is native($library) { * }
my sub hpam_theta_update(Algorithm::HierarchicalPAM::Theta) is native($library) { * }
my sub hpam_theta_weight(Algorithm::HierarchicalPAM::Theta, int32, int32, int32 --> num64) is native($library) { * }
my sub hpam_theta_num_super_topic(Algorithm::HierarchicalPAM::Theta --> int32) is native($library) { * }
my sub hpam_theta_num_sub_topic(Algorithm::HierarchicalPAM::Theta --> int32) is native($library) { * }
my sub hpam_theta_num_doc(Algorithm::HierarchicalPAM::Theta --> int32) is native($library) { * }

method new(Int :$num-super-topic!, Int :$num-sub-topic!, Int :$num-doc!, Num :$alpha!) {
    hpam_create_theta($num-super-topic, $num-sub-topic, $num-doc, $alpha);
}

method num-super-topics(--> Int) {
    hpam_theta_num_super_topic(self)
}

method num-sub-topics(--> Int) {
    hpam_theta_num_sub_topic(self)
}

method num-docs(--> Int) {
    hpam_theta_num_doc(self)
}

method allocate(Int $super-topic, Int $sub-topic, Int $doc-index) {
    hpam_theta_allocate(self, $super-topic, $sub-topic, $doc-index);
}

method deallocate(Int $super-topic, Int $sub-topic, Int $doc-index) {
    hpam_theta_deallocate(self, $super-topic, $sub-topic, $doc-index);
}

method !update {
    hpam_theta_update(self)
}

method weight(Int $super-topic, Int $sub-topic, Int $doc-index --> Num) {
    hpam_theta_weight(self, $super-topic, $sub-topic, $doc-index);
}

submethod DESTORY {
    hpam_delete_theta(self)
}
