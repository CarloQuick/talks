
trying to do something container-y
===
<!-- column_layout: [3, 2] -->


<!-- column: 0 -->
````rust +exec:rust-script +id:containery
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
use anyhow::{Context, Result};
use nix::unistd::{ getcwd, gethostname, getpid, getuid, sethostname };
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
    sethostname("my-container").context("Failed to set container hostname")?;
    print_proc_info("After Isolation")?;
    Ok(())
}
````
* `sethostname` without a namespace — the hostname change affects the whole host
* The output will show why this approach is a problem
<!-- column: 1 -->
<!-- snippet_output: containery -->

<!-- end_slide -->
