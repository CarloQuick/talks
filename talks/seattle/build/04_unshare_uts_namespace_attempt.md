
unshare the uts namespace — uh oh
===

<!-- column_layout: [3, 2] -->


<!-- column: 0 -->
````rust +exec:rust-script +id:failed_unshare_uts
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
use anyhow::{Context, Result};
use nix::{
    sched::{CloneFlags, unshare},
    unistd::{ getcwd, gethostname, getpid, getuid, sethostname }
};
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

fn main() -> Result<()> {
    print_proc_info("Before Isolation")?;

    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to isolate uts namespace")?;
    sethostname("my-container")?;

    print_proc_info("After Isolation")?;
    Ok(())
}
````
* We added `unshare(CLONE_NEWUTS)` — but the output shows a permissions error
* Unprivileged users can't create namespaces without a user namespace first
<!-- column: 1 -->
<!-- snippet_output: failed_unshare_uts -->
<!-- end_slide -->
