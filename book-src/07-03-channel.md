## Channel

The example uses [`std.Thread`] for concurrent and parallel programming.
[`std.Thread.spawn`] spawns a new thread to calculate the result.

This example splits the array in half and performs the work in separate threads.

```zig
{{#include ../src/07-03.zig}}
```
**Note*: Because [`event.Channel`] is still being updated and the required `async` feature has not yet been added, I wrote a simulated channel to implement this functionality.


Output Log:

```
Channel initialized
Start two threads..
Producer starting...
Sending: 0
Sent: 0
Sending: 1
Received: 0
Received: 1
Sent: 1
Sending: 2
Sent: 2
Sending: 3
Sent: 3
Sending: 4
Sent: 4
Received: 2
Received: 3
Received: 4
Done!
16177944 Send value: 200
16177944 Send value: 200
16177945 Send value: 200
16177945 Send value: 200
16177946 Send value: 200
16177946 Send value: 200
16177946 Received value: 100
16177947 Send failed, channel is full.
16177947 Send value: 200
16177947 Received value: 100
16177948 Send failed, channel is full.
16177948 Send value: 200
16177948 Received value: 100
16177949 Send failed, channel is full.
16177949 Send value: 200
16177949 Received value: 100
16177950 Send failed, channel is full.
16177950 Send value: 200
16177950 Received value: 100
16177951 Send failed, channel is full.
16177951 Send value: 200
16177951 Received value: 200
16177952 Send failed, channel is full.
16177952 Send value: 200
16177952 Received value: 200
16177953 Send failed, channel is full.
16177953 Send value: 200
16177953 Received value: 200
```

[`std.thread`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread
[`std.thread.spawn`]: https://ziglang.org/documentation/0.11.0/std/#A;std:Thread.spawn
[`event.Channel`]: https://ziglang.org/documentation/0.11.0/std/#A;std:event.Channel