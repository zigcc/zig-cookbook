// Workaround for using regex in Zig.
// https://www.openmymind.net/Regular-Expressions-in-Zig/
// https://stackoverflow.com/questions/73086494/how-to-allocate-a-struct-of-incomplete-type-in-zig
#include <regex.h>
#include <stdlib.h>

regex_t* alloc_regex_t(void);
void free_regex_t(regex_t* ptr);
