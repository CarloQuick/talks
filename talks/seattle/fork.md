unshare pid namespace + fork()
===

````rust
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
# use nix::{
#    sched::{CloneFlags, unshare},
#     sys::wait::waitpid,
#    unistd::{ ForkResult, getcwd, gethostname, getpid, getuid, sethostname, fork }
# };
# fn print_proc_info(label: &str) -> Result<()> {
#    eprintln!("[{}]", label);
#    eprintln!(
#        "uid [{}]\n\thostname [{:?}]  \n\tpid [{}] \n\tcwd [{:?}]",
#        getuid(),
#        gethostname()?,
#        getpid(),
#        getcwd()?,
#    );
#    Ok(())
# }
# fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
#    std::fs::write("/proc/self/uid_map", uid_map).context("Failed to write to uid")?;
#    // Writing `"deny"` disables the syscall setgroups() in the namespace, and then the kernel allows the `gid_map` write.
#    std::fs::write("/proc/self/setgroups", "deny").context("Failed to write to gid setgroup")?;
#    std::fs::write("/proc/self/gid_map", gid_map).context("Failed to write to gid")?;
#    Ok(())
# }
# fn main() -> Result<()> {
#   print_proc_info("Before Isolation")?;
#   // === USER NAMESPACE ===
#   let uid_map = format!("0 {} 1", nix::unistd::getuid());
#   let gid_map = format!("0 {} 1", nix::unistd::getgid());
#   unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
#   write_proc_mappings(&uid_map, &gid_map)?;

    // ↑↑ USER and UTS NAMESPACE Isolation ↑↑
    // === PID NAMESPACE - next forked child will be PID 1 ===
    unshare(CloneFlags::CLONE_NEWPID).context("Failed to create a PID namespace")?;
    
    // Fork() creates a child process by duplicating the parent
    match unsafe { fork() } {
        Ok(ForkResult::Parent { child }) => {
            // -- snip --
        }
        Ok(ForkResult::Child) => {
            // -- snip --
        }
        Err(err) => Err(err).context("Fork failed!")?,
    }
#   Ok(())
# }
````

<!-- end_slide -->
