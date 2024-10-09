# Argument Parsing

Parsing arguments is common in command line programs and there are some packages in Zig to make this task easier. To name a few:

- [Hejsil/zig-clap](https://github.com/Hejsil/zig-clap)
- [MasterQ32/zig-args](https://github.com/MasterQ32/zig-args/)
- [simargs](https://zigcli.liujiacai.net/modules/simargs/)

Here we will give an example using `simargs`.

```zig
{{#include ../src/13-01.zig }}
```
