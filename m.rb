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
  CODE_KEY = ["r","o","y","g","b","p"] #shorthand for representing the colors
  @@p_score = 0
  @@c_score = 0
  @@rounds = 0

  def initialize
    @possible_codes = generate_all_possible_codes
    @codemaker = ''
    @codebreaker = ''
    @code = []
    @guess = []
    @locked_guess = []
    @potential_colors_by_turn = {1=>nil,2=>nil,3=>nil,4=>nil, 5=>nil,6=>nil,7=>nil,8=>nil,9=>nil,10=>nil,11=>nil,12=>nil}
    @banned_colors = []
    @num_guesses = 0
    @feedback_pins = []
    @turns = 0
    @over = false
    intro_and_setup
  end

  private

  def generate_all_possible_codes
    permutation = []
    CODE_KEY.repeated_permutation(4) { |num| permutation.push(num) }
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
    @guess
  end

  def play
    choose
    guess
    grade_guess

  end

  def grade_guess
    used_colors = []
    @code.each_index do |index|
      # look for exact matches first
      if @code[index] == @guess[index]
        if used_colors.include?(@guess[index])
          # if the color is already used, we need to remove a white pin
          @feedback_pins.push('r')
          @feedback_pins.delete('w')
        else # add red pin and add to used colors
          @feedback_pins.push('r')
          used_colors.push(@guess[index])
        end
      else # not an exact fit, but is this color elsewhere? don't give white pin twice for repeats though
        if @code.include?(@guess[index])
          if used_colors.include?(@guess[index]) # the code has this color but we've already given it a white peg, don't do again

          else
            @feedback_pins.push('w')
            used_colors.push(@guess[index])
          end
        end
      end
    end
    print_grade
  end

  def print_grade
    # print the feedback pins
    puts "\nHere's how your guess did."\
    "\nWhite means you got a color right. Repeats will not receive additional whites."\
    "\nRed means you got the color and order right."\
    "\nRed and White will be indicated by the characters r and w.\n"
    @feedback_pins.each { |pin| print pin }
  end

  def choose
    if @codemaker == 'computer'
      @code = generate_code
    else
      @code = choose_code
    end
  end

  def guess
    # Make guesses until
    if @codebreaker == "computer"
      computer_guess
    else
      player_guess
    end
    puts "\n#{@codebreaker}'s guess is #{@guess}\n"
  end

  def player_guess
    puts "\n\nThe computer has created a code and it is time for you to guess.\n"
    @guess = choose_guess
  end

  def computer_guess
    # FIRST GUESS: pick 2 colors randomly and use the 1122 template
    if @num_guesses == 0
      @guess = first_guess
    else
      if feedback_pins.include?('r') || feedback_pins.include?('w')
          @potential_colors_by_turn[1] = @guess
          # add r count and w count as well
          @potential_colors_by_turn.push(@feedback_pins.count('r'))
          @potential_colors_by_turn.push(@feedback_pins.count('w'))
          p @potential_colors_by_turn
      end

    end
    @num_guesses += 1
  end

  def first_guess
    rand1 = 0
    rand2 = 0
    until rand1 != rand2 do
      rand1 = rand(5)
      rand2 = rand(5)
    end

    color1 = CODE_KEY[rand1] # randomly choose an index
    color2 = CODE_KEY[rand2]
    guess = []
    2.times { @guess.push(color1) }
    2.times { @guess.push(color2) }
  end

end # end of class def

game = Game.new
