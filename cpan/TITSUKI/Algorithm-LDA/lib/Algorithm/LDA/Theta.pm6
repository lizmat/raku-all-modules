use v6.c;
use NativeCall;
unit class Algorithm::LDA::Theta:ver<0.0.9>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/lda>.Str;

my sub lda_create_theta(int32, int32, int32, num64 --> Algorithm::LDA::Theta) is native($library) { * }
my sub lda_delete_theta(Algorithm::LDA::Theta) is native($library) { * }
my sub lda_theta_allocate(Algorithm::LDA::Theta, int32, int32, int32) is native($library) { * }
my sub lda_theta_deallocate(Algorithm::LDA::Theta, int32, int32, int32) is native($library) { * }
my sub lda_theta_update(Algorithm::LDA::Theta) is native($library) { * }
my sub lda_theta_weight(Algorithm::LDA::Theta, int32, int32, int32 --> num64) is native($library) { * }
my sub lda_theta_num_super_topic(Algorithm::LDA::Theta --> int32) is native($library) { * }
my sub lda_theta_num_sub_topic(Algorithm::LDA::Theta --> int32) is native($library) { * }
my sub lda_theta_num_doc(Algorithm::LDA::Theta --> int32) is native($library) { * }

method new(Int :$num-super-topic!, Int :$num-sub-topic!, Int :$num-doc!, Num :$alpha!) {
    lda_create_theta($num-super-topic, $num-sub-topic, $num-doc, $alpha);
}

method num-super-topics(--> Int) {
    lda_theta_num_super_topic(self)
}

method num-sub-topics(--> Int) {
    lda_theta_num_sub_topic(self)
}

method num-docs(--> Int) {
    lda_theta_num_doc(self)
}

method allocate(Int $super-topic, Int $sub-topic, Int $doc-index) {
    lda_theta_allocate(self, $super-topic, $sub-topic, $doc-index);
}

method deallocate(Int $super-topic, Int $sub-topic, Int $doc-index) {
    lda_theta_deallocate(self, $super-topic, $sub-topic, $doc-index);
}

method !update {
    lda_theta_update(self)
}

method weight(Int $super-topic, Int $sub-topic, Int $doc-index --> Num) {
    lda_theta_weight(self, $super-topic, $sub-topic, $doc-index);
}

submethod DESTORY {
    lda_delete_theta(self)
}
