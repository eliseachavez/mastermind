# 6 colors: ROYGBP (red orange yellow green blue purple)
# 4 pegs, no repeats
# Gameplay: keep prompting for gameply until player says no.

#   Codebreaker(computer) generates all possible combinations to guess
#     now computer randomly picks TWO colors
#     put those together in a bipair, like RRGG for red-red-green-green
#     submit
#     receive feedback
#       if no color matches, get rid of ALL combos that have those colors
#       if matched and in right order, add to SOLUTION variable for the knowns
#       if matched but out of order, focus on the correct colors until you find their positions
#         select all codes with those colors
#         what if all four pegs are white? All 4 are right color but wrong position.
#           freeze every position but choose ONE to swap thats a correct color but wrong place

#   Codemaker randomly generates a code with no repeats
#     receive code guess from computer
#     feedback generation:
#       first, are any colors right? forget order.
#         if yes, assign one white peg per correct guess
#       check each slot. Are any perfectly correct?
#         if yes, assign a red peg per. remove white peg for each red peg made
#       if no colors or positions are correct, return no grade pegs

class Game
  NUMBERS = ["1","2","3","4","5","6"] #shorthand for representing the colors
  def initialize
    @possible_codes = generate_all_possible_codes
    @codemaker = "computer"
    @codebreaker = "computer or person"
    @player = ''
    @computer = ''
    intro_and_setup
  end

  private

  def generate_all_possible_codes
    # 4 peg code made from 5 colors, repeats allowed
    # if repeats weren't allowed, I chould choose .permutation method
    # instead of .permutation method
    # Should generate 6^4 codes, or 1,296
    permutation = []
    NUMBERS.repeated_permutation(4) do |num|
      permutation.push(num)
    end
    permutation
  end

  def intro_and_setup
    puts "Welcome to mastermind!"\
    " Would you like to make the code, or break the code?"\
    " Type 'codemaker' for the former and 'codebreaker' for the latter."
    begin
      answer = gets.chomp
    rescue StandardError => e
      puts "ERROR: #{e.inspect}"
      retry
    else
      if answer == "codemaker" || answer == "codebreaker"
        player = answer
      else
        puts "That is not a valid answer; let's start over."
        puts
        intro_and_setup
      end
    end
  end

end # end of class def

game = Game.new
