const std = @import("std");
const process = std.process;
const fs = std.fs;

var hadError: bool = false;

pub fn main() !void {
    const args = std.os.argv;

    if (args.len - 1 > 1) {
        std.debug.print("Usage: zlox-tw [script]\n", .{});
        process.exit(64);
    } else if (args.len - 1 == 1) {
        const path_nt = args[1];
        // convert null-terminated string into a slice without null termination
        const path = std.mem.span(path_nt);
        try runFile(path);
    } else {
        try runPrompt();
    }
}

fn runFile(path: []const u8) !void {
    const allocator = std.heap.page_allocator;

    const file_data = try fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    defer allocator.free(file_data);

    try run(file_data);

    if (hadError) std.process.exit(65);
}

fn runPrompt() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var buf: [1024]u8 = undefined;

    while (true) {
        try stdout.print("> ", .{});
        const user_input = try stdin.readUntilDelimiter(&buf, '\n');

        if (user_input.len == 0) break;
        try run(user_input);
        hadError = false;
    }
}

fn run(source: []u8) !void {
    std.debug.print("Source: {s}\n", .{source});
}

pub fn generateError(line: i32, message: []u8) !void {
    try reportError(line, "", message);
}

pub fn reportError(line: i32, where: []u8, message: []u8) !void {
    const stdout = std.io.getStdOut().writer();

    stdout.print("[line {d}] Error {s}: {s}\n", .{ line, where, message });
    hadError = true;
}
