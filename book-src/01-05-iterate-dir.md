## Iterate directory

There is a convenient method `walk` for this purpose, it will walk the directory iteratively.

```zig
{{#include ../src/01-05.zig}}
```

The order of returned file system entries is undefined, if there are any requirements for the order in which to return the entries, such as alphabetical or chronological, sort them accordingly. Otherwise, leave them in their original, unsorted order.
