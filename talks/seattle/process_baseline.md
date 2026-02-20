Process Baseline
===
<!-- column_layout: [2, 3] -->


<!-- column: 0 -->

````rust +exec:rust-script +id:process_baseline
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::Result;
# use nix::unistd::{ getcwd, gethostname, getpid, getuid };
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
    Ok(())
}
````

<!-- column: 1 -->
<!-- snippet_output: process_baseline -->

<!-- end_slide -->
