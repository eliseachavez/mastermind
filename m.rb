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
    @codemaker = ''
    @codebreaker = ''
    @code = []
    @guess = []
    @over = false
    intro_and_setup
  end

  private

  def generate_all_possible_codes
    permutation = []
    NUMBERS.repeated_permutation(4) { |num| permutation.push(num) }
    permutation
  end

  def intro_and_setup
    puts "Welcome to mastermind!\n"\
    "Would you like to make the code, or break the code?\n"\
    "Type 'codemaker' for the former and 'codebreaker' for the latter.\n"
    begin
      answer = gets.chomp
    rescue StandardError => e
      puts "ERROR: #{e.inspect}"
      retry
    else
      if answer == "codemaker" || answer == "codebreaker"
        if answer == "codemaker"
          @codemaker = "player"
          @codebreaker = "computer"
        else
          @codemaker = "computer"
          @codebreaker = "player"
        end
      else
        puts "That is not a valid answer; let's start over."
        puts
        intro_and_setup
      end
    end
    play
  end

  def generate_code
    # pick a code from @all_possible_codes at random
    # there are 1296 codes, so we may 1296-1 or 1295 the max number
    random_index = rand(1295)
    @possible_codes[random_index]
  end

  def choose_printout
    puts " \nChoose your code. It is four characters long. \n"\
    "\nFor red, type r; orange, type o; yellow, type y,"\
    "\n green, type g; blue, type b; purple, type p\n"\
    "Any characters other than these will be rejected.\n\n"\
  end

  def choose_code
    alphabet = "roygbp"
    code_char = nil
    i = 4

    choose_printout
    until i == 0 do
      puts "color:"
      begin
        code_char = gets.chomp
      rescue StandardError=>each
        puts "Error: #{e.inspect}"
        retry
      else
        code_char = code_char.downcase
        if alphabet.include?(code_char)
          i -= 1
          @code.push(code_char)
        else
          puts "That was an inccorect character."\
          "Type your code character (r,o,y,g,b,p) when prompted."
        end
      end
    end
    @code
  end

  def choose_guess
    alphabet = "roygbp"
    code_char = nil
    i = 4

    choose_printout
    until i == 0 do
      puts "color:"
      begin
        code_char = gets.chomp
      rescue StandardError=>each
        puts "Error: #{e.inspect}"
        retry
      else
        code_char = code_char.downcase
        if alphabet.include?(code_char)
          i -= 1
          @guess.push(code_char)
        else
          puts "That was an inccorect character."\
          "Type your code character (r,o,y,g,b,p) when prompted."
        end
      end
    end
    @code
  end

  def play
    # Let's say for now that play is codemaker and computer is codebreaker
    if @codemaker == 'computer'
      @code = generate_code
    else
      @code = choose_code
    end
    guess
  end

  def guess
    # Make guesses until
    if @codebreaker == "computer"
      computer_guess
    else
      player_guess
    end
  end

  def player_guess
    puts "\n\nThe computer has created a code and it is time for you to guess.\n"
    @guess = choose_guess
    puts "reached end of player guess"

  end

end # end of class def

game = Game.new
