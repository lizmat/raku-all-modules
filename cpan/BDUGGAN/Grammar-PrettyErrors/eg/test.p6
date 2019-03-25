use Grammar::PrettyErrors;

grammar G does Grammar::PrettyErrors {
  rule TOP {
    <subject>
    <verb>
    <prepositional-phrase>
  }
  rule subject {
    <article> [ <adjective>**2 % ' '] <noun>
  }
  token verb { jumped }
  rule prepositional-phrase {
    <preposition> <article> <adjective> <noun>
  }
  token article { the }
  token adjective {
    quick | brown | lazy
  }
  token noun { 'sheep dog' | fox }
  token preposition { over }
  token ws { <!ww> \s* }
}

say so G.parse('the quick brown flox jumped over the lazy sheep dog');
