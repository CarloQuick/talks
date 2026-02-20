Guided Build
===
> **Note**: This demonstration linux kernel specific. I will share the slides and github link at the end of the
> presentation if anyone would like to try it themselves. Remember, though, you'll need to be on a linux machine, linux vm, use wsl2, or in container with special privileges.

These Are the only dependencies, that we'll need!

```toml
[dependencies]
anyhow = "1.0.100"
nix = { version = "0.30.1", features = ["sched", "feature", "fs", "mount", "process", "hostname", "signal","user"] }
```

The hardened kernel in Ubuntu 23.10+ restricts unprivileged user namespaces via AppArmor. When trying to make your container rootless, the kernel will prevent it. Follow this post to learn more about it.
running `echo 0 | sudo tee /proc/sys/kernel/apparmor_restrict_unprivileged_userns` will allow modifying user namespaces until the next system restart.

[AppArmor: Restrict Unprivileged User Namespaces](https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces)

<!-- end_slide -->

Printing Process Information
===

```rust
use nix::unistd::{ getcwd, gethostname, getpid, getuid };
fn print_proc_info(label: &str) -> Result<()> {
    eprintln!("[{}]", label);
    eprintln!(
        "uid [{}]\n\thostname [{:?}]  \n\tpid [{}] \n\tcwd [{:?}]",
        getuid(),
        gethostname()?,
        getpid(),
        getcwd()?,
    );
    Ok(())
}
```

For the sake of simplicity, I won't be showing this print function, but it works behind the scenes to provide an accurate view of the process' current state.

<!-- end_slide -->
