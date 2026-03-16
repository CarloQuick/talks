goin' rootless
===
```rust
fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
    std::fs::write("/proc/self/uid_map", uid_map).context("Failed to write to uid")?;
    // Writing `"deny"` disables the syscall setgroups() in the namespace, and then the kernel allows the `gid_map` write.
    std::fs::write("/proc/self/setgroups", "deny").context("Failed to write to gid setgroup")?;
    std::fs::write("/proc/self/gid_map", gid_map).context("Failed to write to gid")?;

    Ok(())
}
```
```rust
    // fn main() -- snip --

    // === USER NAMESPACE ===
    let uid_map = format!("0 {} 1", nix::unistd::getuid());
    let gid_map = format!("0 {} 1", nix::unistd::getgid());
    unshare(CloneFlags::CLONE_NEWUSER).context("Failed to isolate user namespace")?;
    write_proc_mappings(&uid_map, &gid_map)?;

    // -- snip --
```
**Why write to uid_map / gid_map?**

* The new user namespace has no idea who you are. These files tell the kernel:
* "UID 0 inside this namespace = your real host UID"

We appear as **root** inside the container — the host knows you're not.

_setgroups_ → deny is required by the kernel before it accepts the **gid_map** write, to prevent privilege escalation via group manipulation.

<!-- end_slide -->
