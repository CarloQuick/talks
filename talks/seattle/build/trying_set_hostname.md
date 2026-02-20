(trying to) Do Something container-y-ish
===
<!-- column_layout: [2, 3] -->


<!-- column: 1 -->
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
    sethostname("my-container").context("Failed to set process hostname")?;
    print_proc_info("After Isolation")?;
    Ok(())
}
````
<!-- column: 0 -->
<!-- snippet_output: containery -->

<!-- end_slide -->
