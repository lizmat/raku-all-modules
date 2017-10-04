Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario Outline: Basic arithmetic
    Given a new Calculator object
    And having keyed <first>
    And having keyed <operator>
    And having keyed <second>
    And having pressed =
    Then the display should show <result>
    Examples:
      | first | operator | second | result |
      | 5.0   | +        | 5.0    | 10     |
      | 6     | /        | 3      | 2      |
      | 10    | *        | 7.550  | 75.5   |
      | 3     | -        | 10     | -7     |
