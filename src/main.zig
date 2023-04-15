const std = @import("std");

pub fn main() !u8 {
    // we use a general purpose allocator to allocate memory for the arguments
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // we need to deinitialize the allocator at the end of the program
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 3) return 1;

    const regexp = args[1];
    // we open the file in read-only mode
    const file = try std.fs.cwd().openFile(args[2], .{});
    defer file.close();

    // we create a buffered reader to read the file line by line
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    // we read the file line by line
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_len = line.len;
        // we ignore empty lines
        if (line_len == 0) continue;
       
        // we check if the line contains the word
        const result = match(regexp, line[0..]);

        // if it does, we print the line
        if (result) {
            std.debug.print("{s}\n", .{ line[0..] });
        }
    }

    return 0;
}

// we start with a simple implementation of a regular expression matcher
// that only checks if a line contains a given word
fn match(regexp: []const u8, str: []const u8) bool {
    var i: usize = 0;
    while (i < str.len) {
        if (str[i] == regexp[0]) {
            var k: usize = 1;
            while (k < regexp.len and i + k < str.len and str[i + k] == regexp[k]) {
                k += 1;
            }
            if (k == regexp.len) return true;
        }
        i += 1;
    }
    return false;
}

test "match word" {
    const str = "hello world";
    const regexp = "world";
    try std.testing.expect(match(regexp, str));
}
