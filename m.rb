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
    @last_guess = []
    @locked_guess = []
    @turn_data = {1=>nil,2=>nil,3=>nil,4=>nil, 5=>nil,6=>nil,7=>nil,8=>nil,9=>nil,10=>nil,11=>nil,12=>nil}
    @potential_colors = []
    @banned_colors = []
    @num_guesses = 0
    @r_count = 0
    @w_count = 0
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
    until @over do
      guess
      grade_guess
      archive_and_reset_guess
    end
  end

  def archive_and_reset_guess
    @last_guess = @guess.clone
    @guess.push(@r_count)
    @guess.push(@w_count)
    @turn_data[@num_guesses] = @guess.clone
    @guess.clear
    @r_count = 0
    @w_count = 0
  end

  def grade_guess
    if @guess == @code
      @over = true
    else
      used_colors = []
      @code.each_index do |index|
        if @code[index] == @guess[index]
          if used_colors.include?(@guess[index])
            @r_count += 1
            @w_count -= 1
          else
            @r_count += 1
            used_colors.push(@guess[index])
          end
        else
          if @code.include?(@guess[index])
            unless used_colors.include?(@guess[index])
              @w_count += 1
              used_colors.push(@guess[index])
            end
          else
            unless @banned_colors.include?(@guess[index])
              @banned_colors.push(@guess[index])
            end
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
    puts "\nThere were #{@r_count} red pins and #{@w_count} white pins.\n"
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
    @num_guesses += 1
  end

  def player_guess
    puts "\n\nThe computer has created a code and it is time for you to guess.\n"
    @guess = choose_guess
  end

  def computer_guess
    # FIRST GUESS: pick 2 colors randomly and use the 1122 template
    if @num_guesses == 0
      first_guess
    else
      subsequent_guess
    end
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
    2.times { @guess.push(color1) }
    2.times { @guess.push(color2) }
  end

  def subsequent_guess
    remove_codes
    last_guess = @turn_data[@num_guesses]
    # guesses based on locking colors and comparing codes, not removal
    if last_guess[4] == 0 && last_guess[5] == 0
      new_guess_if_no_pins
    elsif last_guess[4] > 0
      new_guess_if_red_pin
    elsif last_guess[5] > 0
      new_guess_if_only_white_pins
    end

  end

  def remove_codes_with_banned_colors
    p "The size of possible codes before removal is #{@possible_codes.size}\n"
    @banned_colors.each do |banned_color|
      @possible_codes.each do |code|
        if code.include?(banned_color)
          @possible_codes.delete(code)
        end
      end
    p "The size of possible codes now is #{@possible_codes.size}\n"
    end
  end

  def remove_codes_with_rejected_positions
    p "The size of possible codes before removal is #{@possible_codes.size}\n"
    last_guess = @turn_data[@num_guesses]

    last_guess.each_index do |index|
      color_at_position = last_guess[index] # 'r y o p, color_at position is 'r' if index is 0, where position is index, 0-4
      @possible_codes.each do |code|
        if code[index] == color_at_position
          # remove this
          @possible_codes.delete(code)
        end
      end
    end
    p "The size of possible codes now is #{@possible_codes.size}\n"
  end

  def remove_code_last_guessed
    @possible_codes.delete(@turn_data[@num_guesses])
  end

  def remove_codes
    remove_code_last_guessed
    remove_codes_with_banned_colors
    remove_codes_with_rejected_positions
  end

  def new_guess_if_no_pins
    # remove any banned colors (already happened
  end

  def new_guess_if_red_pin
    # add all colors to locked colors, unless on banned colors list
    generate_potential_colors

    # grab code that has highest number of colors that are locked colors
    @possible_codes.each_index do |index|
      code = @possible_code[index]
      match_count = 0
      code_with_max_match_count
      @potential_colors.each do |locked_color|
        if code.include?(locked_color)
          match_count += 1
        end
      end

      if match_count == 4
        @guess = code
      elsif match_count == 3
        @guess = code
      elsif match_count == 2
        @guess = code
      else
        @guess = code
      end

    end

  end

  def new_guess_if_only_white_pins
    # nothing is in right position. need to rearrange
    generate_potential_colors
    random_guess
    # remove anything that has similar positions
  end

  def random_guess
    size = @possible_codes.size - 1
    @guess = @possible_codes.rand(size)
  end

  def generate_potential_colors
    @last_guess.each do |one_guess_color|
      # code would be like [r','g','b','o',1,2]
      i = 0
      4.times do
        unless @banned_colors.include?(one_guess_color)
          unless @potential_colors.include?(one_guess_color)
            @potential_colors.push(one_guess_color)
            i += 1
          end
        end
      end
    end
  end

end # end of class def

game = Game.new
