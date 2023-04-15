const std = @import("std");

pub fn main() !u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) return 1;

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.debug.print("{s}\n", .{line});
    }

    return 0;
}

// pub fn match(regexp: []u8, text: []u8) u8 {
//     if (regexp[0] == '^') return matchhere(regexp + 1, text);

//     while (*text != '\0') {
//         if (matchhere(regexp, text)) return 1;
//         text += 1;
//     }

//     return 0;
// }

test "simple test" {}
