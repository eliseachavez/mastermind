# 6 colors: ROYGBP (red orange yellow green blue purple)
# 4 pegs, repeats allowed
Gameplay: keep prompting for gameply until player says no.

  Codebreaker(computer) generates all possible combinations to guess
    now computer randomly picks TWO colors
    put those together in a bipair, like RRGG for red-red-green-green
    submit
    receive feedback
      if no color matches, get rid of ALL combos that have those colors
      if matched and in right order, add to SOLUTION variable for the knowns
      if matched but out of order, focus on the correct colors until you find their positions
        select all codes with those colors
        what if all four pegs are white? All 4 are right color but wrong position.
          freeze every position but choose ONE to swap thats a correct color but wrong place

  Codemaker randomly generates a code with no repeats
    receive code guess from computer
    feedback generation:
      first, are any colors right? forget order.
        if yes, assign one white peg per correct guess
      check each slot. Are any perfectly correct?
        if yes, assign a red peg per. remove white peg for each red peg made
      if no colors or positions are correct, return no grade pegs
