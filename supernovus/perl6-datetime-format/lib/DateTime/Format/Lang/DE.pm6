unit module DateTime::Format::Lang::DE;

use DateTime::Format :ALL;

BEGIN {
  add-datetime-format-month-names('de', [
    'Jänner',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ]);
  add-datetime-format-day-names('de', [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ]);
}


