use v6;

unit module t::Bridge;
use MONKEY-SEE-NO-EVAL;
use YAML;

our sub eval_perl($this) {
    return EVAL $this.value;
    CATCH {
        return "$!";
    }
}

our sub dump_to_yaml($this) {
    return YAML::dump($this.value);
}
