# Mmap file

Creates a memory map of a file using [mmap](https://man7.org/linux/man-pages/man2/mmap.2.html) and simulates some non-sequential reads from the file. Using a memory map means you just index into a slice rather than dealing with seek to navigate a File.

```zig
{{#include ../src/01-02.zig }}
```
