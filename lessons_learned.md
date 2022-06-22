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
