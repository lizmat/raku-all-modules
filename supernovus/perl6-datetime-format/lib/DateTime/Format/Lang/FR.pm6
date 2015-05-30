unit module DateTime::Format::Lang::FR;

use DateTime::Format :ALL;

BEGIN {
  add-datetime-format-month-names('fr', [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ]);
  add-datetime-format-day-names('fr', [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ]);
}


