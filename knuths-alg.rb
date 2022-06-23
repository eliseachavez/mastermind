
CODE_KEY = ["r","o","y","g","b","p"] #shorthand for representing the colors
possible_codes = generate_all_possible_codes

code = ['b','g','o','p']
guess = ['o','o','y','y']

r_count = 0
w_count = 1

def generate_all_possible_codes
  permutation = []
  CODE_KEY.repeated_permutation(4) { |num| permutation.push(num) }
  permutation
end

def remove_based_off_knuth_alg
  #remove_codes

end

