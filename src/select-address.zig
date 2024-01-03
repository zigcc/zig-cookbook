// Allows to choose between IPv4 and IPv6

const std = @import("std");
const net = std.net;

const ipVersion = 4; // Currently (december 2023), only 4 or 6

const v4addr = "127.0.0.1";
const v6addr = "::1";

// Returns a struct with the text form of the IP address (see RFC
// 3986, section 3.2.2) and the address to listen on.
pub fn myAddress() !struct { textAddr: []const u8, local: net.Address } {
    if (ipVersion == 6) {
        const loopback = try net.Ip6Address.parse(v6addr, 0);
        const localhost = net.Address{ .in6 = loopback };
        return .{ .textAddr = "[" ++ v6addr ++ "]", .local = localhost };
    } else if (ipVersion == 4) {
        const loopback = try net.Ip4Address.parse(v4addr, 0);
        const localhost = net.Address{ .in = loopback };
        return .{ .textAddr = v4addr, .local = localhost };
    } else unreachable;
}

// Returns the address to connect to
pub fn remoteAddress(port: u16) !net.Address {
    if (ipVersion == 6) {
        return try net.Address.parseIp6(v6addr, port);
    } else if (ipVersion == 4) {
        return try net.Address.parseIp(v4addr, port);
    } else unreachable;
}
