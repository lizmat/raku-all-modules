use v6;

class FastCGI::Errors;

has @.messages;

method print (*@msg)
{
  @.messages.push(@msg.join);
}

method say (*@msg)
{
  @.messages.push(@msg.join ~ "\n");
}

method printf ($format, *@msg)
{
  @.messages.push(sprintf($format, |@msg));
}

