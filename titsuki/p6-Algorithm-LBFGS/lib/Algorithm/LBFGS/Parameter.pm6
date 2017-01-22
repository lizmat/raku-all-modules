unit class Algorithm::LBFGS::Parameter is repr('CStruct');

use NativeCall;

my constant ptrsize = nativesizeof(Pointer);
my constant lbfgsfloatval_t = ptrsize == 8 ?? num64 !! num32;
my constant $library = %?RESOURCES<libraries/lbfgs>.Str;

has int32 $.m is rw;
has lbfgsfloatval_t $.epsilon is rw;
has int32 $.past is rw;
has lbfgsfloatval_t $.delta is rw;
has int32 $.max_iterations is rw;
has int32 $.linesearch is rw;
has int32 $.max_linesearch is rw;
has lbfgsfloatval_t $.min_step is rw;
has lbfgsfloatval_t $.max_step is rw;
has lbfgsfloatval_t $.ftol is rw;
has lbfgsfloatval_t $.wolfe is rw;
has lbfgsfloatval_t $.gtol is rw;
has lbfgsfloatval_t $.xtol is rw;
has lbfgsfloatval_t $.orthantwise_c is rw;
has int32 $.orthantwise_start is rw;
has int32 $.orthantwise_end is rw;
my sub lbfgs_parameter_init(Algorithm::LBFGS::Parameter) is native($library) is export { * }

submethod BUILD(Int :$m,
		Num :$epsilon,
		Int :$past,
		Num :$delta,
		Int :$max_iterations,
		Int :$linesearch,
		Int :$max_linesearch,
		Num :$min_step,
		Num :$max_step,
		Num :$ftol,
		Num :$wolfe,
		Num :$gtol,
		Num :$xtol,
		Num :$orthantwise_c,
		int32 :$orthantwise_start,
		int32 :$orthantwise_end) {
    lbfgs_parameter_init(self);
    self.m = $m if $m.defined;
    self.epsilon = $epsilon if $epsilon.defined;
    self.past = $past if $past.defined;
    self.delta = $delta if $delta.defined;
    self.max_iterations = $max_iterations if $max_iterations.defined;
    self.linesearch = $linesearch if $linesearch.defined;
    self.max_linesearch = $max_linesearch if $max_linesearch.defined;
    self.min_step = $min_step if $min_step.defined;
    self.max_step = $max_step if $max_step.defined;
    self.ftol = $ftol if $ftol.defined;
    self.wolfe = $wolfe if $wolfe.defined;
    self.gtol = $gtol if $gtol.defined;
    self.xtol = $xtol if $xtol.defined;
    self.orthantwise_c = $orthantwise_c if $orthantwise_c.defined;
    self.orthantwise_start = $orthantwise_start if $orthantwise_start.defined;
    self.orthantwise_end = $orthantwise_end if $orthantwise_end.defined;
}
