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
    @banned_positions = {r:[],o:[],y:[],g:[],b:[],p:[]}

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
      guess = make_a_guess
      grade_guess(@code, guess)
      archive_and_reset_guess
    end
  end

  def archive_and_reset_guess
    @last_guess.clear
    @last_guess = @guess.clone
    @guess.push(@r_count)
    @guess.push(@w_count)
    @turn_data[@num_guesses] = @guess.clone
    @guess.clear
    @r_count = 0
    @w_count = 0
  end

  def grade_guess(code, guess)
    if guess == code
      @over = true
      puts "You won!"
    else
      match_count = generate_count_of_exact_matches_by_color(code, guess, {r:0,o:0,y:0,g:0,b:0,p:0})
      look_for_colors_at_exact_position(code, guess, match_count)
      look_for_colors_at_inexact_position(code, guess, match_count)
      print_grade
    end
  end

  def look_for_colors_at_exact_position(code, guess, match_count)

    code.each_index do |i|
      if code[i] == guess[i]
        @r_count += 1
        increment_match_count(guess[i], match_count)
      end
    end
  end

  def increment_match_count(color, match_count)
    match_count[color.to_sym] += 1
  end

  def look_for_colors_at_inexact_position(code, guess)
    code_color_count = generate_code_color_count(code)
    guess_color_count = generate_guess_color_count(guess)
    match_count = generate_count_of_exact_matches_by_color(code, guess, {r:0,o:0,y:0,g:0,b:0,p:0})
    # to avoid overocunting, any time a color is counted (for red or white!) need to decrement it in the count
    guess.each do |color|
      color = color.to_sym
      if match_count[color] == code_color_count[color] # num of exact matches of this color is equal to num of times color found in code
        # because this would have already gotten a red pin in the look_for_colors_at_exact_position method
        # we will decrement it in match count because we've already taken care of the match and we don't need to keep flagging it
        # decrement_match_count(color)
      elsif code_color_count[color] > match_count[color] # num of times color found in the code is more than num of exact matches, so we need a white pin
        if guess_color_count[color] == code_color_count[color]
        @w_count += 1
        elsif guess_color_count[color] > code_color_count[color]
          # subtract, and the difference is the number of white pins
          # but what about exact matches?
          difference = guess_color_count[color] - code_color_count[color]
          @w_count += difference
          guess_color_count[color.to_sym] = 0 # only needs to happen bc we're counting ALL the instances of this color here
          puts "Guess color count should be zero, but it's #{guess_color_count[color.to_sym]}"
        end
      elsif match_count[color] > code_color_count[color] # somehow there are more exact matches of this color than there is a number of that color in the code
        puts "Error, should not be able to have more exact matches than there are numbers of that color in the code"
      else
        puts "Error, not sure how we got to this branch"
      end
    end

  end

  def generate_count_of_exact_matches_by_color(code, guess, match_count)
    code.each_index do |i|
      if guess[i] == code[i]
        match_count[code[i].to_sym] += 1
      end
    end
    match_count
  end

  def generate_code_color_count(code)
    code_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}
    CODE_KEY.each do |color|
      code.each do |code_color|
        if code_color == color
          code_color_count[color.to_sym] += 1
        end
      end
    end
    code_color_count
  end

  def generate_guess_color_count(guess)
    guess_color_count = {r:0,o:0,y:0,g:0,b:0,p:0}
    CODE_KEY.each do |color|
      guess.each do |guess_color|
        if guess_color == color
          guess_color_count[color.to_sym] += 1
        end
      end
    end
    guess_color_count
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
      @code = generate_code
    else
      @code = choose_code
    end
  end

  def make_a_guess
    # Make guesses until
    if @codebreaker == "computer"
      guess = computer_guess
    else
      guess = player_guess
    end
    puts "\n#{@codebreaker}'s guess is #{guess}\n"
    @num_guesses += 1
    guess
  end

  def player_guess
    puts "\n\nThe computer has created a code and it is time for you to guess.\n"
    guess = choose_guess
  end

  def computer_guess
    # FIRST GUESS: pick 2 colors randomly and use the 1122 template
    if @num_guesses == 0
      guess = first_guess
    else
      guess = subsequent_guess
    end
    guess
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

    2.times { guess.push(color1) }
    2.times { guess.push(color2) }

    guess
  end

  def subsequent_guess
    guess = choose_by_knuth_alg
    #remove_codes
    reset_pins
    guess
   end

  def choose_by_knuth_alg
    # Ese last guess as your master code for now. Remove amything that doesn't give the same feedback as last time
    master_pins = pin_report_for_master

    # loop and reject if temp_pins != master_pins
      @possible_codes_iteration_set = @possible_codes.clone

      @possible_codes_iteration_set.each do |code|
        guess = code
        grade_guess(code, guess)
        temp_pins = pin_report_for_temp_code
        if temp_pins != master_pins
          @possible_codes.delete(code)
        end
        #@possible_codes.reject! { |num| temp_pins != master_pins }
        guess
    end

    puts "\nnew size of possible codes after algorithm is #{@possible_codes.size}\n"

    guess = random_guess #now get a new guess based off our new solution set
    puts "\n\nOur new guess based off Knuth's alg is #{@guess}\n\n"
    # reset pins and everything since none of this has involved submitting a real guess
    soft_clear_and_reset_no_archive
    guess
  end

  def soft_clear_and_reset_no_archive
    reset_pins
    #@guess.clear
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

  def new_guess_if_pins
    first_guess
  end

  def no_pins?
    num_red_pins == 0 && num_white_pins == 0
  end

  def num_red_pins
    last_guess = @turn_data[@num_guesses]
    last_guess[4]
  end

  def num_white_pins
    last_guess = @turn_data[@num_guesses]
    last_guess[5]
  end

  def remove_codes_with_banned_colors
    puts "\nnumber of codes BEFORE remove_codes_with_banned_colors method: #{@possible_codes.size}"
    determine_banned_colors
    @banned_colors.each do |color|
      @possible_codes.reject! { |code| code.include?(color) }
    end
    puts "\nnumber of codes AFTER remove_codes_with_banned_colors method: #{@possible_codes.size}"
  end

  def remove_codes_with_rejected_positions
    puts "\nnumber of codes BEFORE remove_codes_with_rejected_positions method: #{@possible_codes.size}"
    if num_white_pins == 4
      generate_banned_positions
      # now remove
      @banned_positions.each do |color_char, array_of_positions| # :p, [0,3]
        @possible_codes.each do |code| # ['r','g','b','y']
          @last_guess.each_index do |index| # 0, last guess ['p','y','g','b']
            last_guess_color_char = @last_guess[i] # p
            @possible_codes.reject! { last_guess_color_char == color_char.to_s && indexes_match }
              # if p == :p && [] == 0
          end
        end
      end
      puts "\nnumber of codes AFTER remove_codes_with_rejected_positions method: #{@possible_codes.size}"
    end
    #elsif num_white_pins < 4 && num_white_pins > 0 && num_red_pins == 0

    #end
    # p "The size of possible codes before removal is #{@possible_codes.size}\n"
    # last_guess = @turn_data[@num_guesses]

    # last_guess.each_index do |index|
    #   color_at_position = last_guess[index] # 'r y o p, color_at position is 'r' if index is 0, where position is index, 0-4
    #   @possible_codes.each do |code|
    #     @possible_codes.reject! { |code| code[index] == color_at_position}
    #   end
    # end
    # p "The size of possible codes now is #{@possible_codes.size}\n"
  end

  def generate_banned_positions
    @last_guess.each_index do |index|
      color_char = @last_guess[index]
      @banned_positions[color_char.to_sym].push(index)
    end
  end

  def indexes_match(array_of_positions,index_of_guess_code)
    array_of_positions.any?(index_of_guess_code)
  end

  def remove_code_last_guessed
    @possible_codes.delete(@last_guess)
  end

  def remove_codes
    remove_code_last_guessed
    remove_codes_with_banned_colors
    remove_codes_with_rejected_positions
  end

  def determine_banned_color_positions
  end

  def determine_banned_colors
    if no_pins?
      @last_guess.each do |color|
        unless @banned_colors.include?(color)
          @banned_colors.push(color)
        end
      end
    end
  end

  def new_guess_if_no_pins
    # remove any banned colors (already happened
    random_guess
  end

  def new_guess_if_red_pin
    # grab code that has highest number of colors that are locked colors
    @possible_codes.each_index do |index|
      code = @possible_codes[index]
      match_count = 0
      @potential_colors.each do |color|
        if code.include?(color)
          match_count += 1
        end
      end

      if match_count == 4
        guess = code
      elsif match_count == 3
        guess = code
      elsif match_count == 2
        guess = code
      else
        @guess = code
      end

    end

  end

  def new_guess_if_only_white_pins
    # nothing is in right position. need to rearrange
    random_guess
    # remove anything that has similar positions
  end

  def random_guess
    size = @possible_codes.size - 1
    random_index = rand(size).to_i
    @possible_codes[random_index]
  end

end # end of class def

game = Game.new
