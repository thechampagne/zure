const std = @import("std");
const testing = std.testing;
const zure = @import("zure");
const Regex = zure.Regex;
const Captures = zure.Captures;

test "isMatch" {
    const haystack = "snowman: \xE2\x98\x83";

    const re = Regex.compileMust("\\p{So}$");
    defer re.deinit();
    
    const matched = re.isMatch(haystack, 0);
    
    try testing.expect(matched == true);
}

test "shortestMatch" {
    const haystack = "aaaaa";

    const re = Regex.compileMust("a+");
    defer re.deinit();
    
    var end: usize = 0;
    const matched = re.shortestMatch(haystack,0,&end);
    
    try testing.expect(matched == true);
    try testing.expect(end == 1);
}

test "find" {
    const haystack = "snowman: \xE2\x98\x83";

    const re = Regex.compileMust("\\p{So}$");
    defer re.deinit();
    
    const match = re.find(haystack,0);

    try testing.expect(match.?.start == 9);
    try testing.expect(match.?.end == 12);
}

test "captures" {
    const haystack = "snowman: \xE2\x98\x83";

    const re = Regex.compileMust(".(.*(?P<snowman>\\p{So}))$");
    defer re.deinit();
    
    const caps = re.captures();
    defer caps.deinit();
    
    const matched = re.findCaptures(haystack, 0, caps);
    try testing.expect(matched == true);
    
    const captures_len = caps.len();
    try testing.expect(captures_len == 3);

    const capture_index = re.captureNameIndex("snowman");
    try testing.expect(capture_index == 2);
    

    const match = caps.at(2);
    try testing.expect(match.?.start == 9);
    try testing.expect(match.?.end == 12); 
}
