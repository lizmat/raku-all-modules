Text::Names generates American English names.

I wrote this project as a way of learning perl6 so the code may not be fully idiomatic perl6. 

# Usage

```
get-full() # generates a random name with a first name and last name 
get-full("male") # generates a random male full name 
get-full("female") # generates a random female full name 
get-male() # generates just a male first name
get-female() # generates just a female first name
get-last() # generates just a last name 
```

You can significantly increase performance for large numbers of generated names by setting `$*buffer-size` to the number of names you plan on generating. By default, the file is reread every time a name is generated. `$*buffer-size` tells the library to fetch that many names at once from each file used. `$*buffer-size` will likely not significantly improve performance for small numbers of generated names. 

If you prefer enums to magic strings, you can use `male`, `female`, and `both` from the enum `Gender`. 

# Known Issues
Performance is a bit rubbish. The current algorithm is slower than it needs to be. Some speed increases can be implemented likely by indexing the source file instead of reading though almost the entire name database every time a rare name is generated. Alternatively a heuristic could likely be used to allow greater leaps down the text file to find the target name quicker.

In theory, the automatic tests could rarely fail just from drawing the same random name several times in a row. I have never seen this happen and is extremely unlikely.

# Credit
This module was written using the python ["names"](https://github.com/treyhunner/names) module heavily as reference. Ribbon-otter (me) copied the public domain source files as well as the basic algorithm from it. The names python project, at time of writing, lists their authors as 

* Trey Hunner <http://treyhunner.com>
* Simeon Visser <http://simeonvisser.com>
 
