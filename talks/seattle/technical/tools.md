The Tools
===

The **nix** crate wraps low-level libc calls in idiomatic Rust — not by hiding danger, but by making it explicit in the type system.

<!-- pause -->
**_https://github.com/nix-rust/nix_**

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

**libc**

```c
// unsafe, manual errno handling
pub unsafe extern fn gethostname(
    name: *mut c_char,
    len: size_t
) -> c_int;
```

<!-- column: 1 -->

**nix**

```rust
// returns Result<OsString>
pub fn gethostname() -> Result<OsString>;
```

<!-- reset_layout -->

<!-- pause -->

The kernel is still the kernel. But the **boundary is visible**: this can fail, and you must handle it.

<!-- pause -->

Let's start building.

<!-- end_slide -->
