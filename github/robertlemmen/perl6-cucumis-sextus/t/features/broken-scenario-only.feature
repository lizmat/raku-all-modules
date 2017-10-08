# this is broken, we aree missing a feature definition
Scenario: First Key Press on the Display
    Given a new Calculator object
    And having pressed 1
    Then the display should show 1
