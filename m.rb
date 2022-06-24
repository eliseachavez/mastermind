class Game
  CODE_KEY = ["r","o","y","g","b","p"] #shorthand for representing the colors
  @@p_score = 0
  @@c_score = 0
  @@rounds = 0

  def initialize
    @possible_codes = generate_all_possible_codes
    @codemaker = ''
    @codebreaker = ''
    @original_code = []
    @code = []
    @guess = []
    @last_guess = []
    @turn_data = {1=>nil,2=>nil,3=>nil,4=>nil, 5=>nil,6=>nil,7=>nil,8=>nil,9=>nil,10=>nil,11=>nil,12=>nil}
    @num_guesses = 0
    @r_count = 0
    @w_count = 0
    @turns = 0
    @over = false
    @code_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}
    @guess_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}

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
    @original_code = @possible_codes[random_index]
    @code = @possible_codes[random_index]
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
        if CODE_KEY.include?(code_char)
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
    guess = []
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
          guess.push(code_char)
        else
          puts "That was an inccorect character."\
          "Type your code character (r,o,y,g,b,p) when prompted."
        end
      end
    end
    guess
  end

  def play
    choose
    until @over do
      make_a_guess
      # since Knuth's algorithm is run in make_a_guess and changes a temp guess to master code
      # and a new code as the new guess
      # we need to set guess to equal what is now code
      # and code needs to be original
      revert_original_code
      grade_guess
      archive_and_reset_guess
    end
  end

  def revert_original_code
    # right now Knuth's alg code is @code
    # we need it to become @guess
    # @code needs to go back to being @original_code
    temp = []
    temp = @code.clone
    @guess.clear
    @guess = temp.clone

    @code.clear
    @code = @original_code.clone
  end

  def archive_and_reset_guess
    @last_guess.clear
    @last_guess = guess.clone
    @guess.push(@r_count)
    @guess.push(@w_count)
    @turn_data[@num_guesses] = @guess.clone
    @guess.clear
    @r_count = 0
    @w_count = 0
  end

  def clear_code_color_count
    @code_color_count.clear
    @code_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}
  end

  def clear_guess_color_count
    @guess_color_count.clear
    @guess_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}
  end

  def grade_guess
    if @guess == @code
      @over = true
      puts "You won!"
    else
      grade
    end
  end

  def grade
    # Clear them from before.
    # Don't do in final clear method because that doesn't get touched when doing knuth's
    reset_pins
    clear_code_color_count
    clear_guess_color_count
    generate_code_color_count
    generate_guess_color_count

    count_exact_matches
    count_inexact_matches
  end

  def count_exact_matches
    # Count exact matches and give a red pin
    # Once counted, remove them from color counts so they aren't counted again when counting for white pins
    @code.each_index do |i|
      if @code[i] == @guess[i]
        decrement_code_color_count(@code[i])
        decrement_guess_color_count(@guess[i])
        @r_count += 1
      end
    end
  end

  def count_inexact_matches
    # Get a diff to see if guess has enough colors to fill the counts for code

    CODE_KEY.each do |color|
      color = color.to_sym
      if @guess_color_count[color] > 0
        @code_color_count[color].times do
          # For as many of this color that the code has, count a white pin that guess color has available
          if @guess_color_count[color] >= 1
            @w_count += 1
            decrement_guess_color_count(color)
          end
        end
      end
    end
  end

  def decrement_code_color_count(code)
    color_key = code.to_sym
    @code_color_count[color_key] -= 1
  end

  def decrement_guess_color_count(guess)
    color_key = guess.to_sym
    @guess_color_count[color_key] -= 1
  end

  def generate_code_color_count
    CODE_KEY.each do |color|
      @code.each do |code_color|
        if code_color == color
          @code_color_count[color.to_sym] += 1
        end
      end
    end
  end

  def generate_guess_color_count
    CODE_KEY.each do |color|
      @guess.each do |guess_color|
        if guess_color == color
          @guess_color_count[color.to_sym] += 1
        end
      end
    end
  end

  def print_grade
    # print the feedback pins
    puts "\nHere's how your guess did."\
    "\nWhite means you got a color right. Repeats will not receive additional whites."\
    "\nRed means you got the color and order right."\
    "\nRed and White will be indicated by the characters r and w.\n"
    puts "\nThere were #{@r_count} red pins and #{@w_count} white pins.\n\n"
  end

  def choose
    if @codemaker == 'computer'
      generate_code
    else
      choose_code
    end
  end

  def make_a_guess
    # Make guesses until
    if @codebreaker == "computer"
      computer_guess
    else
      player_guess
    end
    puts "\n#{@codebreaker}'s guess is #{guess}\n"
    @num_guesses += 1
  end

  def player_guess
    puts "\n\nThe computer has created a code and it is time for you to guess.\n"
    choose_guess
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

    color1 = CODE_KEY[rand1]
    color2 = CODE_KEY[rand2]

    2.times { @guess.push(color1) }
    2.times { @guess.push(color2) }
  end

  def subsequent_guess
    choose_by_knuth_alg
    reset_pins
    guess
  end

  def choose_by_knuth_alg
    # Ese last guess as your master code for now. Remove amything that doesn't give the same feedback as last time
    master_pins = pin_report_for_master

    # loop and reject if temp_pins != master_pins
      new_solution_set = []

      # make our @last_guess our new @code
      # and the iteration variable code is our new @guess
      @code.clear
      @code = @last_guess.clone

      @possible_codes.each do |code|

        @guess.clear
        @guess = code

        grade_guess
        temp_pins = pin_report_for_temp_code

        if temp_pins == master_pins
          new_solution_set.push(code)
        end
        puts "Number of possible codes is #{new_solution_set.size}"
    end

    clear_and_replace_solution_set(new_solution_set)
    puts "\nnew size of possible codes after algorithm is #{@possible_codes.size}\n"

    random_guess #now get a new guess based off our new solution set
    puts "set is #{@possible_codes}"
    puts "\n\nOur new guess based off Knuth's alg is #{@guess}\n\n"
    # reset pins and everything since none of this has involved submitting a real guess
    reset_pins
  end

  def clear_and_replace_solution_set(new_solution_set)
    @possible_codes.clear
    @possible_codes = new_solution_set.clone
  end

  def pin_report_for_master
    @w_count = @turn_data[@num_guesses][5]
    @r_count = @turn_data[@num_guesses][4]
    pin_arr = []
    pin_arr.push(@r_count)
    pin_arr.push(@w_count)
    reset_pins
    pin_arr
  end

  def pin_report_for_temp_code
    pin_arr = []
    pin_arr.push(@r_count)
    pin_arr.push(@w_count)
    reset_pins
    pin_arr
  end

  def reset_pins
    @w_count = 0
    @r_count = 0
  end

  def remove_code_last_guessed
    @possible_codes.delete(@last_guess)
  end

  def remove_codes
    remove_code_last_guessed
  end

  def random_guess
    size = @possible_codes.size - 1
    random_index = rand(size).to_i
    @guess.clear
    @guess = @possible_codes[random_index]
  end

end # end of class def

game = Game.new
