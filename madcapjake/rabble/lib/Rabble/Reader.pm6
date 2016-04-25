unit grammar Rabble::Reader;

token TOP           { [ <Line> \n+ ]+ }
token Line          { \s* [ <Expression> \s* ]+ <EOLComment>? }
token Expression    { <Word> | <Number> | <Quotation> | <Definition> }
regex Term          { <:Letter+:Punctuation+:Symbol-[\[\]:;\\()]>+ }
token Word          { <Term> }
token Name          { <Term> }
token Number        { '-'? <:Number>+ [ '.' <:Number>+ ]? }
token Quotation     { '[' \s* [ <Expression> | <InlineComment> | \s ]+ \s* ']' }
token Definition    { ':' \s* <Name> \s+ [ [<Expression> | <InlineComment>] \s+ ]+ \s* ';' }
token EOLComment    { '\\' .* }
token InlineComment { '(' <-[)]>* ')' }
