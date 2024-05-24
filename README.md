# zure

<img align="left" style="width:290px" src="https://raw.githubusercontent.com/thechampagne/zure/main/.github/assets/logo.jpg" width="290px">

**Rust regex**

This library provides routines for searching strings for matches of a [regular expression](https://en.wikipedia.org/wiki/Regular_expression) (aka "regex").

The regex syntax supported by this library is similar to other regex engines, but it lacks several features that are not known how to implement efficiently.

This includes, but is not limited to, look-around and backreferences.

In exchange, all regex searches in this library have worst case `O(m * n)` time complexity, where `m` is proportional to the size of the regex and `n` is proportional to the size of the string being searched.

---

<br>

[![](https://img.shields.io/github/license/thechampagne/zure)](https://github.com/thechampagne/zure/blob/main/LICENSE)

Zig binding for rust **regex** engine.

### Usage

Build rust regex library:
```sh
$ git clone git://github.com/rust-lang/regex
$ cd regex/regex-capi
$ cargo build --release # it exist in ../target/release [librure.so, librure.a]
```
build.zig.zon:
```zig
.{
    .dependencies = .{
        .zure = .{
            .url = "https://github.com/thechampagne/zure/archive/refs/heads/main.tar.gz" ,
          //.hash = "12208586373679a455aa8ef874112c93c1613196f60137878d90ce9d2ae8fb9cd511",
        },
    },
}
```
build.zig:
```zig
const zure = b.dependency("zure", .{});
exe.root_module.addImport("zure", zure.module("zure"));
exe.addLibraryPath(b.path("regex/target/release"));
exe.linkSystemLibrary("rure");
```

### References
 - [rust-regex](https://github.com/rust-lang/regex/)

### License

This repo is released under the [MIT License](https://github.com/thechampagne/zure/blob/main/LICENSE).
