const rure = @cImport(@cInclude("rure.h"));

pub const Flags = enum(u32) {
    casei = (1 << 0), // The case insensitive (i) flag.
    multi_line = (1 << 1), // The multi-line matching (m) flag. (^ and $ match new line boundaries.)
    dotnl =(1 << 2), // The any character (s) flag. (. matches new line.)
    swap_greed =(1 << 3), // The greedy swap (U) flag. (e.g., + is ungreedy and +? is greedy.)
    space = (1 << 4), // The ignore whitespace (x) flag.
    unicode = (1 << 5), // The Unicode (u) flag.
    default = Flags.unicode, // The default set of flags enabled when no flags are set.
};

const Regex = struct {
    rure: ?*rure.rure,
    
    pub fn compileMust(pattern: [:0]const u8) Regex {
        return .{.rure = rure.rure_compile_must(pattern.ptr)};
    }

    pub fn compile(pattern: [:0]const u8, flags: Flags,
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

    pub fn deinit(zure: @This()) void {
        rure.rure_free(zure.rure);
    }

};

const RegexSet = struct {};

const Options = struct {
    rure_options: ?*rure.rure_options,
};

const Match = struct {
    start: usize,
    end: usize,
};

const Captures = struct {};

const RegexIter = struct {};

const RegexIterCaptureNames = struct {};

const Error = struct {
    rure_error: ?*rure.rure_error,
};
