$r_count = 0
$w_count = 0
$code = ['b','g','o','p']
$potential_colors = []

$guess = ['b','b','y','y'] # one red pin (so add all colors to potential colors, no banned colors)
#$guess = ['y','y','r','r'] # 0 pins (all of these go to banned colors)
#$guess = ['b','p','g','o'] # one red pin and 3 white pins (all of these go to potential colors)
#$guess = ['g','o','p', 'b'] # all white pins (add all to potential colors)

def grade
  #exact_match?
  look_for_matches_at_position
  look_for_colors_at_any_position
  print_feedback
  reset_counts
end

def look_for_matches_at_position
  $code.each_index do |i|
    if $code[i] == $guess[i]
      $r_count += 1
    end
  end
end

def look_for_colors_at_any_position
  # we want to ignore if it's an exact match because we already did those
  $guess.each_index do |i|
    if $code.include?($guess[i])
      unless $code[i] == $guess[i] #because it was already counted by previous method
        $potential_colors.push($guess[i])
        $w_count += 1
      end
    end
  end
end

def print_feedback
  puts "There are #{$r_count} red pins and #{$w_count} white pins"
end

def reset_counts
  $r_count = 0
  $w_count = 0
end
  
grade





