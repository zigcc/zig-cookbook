//! Demonstrate hexadecimal encoding and decoding in Zig.

const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const original_text = "Hello, Zig Hex Encoding!";
    print("Original text: \"{s}\"\n", .{original_text});

    // 1. Encode raw bytes into lowercase hexadecimal string.
    // bytesToHex returns a fixed-size array [N * 2]u8, requiring no heap allocation.
    const hex_lower = std.fmt.bytesToHex(original_text.*, .lower);
    print("Hex (lowercase): {s}\n", .{hex_lower});

    // 2. Encode raw bytes into uppercase hexadecimal string.
    const hex_upper = std.fmt.bytesToHex(original_text.*, .upper);
    print("Hex (uppercase): {s}\n", .{hex_upper});

    // 3. Decode lowercase hex string back into original bytes.
    var decoded_buf: [original_text.len]u8 = undefined;
    const decoded_slice = try std.fmt.hexToBytes(&decoded_buf, &hex_lower);
    print("Decoded text: \"{s}\"\n", .{decoded_slice});

    try std.testing.expectEqualStrings(original_text, decoded_slice);

    // 4. Decode uppercase hex string back into original bytes.
    var decoded_buf2: [original_text.len]u8 = undefined;
    const decoded_slice2 = try std.fmt.hexToBytes(&decoded_buf2, &hex_upper);
    try std.testing.expectEqualStrings(original_text, decoded_slice2);

    // 5. Handling invalid hex inputs:
    var err_buf: [4]u8 = undefined;
    // An invalid character returns error.InvalidCharacter
    const invalid_char_result = std.fmt.hexToBytes(&err_buf, "123z");
    try std.testing.expectError(error.InvalidCharacter, invalid_char_result);

    // An odd-length input is rejected with error.InvalidLength
    const invalid_len_result = std.fmt.hexToBytes(&err_buf, "123");
    try std.testing.expectError(error.InvalidLength, invalid_len_result);

    print("All hex encode and decode checks passed successfully!\n", .{});
}
