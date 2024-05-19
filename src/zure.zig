const rure = @cImport(@cInclude("rure.h"));
const std = @import("std");

pub const Flags = enum(u32) {
    /// The case insensitive (i) flag.
    casei = (1 << 0),
    /// The multi-line matching (m) flag. (^ and $ match new line boundaries.)
    multi_line = (1 << 1),
    /// The any character (s) flag. (. matches new line.)
    dotnl =(1 << 2),
    /// The greedy swap (U) flag. (e.g., + is ungreedy and +? is greedy.)
    swap_greed =(1 << 3),
    /// The ignore whitespace (x) flag.
    space = (1 << 4),
    /// The Unicode (u) flag.
    unicode = (1 << 5),
    /// The default set of flags enabled when no flags are set.
    default = Flags.unicode,
};

pub const Regex = struct {
    rure: ?*rure.rure,

    pub fn escapeMust(pattern: [:0]const u8) []const u8 {
        return std.mem.span(rure.rure_escape_must(pattern.ptr));
    }
    
    pub fn compileMust(pattern: [:0]const u8) Regex {
        return .{.rure = rure.rure_compile_must(pattern.ptr)};
    }

    pub fn compile(pattern: []const u8, flags: Flags,
                   options: ?Options, zure_error: ?Error) ?Regex {
        var opt: ?*rure.rure_options = null;
        if (options) |op| {
            opt = op.rure_options;
        }
        var err: ?*rure.rure_error = null;
        if (zure_error) |zerr| {
            err = zerr.rure_error;
        }
        const re = rure.rure_compile(pattern.ptr,
                                     pattern.len,
                                     flags,
                                     opt,
                                     err);
        if (re) |r| {
            return .{.rure = r};
        }
        return null;
    }

    pub fn isMatch(zure: @This(), haystack: []const u8, start: usize) bool {
        if (rure.rure_is_match(zure.rure, haystack.ptr, haystack.len, start)) return true;
        return false;
    }

    pub fn find(zure: @This(), haystack: []const u8, start: usize) ?Match {
        var match: rure.rure_match = undefined;
        if (rure.rure_find(zure.rure,
                           haystack.ptr,
                           haystack.len,
                           start,
                           &match)) {
            return .{
                .start = match.start,
                .end = match.end,
            };
        }
        return null;
    }

    pub fn findCaptures(zure: @This(), haystack: []const u8, start: usize, cap: Captures) bool {
        if (rure.rure_find_captures(zure.rure, haystack.ptr, haystack.len, start, cap.rure_captures)) return true;
        return false;
    }

    pub fn shortestMatch(zure: @This(), haystack: []const u8,
                         start: usize, end: *usize) bool {
        if (rure.rure_shortest_match(zure.rure, haystack.ptr,
                                     haystack.len, start, end)) return true;
        return false;
    }

    pub fn captureNameIndex(zure: @This(), name: [:0]const u8) i32 {
        return rure.rure_capture_name_index(zure.rure, name.ptr);
    }

    pub fn iterCaptureNames(zure: @This()) RegexIterCaptureNames {
        return .{ .rure_iter_capture_names = rure.rure_iter_capture_names_new(zure.rure)};
    }

    pub fn iter(zure: @This()) RegexIter {
        return .{.rure_iter = rure.rure_iter_new(zure.rure_iter)};
    }

    pub fn captures(zure: @This()) Captures {
        return .{.rure_captures = rure.rure_captures_new(zure.rure)};
    }

    pub fn stringFree(s: []u8) void {
        rure.rure_cstring_free(s.ptr);
    }
    
    pub fn deinit(zure: @This()) void {
        rure.rure_free(zure.rure);
    }

};

const RegexSet = struct {
    rure_set: ?*rure.rure_set,

    // pub fn compileSet(patterns: []const []const u8, flags: Flags,
    //                options: ?Options, zure_error: ?Error) ?Regex {
    //     var opt: ?*rure.rure_options = null;
    //     if (options) |op| {
    //         opt = op.rure_options;
    //     }
    //     var err: ?*rure.rure_error = null;
    //     if (zure_error) |zerr| {
    //         err = zerr.rure_error;
    //     }
    //     const re = rure.rure_compile_set(patterns.ptr,
   
    //                                  patterns.len,
    //                                  flags,
    //                                  opt,
    //                                  err);
    //     if (re) |r| {
    //         return .{.rure = r};
    //     }
    //     return null;
    // }

    pub fn deinit(zure_set: @This()) void {
        rure.rure_set_free(zure_set.rure_set);
    }
};

const Options = struct {
    rure_options: ?*rure.rure_options,

    pub fn init() Options {
        return .{.rure_options = rure.rure_options_new()};
    }

    pub fn sizeLimit(zure_options: @This(), limit: usize) void {
        rure.rure_options_size_limit(zure_options.rure_options, limit);
    }

    pub fn sizeLimitDFA(zure_options: @This(), limit: usize) void {
        rure.rure_options_dfa_size_limit(zure_options.rure_options, limit);
    }

    pub fn deinit(zure_options: @This()) void {
        rure.rure_options_free(zure_options.rure_options);
    }
};

const Match = struct {
    start: usize,
    end: usize,
};

const Captures = struct {
    rure_captures: ?*rure.rure_captures,

    pub fn at(zure_captures: @This(), i: usize) ?Match {
        var match: rure.rure_match = undefined;
        if (rure.rure_captures_at(zure_captures.rure_captures,
                           i,
                           &match)) {
            return .{
                .start = match.start,
                .end = match.end,
            };
        }
        return null;
    }

    pub fn len(zure_captures: @This()) usize {
        return rure.rure_captures_len(zure_captures.rure_captures);
    }

    pub fn deinit(zure_captures: @This()) void {
        rure.rure_captures_free(zure_captures.rure_captures);
    }
};

const RegexIter = struct {
    rure_iter: ?*rure.rure_iter,

    pub fn next(zure_iter: @This(), haystack: []const u8) ?Match {
        var match: rure.rure_match = undefined;
        if (rure.rure_iter_next(zure_iter.rure_iter,
                           haystack,
                           haystack.len,
                           &match)) {
            return .{
                .start = match.start,
                .end = match.end,
            };
        }
        return null;
    }

    pub fn nextCaptures(zure_iter: @This(), haystack: []const u8, captures: Captures) bool {
        if (rure.rure_iter_next_captures(zure_iter.rure_iter,
                           haystack,
                           haystack.len,
                                         captures.rure_captures)) return true;
        return false;
    }

    pub fn deinit(zure_iter: @This()) void {
        rure.rure_iter_free(zure_iter.rure_iter);
    }
};

const RegexIterCaptureNames = struct {
    rure_iter_capture_names: ?*rure.rure_iter_capture_names,

    pub fn next(zure_iter_capture_names: @This()) ?[]const u8 {
        var name: [*]u8 = null;
        if (rure.rure_iter_capture_names_next(zure_iter_capture_names.rure_iter_capture_names,
                                                  &name)) {
            return std.mem.span(name);
        }
        return null;
    }

    pub fn deinit(zure_iter_capture_names: @This()) void {
        rure.rure_iter_capture_names_free(zure_iter_capture_names.rure_iter_capture_names);
    }
};

const Error = struct {
    rure_error: ?*rure.rure_error,

    pub fn init() Error {
        return .{.rure_error = rure.rure_error_new()};
    }

    pub fn message(zure_error: @This()) []const u8 {
        return std.mem.span(rure.rure_error_message(zure_error.rure_error));
    }

    pub fn deinit(zure_error: @This()) void {
        rure.rure_error_free(zure_error.rure_error);
    }
};
