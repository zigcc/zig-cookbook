# Find files that have been modified in the last 24 hours

Gets the current working directory by calling `fs.cwd()`, and then iterates files using `walk()`, which will recursively iterate entries in the directory.

For each entry, we check if it's a file, and use `statFile()` to retrieve the file's metadata.

```zig
{{#include ../src/01-03.zig }}
```
