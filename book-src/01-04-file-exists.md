# Check file existence

In this example, `access` is utilized to verify file existence; however, for it to function correctly, one must specifically check for the `FileNotFound` error type.

```zig
{{#include ../src/01-04.zig}}
```
