recap
===

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->
````rust
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
# use std::ffi::CString;
# use mount::{MsFlags, mount};
# use nix::{
#    sched::{CloneFlags, unshare},
#     sys::wait::waitpid,
#    unistd::{ ForkResult, chroot, execvp, fork, getcwd, gethostname, getpid, getuid, sethostname }
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
fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
    std::fs::write("/proc/self/uid_map", uid_map)?;
    std::fs::write("/proc/self/setgroups", "deny")?;
    std::fs::write("/proc/self/gid_map", gid_map)?;

    Ok(())
}
fn child(container_dir: &PathBuf, rootfs: &PathBuf, argv: &[CString]) -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS)?;
    sethostname("my-container")?;

    // === MOUNT NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWNS)?;

    mount(Some(rootfs), container_dir, None::<&str>, MsFlags::MS_BIND, None::<&str>)?;
    // Change the root directory of the process
    chroot(container_dir)?;
    // Set the process' current working directory
    std::env::set_current_dir("/")?;
    // Create and mount procfs in container
    fs::create_dir_all("/proc")?;
    mount(
        Some("proc"),
        "/proc",
        Some("proc"),
        MsFlags::empty(),
        None::<&str>,
    )?;

    print_proc_info("Child's Isolation")?;
    execvp(&argv[0], argv)?;

    Ok(())
}
````
<!-- column: 1 -->
````rust
fn main() -> Result<()> {
    const ROOT_FS: &str = "/home/cquick/talks/rootfs";
    const CONTAINER_DIR: &str = "/home/cquick/talks/container";
    let rootfs = PathBuf::from(ROOT_FS);
    let container_dir = PathBuf::from(CONTAINER_DIR);

    print_proc_info("Before Isolation")?;

    // === USER NAMESPACE ===
    let uid_map = format!("0 {} 1", nix::unistd::getuid());
    let gid_map = format!("0 {} 1", nix::unistd::getgid());
    unshare(CloneFlags::CLONE_NEWUSER)?;
    write_proc_mappings(&uid_map, &gid_map)?;

    // === PID NAMESPACE - next forked child will be PID 1 ===
    unshare(CloneFlags::CLONE_NEWPID)?;

    match unsafe { fork() } {
        Ok(ForkResult::Parent { child }) => {
            waitpid(child, None)?;
        }
        Ok(ForkResult::Child) => {
            let argv = vec![CString::new("ps")?];
            child(&container_dir, &rootfs, &argv)?;
        }
        Err(err) => Err(err).context("Fork failed!")?,
    }
    Ok(())
}
````
<!-- end_slide -->
