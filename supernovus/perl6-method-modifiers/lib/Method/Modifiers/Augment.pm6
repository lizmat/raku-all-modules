use Method::Modifiers;

use MONKEY_TYPING;

augment class Any
{
  method before ($method-name, &closure)
  {
    before(self, $method-name, &closure);
  }
  method after ($method-name, &closure)
  {
    after(self, $method-name, &closure);
  }
  method around ($method-name, &closure)
  {
    around(self, $method-name, &closure);
  }
}

