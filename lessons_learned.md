###### Hash declaration:
* if the key isn't a string, you can't use the JSON style syntax, need the => rocket syntax
###### Generating combinations and permutations
* Combos are unordered, permutations are
* ruby has two methods: one that allows repeats and one that doesn't
##### Deep Copy of Array
* When trying to copy an array's contents to a new array, any change I made to the original array would change the array copy as well, because it was a shallow copy!
* = assignment and even iterating and pushing to the new array with .push would still create a shallow copy
* Only way to make a deep copy is to use .clone
##### Delete Codes From Array
* For whatever reason, still haven't found out why, #delete doesn't work on the
* Array of possible codes. Strangely, it will only delete some codes that meet the condition - for unknown reasons. When the same actions are done manually, they work perfectly.
* When things like this happen, try other methods


To understand why delete didn't work you have to think how'd you iterate an array without a helper method like each. The only way really, and the way you'd have to do it in other languages, is to grab the length of the array and then iterate using a loop, each iteration of the loop you look up the index of the array at that position.

If you have an array like [1,2,3] and want to iterate it, you start at index 0 which is the number 1 in the array. If I delete the number one during the first iteration my array becomes [2,3]

During the next iteration I'm now at index 1, but since you mutated the array what is now at index 1? It's the number 3. You've completely skipped an array element
Never mutate an array you are iterating
If you really have to and have no other choice iterate the array backwards from the last element to the first. Deleting an element while iterating backwards means you never delete an element at an index you have yet to visit


##### Clearing a Hash
* can't iterate and re-assign a value
* in general, DON'T mutate an array while iterating
* use #clear hash class instance method

##### Knuth's Algorithm

STEP 1, make a guess using combo [1,1,2,2] and store the feedback/hint

STEP 2, (in that same guess method) immediately iterate through the set of combos and for each one, make it the "temporary" secret code and test [1,1,2,2] (our initial guess) against it.

STEP 3, In this iteration, any combo (acting as a secret code) that doesn't return the same hint as the actual secret code will be deleted from the set.
This is because if they were a likely secret code, they would've produced what the actual secret code produced for guess [1,1,2,2] in step 1.

STEP 4, now the guess method is done. It terminates.

So for the next guess, randomly pick a guess from your now reduced set of combos, make a guess using it, store the feedback, and repeat the whole process again from step 2.


