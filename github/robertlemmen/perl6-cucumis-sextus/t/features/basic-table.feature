Feature: Basic Calculator Functions
  In order to check I've written the Calculator class correctly
  As a developer I want to check some basic operations
  So that I can have confidence in my Calculator class.

  Scenario: Separation of calculations
    Given a new Calculator object
    And having successfully performed the following calculations
      | first | operator | second | result |
      | 0.5   | +        | 0.1    | 0.6    |
      | 0.01  | /        | 0.01   | 1      |
      | 10    | *        | 1      | 10     |
    And having pressed 3
    Then the display should show 3

