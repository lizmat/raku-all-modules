use lib "lib";

use ProblemSolver;
my ProblemSolver $problem .= new: :stop-on-first-solution;

my @colors = <green yellow blue white>;

my @states = <
	acre				alagoas
	amapa				amazonas
	bahia				ceara
	espirito-santo		goias
	maranhao			mato-grosso
	mato-grosso-do-sul	minas-gerais
	para				paraiba
	parana				pernambuco
	piaui				rio-de-janeiro
	rio-grande-do-norte	rio-grande-do-sul
	rondonia			roraima
	santa-catarina		sao-paulo
	sergipe				tocantins
>;

for @states -> $state {
	$problem.add-variable: $state, @colors;
}

$problem.unique-vars: <acre amazonas>;
$problem.unique-vars: <amazonas roraima>;
$problem.unique-vars: <amazonas rondonia>;
$problem.unique-vars: <amazonas para>;
$problem.unique-vars: <para amapa>;
$problem.unique-vars: <para tocantins>;
$problem.unique-vars: <para mato-grosso>;
$problem.unique-vars: <para maranhao>;
$problem.unique-vars: <maranhao tocantins>;
$problem.unique-vars: <maranhao piaui>;
$problem.unique-vars: <piaui ceara>;
$problem.unique-vars: <piaui pernambuco>;
$problem.unique-vars: <piaui bahia>;
$problem.unique-vars: <ceara rio-grande-do-norte>;
$problem.unique-vars: <ceara paraiba>;
$problem.unique-vars: <ceara pernambuco>;
$problem.unique-vars: <rio-grande-do-norte paraiba>;
$problem.unique-vars: <pernambuco alagoas>;
$problem.unique-vars: <alagoas sergipe>;
$problem.unique-vars: <sergipe bahia>;
$problem.unique-vars: <bahia minas-gerais>;
$problem.unique-vars: <bahia espirito-santo>;
$problem.unique-vars: <bahia tocantins>;
$problem.unique-vars: <bahia goias>;
$problem.unique-vars: <mato-grosso goias>;
$problem.unique-vars: <mato-grosso tocantins>;
$problem.unique-vars: <mato-grosso rondonia>;
$problem.unique-vars: <mato-grosso mato-grosso-do-sul>;
$problem.unique-vars: <mato-grosso-do-sul goias>;
$problem.unique-vars: <mato-grosso-do-sul minas-gerais>;
$problem.unique-vars: <mato-grosso-do-sul sao-paulo>;
$problem.unique-vars: <mato-grosso-do-sul parana>;
$problem.unique-vars: <sao-paulo minas-gerais>;
$problem.unique-vars: <sao-paulo rio-de-janeiro>;
$problem.unique-vars: <rio-de-janeiro espirito-santo>;
$problem.unique-vars: <rio-de-janeiro minas-gerais>;
$problem.unique-vars: <minas-gerais espirito-santo>;
$problem.unique-vars: <parana santa-catarina>;
$problem.unique-vars: <santa-catarina rio-grande-do-sul>;

my %res = $problem.solve.first;
my $size = %res.keys.map(*.chars).max;
for %res.kv -> $state, $color {
	printf "%{$size}s => %s\n", $state, $color;
}

