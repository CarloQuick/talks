forking a child process + inspect isolation
===
<!-- column_layout: [2, 3] -->


<!-- column: 1 -->

````rust +exec:rust-script +id:forking_proc_child_chk_iso
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
use std::ffi::CString;

# use nix::{
#    sched::{CloneFlags, unshare},
#     sys::wait::waitpid,
#    unistd::{ ForkResult, execvp, fork, getcwd, gethostname, getpid, getuid, sethostname }
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
fn child(argv: &[CString]) -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;

    print_proc_info("Child Level Isolation")?;
    execvp(&argv[0], argv)?;
    Ok(())
}
fn main() -> Result<()> {
    // -- snip -- ↑↑ USER and PID NAMESPACE Isolation ↑↑
#   print_proc_info("Before Isolation")?;
#   // === USER NAMESPACE ===
#   let uid_map = format!("0 {} 1", nix::unistd::getuid());
#   let gid_map = format!("0 {} 1", nix::unistd::getgid());
#   unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
#   write_proc_mappings(&uid_map, &gid_map)?;
#    // === PID NAMESPACE - next forked child will be PID 1 ===
#    unshare(CloneFlags::CLONE_NEWPID).context("Failed to create a PID namespace")?;    
#    // Fork() creates a child process by duplicating the parent
    match unsafe { fork() } {
#        Ok(ForkResult::Parent { child }) => {
#            waitpid(child, None)?;
#        }
        // -- snip -- ↑↑ Ok(ForkResult::Parent)... ↑↑
        Ok(ForkResult::Child) => {
            let argv = vec![CString::new("ls")?];
            child(&argv)?;
        }
        // -- snip --
#        Err(err) => Err(err).context("Fork failed!")?,
#    }
#   Ok(())
# }
````
<!-- column: 0 -->
<!-- snippet_output: forking_proc_child_chk_iso -->

<!-- end_slide -->
