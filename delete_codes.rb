colors = ['r','o','y']
possible_codes = []
colors.repeated_permutation(2){ |num| possible_codes.push(num) }
banned_colors = ['r']

pp possible_codes

# delete code with banned colors
possible_codes.each do |code|
  banned_colors.each do |color|
    if code.include?(color)
      possible_codes.delete(code)
    end
  end
end

# check if codes with banned colors removed
possible_codes.each do |code|
  banned_colors.each do |banned_color|
    if code.include?(banned_color)
      puts "error, code with banned colors were not removed"
    end
  end
end

pp possible_codes
