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


