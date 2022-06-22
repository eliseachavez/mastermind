$r_count = 0
$w_count = 0
$code = ['b','g','o','p']
$potential_colors = []
$perfect_matches = []
$colors = ['r','o','y','g','b','p']
$count_of_colors_at_exact_matches = {r:0,o:0,y:0,g:0,p:0}

$guess = ['b','b','y','y'] # one red pin (so add all colors to potential colors, no banned colors)
#$guess = ['y','y','r','r'] # 0 pins (all of these go to banned colors)
#$guess = ['b','p','g','o'] # one red pin and 3 white pins (all of these go to potential colors)
#$guess = ['g','o','p', 'b'] # all white pins (add all to potential colors)

def grade
  #exact_match?
  look_for_matches_at_position # generate red pins
  look_for_colors_at_inexact_position # generate whie pins
  print_feedback
  reset_counts
end

def look_for_matches_at_position
  $code.each_index do |i|
    if $code[i] == $guess[i]
      $r_count += 1
      $w_count -= 1 # because it's going to be counted again later
      $perfect_matches.push($guess[i])
      $potential_colors.push($guess[i])
    end
  end
end

def look_for_colors_at_inexact_position
  #psuedocode:
  # if # of exact matches of this color == # of times this color found in code
  #   then we don't need to add a white pin
  # else if # number of time this color is in the code > # of exact matches of color (including 0 times!)
  #   then we add a white pin
  #   also add to potential colors IF NOT ALREADY THERE
  # else # of exact matches of this color > # of times color found in this code
  #   then error message, there can't be more matches of this color then there are instances of it


end

def print_feedback
  puts "There are #{$r_count} red pins and #{$w_count} white pins"
end

def reset_counts
  $r_count = 0
  $w_count = 0
end



grade





