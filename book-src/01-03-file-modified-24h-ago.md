# Find files that have been modified in the last 24 hours

Gets the current working directory by calling `fs.cwd()`, and then iterate files using `walk()`, which will recursively iterates over a directory.

For each entries, we check if it's a file, and use `statFile()` to retrieve file's metadata.

```zig
{{#include ../src/01-03.zig }}
```
