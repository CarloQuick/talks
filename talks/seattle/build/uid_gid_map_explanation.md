goin' rootless
===
```rust
    // -- snip --

    // === USER NAMESPACE ===
    let uid_map = format!("0 {} 1", nix::unistd::getuid());
    let gid_map = format!("0 {} 1", nix::unistd::getgid());
    unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
    write_proc_mappings(&uid_map, &gid_map)?;

    // -- snip --
```

```rust
fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
    std::fs::write("/proc/self/uid_map", uid_map).context("Failed to write to uid")?;
    // Writing `"deny"` disables the syscall setgroups() in the namespace, and then the kernel allows the `gid_map` write.
    std::fs::write("/proc/self/setgroups", "deny").context("Failed to write to gid setgroup")?;
    std::fs::write("/proc/self/gid_map", gid_map).context("Failed to write to gid")?;

    Ok(())
}
```

[explanation]

<!-- end_slide -->
