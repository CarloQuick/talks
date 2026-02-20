pid namespace
===
<!-- column_layout: [2, 3] -->


<!-- column: 1 -->

````rust +exec:rust-script +id:not_desired_pid_result
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
# use nix::{
#    sched::{CloneFlags, unshare},
#    unistd::{ getcwd, gethostname, getpid, getuid, sethostname }
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
#   // === UTS NAMESPACE ===
#   unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
#   sethostname("my-container")?;
    // ↑↑ USER and UTS NAMESPACE Isolation ↑↑
    // === PID NAMESPACE ===
#    // === PID NAMESPACE - next forked child will be PID 1 ===
    unshare(CloneFlags::CLONE_NEWPID).context("Failed to create a PID namespace")?;
#   print_proc_info("After Isolation")?;
#   Ok(())
# }
````
<!-- column: 0 -->
<!-- snippet_output: not_desired_pid_result -->
<!-- end_slide -->
