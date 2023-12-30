// Workaround for using regex in Zig.
// https://www.openmymind.net/Regular-Expressions-in-Zig/
// https://stackoverflow.com/questions/73086494/how-to-allocate-a-struct-of-incomplete-type-in-zig
#include <regex.h>
#include <stdalign.h>

const size_t sizeof_regex_t = sizeof(regex_t);
const size_t alignof_regex_t = alignof(regex_t);
