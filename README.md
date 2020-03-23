# mlang

This is my toy language that I am, for now, calling mlang. It is built
using Flex and Bison. The parser created after building this project
transpiles mlang files to very basic C++.

## Building

In the root directory run
```
make
```
This will produce a `parser` executable in the same directory.

## Running

Once compiled, you can run the parser like so:
```
./parser < my_mlang_program.m > my_program.cpp
```
and build the output file like this:
```
g++ -o my_program my_program.cpp
```
Finally, the finished executable can be run like so:
```
./my_program
```
That's it.

## The Language

Check out `test/` for some examples.
