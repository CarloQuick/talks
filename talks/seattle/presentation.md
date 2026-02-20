---
theme:
  override:
    code:
      alignment: left
      background: true
title: "Building a Minimal **Rootless** container in Rust"
author: Carlo Quick
---
Outcome
===

By the end of this talk, you’ll have a concrete mental model of how containers work, tools to make your own, and why Rust makes exploring Linux kernel concepts far more approachable.

Container properties checklist
* ✅ Rootless
* ✅ Isolated Hostname
* ✅ Believes it is PID 1
* ✅ Isolated root filesystemv
<!-- end_slide -->

Intro
===

# Bio

Carlo Quick - Software Engineer, Watahan Holdings

- Tokyo, Japan

# Talk Inspiration

This whole thing started on a lunch break, staring at a bento— basically a Japanese lunch box — and I caught myself thinking: I use containers every day… and I don’t actually know what a container is.

Also, If you [Liz Rice](https://www.lizrice.com/) has multiple excellent videos on youtube of her building containers from scratch in Go. She's an incredible speaker and author - who literally wrote the book on [Container security"](https://containersecurity.tech/). Many portions of this section are inspired by Liz

Alright, it's time to start coding ourselves a MVRC. We'll be focusing more today on using namespaces to get process isolation and will save cgroups for later.
<!-- end_slide -->

VMs vs Containers
===

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

**Virtual Machines**

Full machine virtualization. Each VM runs its own operating system.

A **hypervisor** sits underneath and slices up real hardware — CPU, memory, networking — and hands pieces to each VM.

```
┌──────────┬──────────┐
│  App A   │  App B   │
├──────────┤──────────┤
│Bins/Libs │Bins/Libs │
├──────────┤──────────┤
│ Guest OS │ Guest OS │
│ (kernel) │ (kernel) │
╠══════════╧══════════╣
│      Hypervisor     │
├─────────────────────┤
│      Hardware       │
└─────────────────────┘
```

<!-- column: 1 -->

**Containers**

**Not a machine**. Just a process — or a group of processes — running on the host kernel.

No second kernel. No guest OS. But the process is **made to believe it's alone**.

```
┌──────────┬──────────┐
│  App A   │  App B   │
├──────────┤──────────┤
│Bins/Libs │Bins/Libs │
╠══════════╧══════════╣
│  Container Runtime  │
├─────────────────────┤
│       Host OS       │
│   (shared kernel)   │
├─────────────────────┤
│       Hardware      │
└─────────────────────┘
```

<!-- reset_layout -->

# How Does Linux Pull This Off?

<!-- end_slide -->
Namespaces and Cgroups?
===

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

# Namespaces

- control what a process can **see**.

<!-- pause -->
<!-- column: 1 -->

# Cgroups

<!-- pause -->

- control what a process can **use**.

<!-- pause -->
<!-- reset_layout -->

**Namespaces** give a process its own view of things like PIDs, hostnames, and filesystems. **Cgroups** keep it from eating all your CPU and memory.

Today, we're focusing entirely on **namespaces**. Cgroups are important — but that's a whole other talk.

Namespaces

| Namespace | Flag | Page | Isolates | 
|:---|:---|:---|:---|
| Cgroup |CLONE_NEWCGROUP |cgroup_namespaces(7) |  Cgroup root directory |
| IPC | CLONE_NEWIPC | ipc_namespaces(7) |System V IPC, POSIX message queues |
| Network | CLONE_NEWNET | network_namespaces(7) | Network devices,stacks,ports, etc. |
| Mount | CLONE_NEWNS | mount_namespaces(7) | Mount points |
| PID | CLONE_NEWPID | pid_namespaces(7) | Process IDs |
| Time | CLONE_NEWTIME | time_namespaces(7) | Boot and monotonic clocks |
| User | CLONE_NEWUSER | user_namespaces(7) | User and group IDs |
| UTS | CLONE_NEWUTS | uts_namespaces(7) | Hostname and NIS domain name |

<!-- pause -->

# Container vs Host's Perspective

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

**Container's View**

```
┌─────────────────────────┐
│  "I'm the whole machine"│
│                         │
│  PID:  1                │
│  Host: my-container     │
│  Root: /                │
│  Procs: just me         │
│                         │
│  👑 I am alone.         │
└─────────────────────────┘
```

<!-- column: 1 -->

**Host's View**

```
┌─────────────────────────┐
│  Processes:             │
│  ├─ PID 1    systemd    │
│  ├─ PID 435  sshd       │
│  ├─ PID 1200 nginx      │
│  ├─ PID 4812 "container"│ ←
│  ├─ PID 4999 postgres   │
│  └─ ...                 │
└─────────────────────────┘
```

<!-- reset_layout -->

<!-- pause -->

That asymmetry is the **core idea** behind containers.

<!-- pause -->

With that — let's talk about what it means to run containers **without root**: going _rootless_.
<!-- end_slide -->
The Root Problem
===

What privileges does a container process actually have?

<!-- pause -->

In common container runtimes, the container process starts with full privileges.

The process runs as **UID 0** — real root — and relies on namespaces for isolation.

<!-- pause -->

Isolation comes from _where the process is allowed to look_, not from _what the process is allowed to do_.

<!-- pause -->

```
┌─────────────────────────────┐
│  Container escapes namespace │
│                              │
│  UID 0 on host              │
│  Full root privileges        │
│  Game over.                  │
└─────────────────────────────┘
```

<!-- end_slide -->
Rootless Containers
===

Rootless containers flip the model:

<!-- pause -->

Instead of **maximum privilege + containment**, start as an **unprivileged user** and selectively add isolation.

<!-- pause -->

```
  Traditional              Rootless
  ──────────              ────────
  Start as root           Start as user
  Add restrictions        Add isolation
  Hope nothing escapes    Limited blast radius
```

<!-- pause -->

This is a **design choice**.

For example:

- **Podman** — rootless by default
- **Docker** — supports rootless, requires configuration

![](term_shot.png)

- [Docker Install](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Linux Post-installation](https://docs.docker.com/engine/install/linux-postinstall)
- [Docker Rootless](https://docs.docker.com/engine/security/rootless)
- [Redhat: What is Podman](https://www.redhat.com/en/topics/containers/what-is-podman)
<!-- end_slide -->
Why Rust?
===
You're crossing security boundaries. Talking directly to the kernel. Mistakes don't crash programs — they **break isolation**.

<!-- pause -->

Rust doesn't invent new container primitives. It doesn't replace syscalls.

It gives you **compiler-enforced honesty**.

<!-- pause -->

- Every fallible operation returns a `Result`
- Every unsafe operation is explicitly marked
- Every boundary between safe and dangerous is **visible in the code**

<!-- pause -->

The language refuses to let you gloss over the hard parts.

<!-- column_layout: [1, 1] -->

<!-- column: 0 -->
```c
// https://man7.org/linux/man-pages/man2/fork.2.html
int
main(void) {
    pid_t pid;

    if (signal(SIGCHLD, SIG_IGN) == SIG_ERR) {
        error("signal");
        exit(EXIT_FAILURE);
    }
    pid = fork();
    switch (pid) {
        case -1:
            perror("fork");
            exit(EXIT_FAILURE);
        case 0:
            puts("Child exiting.");
            fflush(stdout);
            _exit(EXIT_SUCCESS);
        default:
            printf("Child is PID %jd\n", (intmax_t) pid);
            puts("Parent exiting.");
            exit(EXIT_SUCCESS);
    }
}
```
<!-- column: 1 -->
```rust
// modified: https://docs.rs/nix/latest/nix/unistd/fn.fork.html
fn main() -> Result<()> {
    match unsafe { fork() } {
        Ok(ForkResult::Parent { child, .. }) => {
            println!("Child is PID {}", child);
            waitpid(child, None).context("Failed to get child's signal.")?;
        }
        Ok(ForkResult::Child) => {
            write(std::io::stdout(), "New child process\n".as_bytes()).ok();
            unsafe { libc::_exit(0) };
        }
        Err(_) => anyhow::bail!("Fork failed."),
    }
    Ok(())
}
```
<!-- end_slide -->
The Tools
===

The **nix** crate wraps low-level libc calls in idiomatic Rust — not by hiding danger, but by making it explicit in the type system.

<!-- pause -->
**_https://github.com/nix-rust/nix_**

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

**libc**

```c
// unsafe, manual errno handling
pub unsafe extern fn gethostname(
    name: *mut c_char,
    len: size_t
) -> c_int;
```

<!-- column: 1 -->

**nix**

```rust
// returns Result<OsString>
pub fn gethostname() -> Result<OsString>;
```

<!-- reset_layout -->

<!-- pause -->

The kernel is still the kernel. But the **boundary is visible**: this can fail, and you must handle it.

<!-- pause -->

Let's start building.

<!-- end_slide -->
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
unshare
===

"disassociate parts of the process execution context" - unashare(2)

It takes a flag argument that specify which parts of the process' execution should be "unshared".

For today's talk, we'll only be using:

<!-- incremental_lists: true -->

- CloneFlags::CLONE_NEWUSER - new user namespace
- CloneFlags::CLONE_NEWUTS - new uts (hostname) namespace
- CloneFlags::CLONE_NEWPID - new pid namespace
- CloneFlags::CLONE_NEWNS - new mount namespace

...but there are many more

<!-- end_slide -->
unshare the uts namespace
===

<!-- column_layout: [2, 3] -->


<!-- column: 1 -->
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
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;

    print_proc_info("After Isolation")?;
    Ok(())
}
````
<!-- column: 0 -->
<!-- snippet_output: failed_unshare_uts -->
<!-- end_slide -->
goin' rootless
===
```rust
    // -- snip --

    // === USER NAMESPACE ===
    let uid_map = format!("0 {} 1", nix::unistd::getuid());
    let gid_map = format!("0 {} 1", nix::unistd::getgid());
    unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
    write_proc_mappings(&uid_map, &gid_map)?;

    // -- snip --
```

```rust
fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
    std::fs::write("/proc/self/uid_map", uid_map).context("Failed to write to uid")?;
    // Writing `"deny"` disables the syscall setgroups() in the namespace, and then the kernel allows the `gid_map` write.
    std::fs::write("/proc/self/setgroups", "deny").context("Failed to write to gid setgroup")?;
    std::fs::write("/proc/self/gid_map", gid_map).context("Failed to write to gid")?;

    Ok(())
}
```

[explanation]

<!-- end_slide -->
isolation (kinda) achieved!
===
<!-- column_layout: [2, 3] -->


<!-- column: 1 -->

````rust +exec:rust-script +id:kinda_isolation
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
#    print_proc_info("Before Isolation")?;
    // === USER NAMESPACE ===
    let uid_map = format!("0 {} 1", nix::unistd::getuid());
    let gid_map = format!("0 {} 1", nix::unistd::getgid());
    unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
    write_proc_mappings(&uid_map, &gid_map)?;

    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;
#    print_proc_info("After Isolation")?;
#    Ok(())
# }
````

<!-- column: 0 -->
<!-- snippet_output: kinda_isolation -->


<!--reset_layout -->
<!-- pause -->
Container Checklist
* ✅ Rootless
* ✅ Isolated Hostname
* ❌ Believes it is PID 1
* ❌ Isolated root filesystem
<!-- end_slide -->
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
child()
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
fn child() -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;

    print_proc_info("Child Level Isolation")?;
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
        Ok(ForkResult::Parent { child }) => {
            waitpid(child, None)?;
        }
        Ok(ForkResult::Child) => {
            child()?;
        }
        Err(err) => Err(err).context("Fork failed!")?,
    }
   Ok(())
# }
````
<!-- end_slide -->
forking a child process
===
<!-- column_layout: [2, 3] -->


<!-- column: 1 -->

````rust +exec:rust-script +id:forking_proc_child
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
fn child() -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;

    print_proc_info("Child Level Isolation")?;
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
            child()?;
        }
        Err(err) => Err(err).context("Fork failed!")?,
    }
   Ok(())
# }
````
<!-- column: 0 -->
<!-- snippet_output: forking_proc_child -->
<!--reset_layout -->
<!-- pause -->
Container Checklist
* ✅ Rootless
* ✅ Isolated Hostname
* ✅ Believes it is PID 1
* ❌ Isolated root filesystem
<!-- end_slide -->
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
mount namespace
===

````rust
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
# use std::ffi::CString;
use mount::{MsFlags, mount};

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
fn child(container_dir: &PathBuf, rootfs: &PathBuf, argv: &[CString]) -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS).context("Failed to create uts namespace")?;
    sethostname("my-container")?;

    // === MOUNT NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWNS).context("Failed to create a mounted namespace")?;
    mount(Some(rootfs), container_dir, None::<&str>, MsFlags::MS_BIND, None::<&str>)?;
    
    // Change the root directory of the process
    chroot(container_dir)?;
    // Set the process' current working directory
    std::env::set_current_dir("/")?;

    print_proc_info("Child Level Isolation")?;
    execvp(&argv[0], argv)?;
    Ok(())
}

fn main() -> Result<()> {
    const ROOT_FS: &str = "/home/cquick/talks/rootfs";
    const CONTAINER_DIR: &str = "/home/cquick/talks/container";
    let rootfs = PathBuf::from(ROOT_FS);
    let container_dir = PathBuf::from(CONTAINER_DIR);
#    // -- snip -- ↑↑ USER and PID NAMESPACE Isolation ↑↑
#   print_proc_info("Before Isolation")?;
#   // === USER NAMESPACE ===
#   let uid_map = format!("0 {} 1", nix::unistd::getuid());
#   let gid_map = format!("0 {} 1", nix::unistd::getgid());
#   unshare(CloneFlags::CLONE_NEWUSER).context("Failed to create user namespace")?;
#   write_proc_mappings(&uid_map, &gid_map)?;
#    // === PID NAMESPACE - next forked child will be PID 1 ===
#    unshare(CloneFlags::CLONE_NEWPID).context("Failed to create a PID namespace")?;    
#    // Fork() creates a child process by duplicating the parent
#    match unsafe { fork() } {
#        Ok(ForkResult::Parent { child }) => {
#            waitpid(child, None)?;
#        }
#        // -- snip -- ↑↑ Ok(ForkResult::Parent)... ↑↑
#        Ok(ForkResult::Child) => {
#            let argv = vec![CString::new("ls")?];
#            child(&argv)?;
#        }
#        // -- snip --
#        Err(err) => Err(err).context("Fork failed!")?,
#    }
#   Ok(())
# }
// -- snip --
````
![](rootfs.png)

<!-- end_slide -->
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
is this it?
===

<!-- column_layout: [2, 3] -->

<!-- column: 1 -->
````rust +exec:rust-script +id:fork_child_with_mounted_proc
# //! ```cargo
# //! [dependencies]
# //! anyhow = "1.0.100"
# //! nix = { version = "0.30.1", features = ["sched", "fs", "mount", "process", "hostname", "signal","user"] }
# //! ```
# use anyhow::{Context, Result};
# use std::{ffi::CString, path::PathBuf};
# use nix::{
#   mount::{MsFlags, mount},
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
# fn write_proc_mappings(uid_map: &str, gid_map: &str) -> Result<()> {
#     std::fs::write("/proc/self/uid_map", uid_map)?;
#     std::fs::write("/proc/self/setgroups", "deny")?;
#     std::fs::write("/proc/self/gid_map", gid_map)?;
#     Ok(())
# }
fn child(container_dir: &PathBuf, rootfs: &PathBuf, argv: &[CString]) -> Result<()> {
    // === UTS NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWUTS)?;
    sethostname("my-container")?;

    // === MOUNT NAMESPACE ===
    unshare(CloneFlags::CLONE_NEWNS)?;

    mount(
        Some(rootfs), 
        container_dir, 
        None::<&str>, 
        MsFlags::MS_BIND, 
        None::<&str>
    )?;
    // Change the root directory of the process
    chroot(container_dir)?;
    // Set the process' current working directory
    std::env::set_current_dir("/")?;
    // Create and mount procfs in container
    std::fs::create_dir_all("/proc")?;
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

# fn main() -> Result<()> {
#    const ROOT_FS: &str = "/home/cquick/talks/rootfs";
#    const CONTAINER_DIR: &str = "/home/cquick/talks/container";
#    let rootfs = PathBuf::from(ROOT_FS);
#    let container_dir = PathBuf::from(CONTAINER_DIR);
#    print_proc_info("Before Isolation")?;
#    // === USER NAMESPACE ===
#    let uid_map = format!("0 {} 1", nix::unistd::getuid());
#    let gid_map = format!("0 {} 1", nix::unistd::getgid());
#    unshare(CloneFlags::CLONE_NEWUSER)?;
#    write_proc_mappings(&uid_map, &gid_map)?;
#    // === PID NAMESPACE - next forked child will be PID 1 ===
#    unshare(CloneFlags::CLONE_NEWPID)?;
#    match unsafe { fork() } {
#        Ok(ForkResult::Parent { child }) => {
#            waitpid(child, None)?;
#        }
#        Ok(ForkResult::Child) => {
#            let argv = vec![CString::new("ls")?];
#            child(&container_dir, &rootfs, &argv)?;
#        }
#        Err(err) => Err(err).context("Fork failed!")?,
#    }
#    Ok(())
# }
````
<!-- column: 0 -->
<!-- snippet_output: fork_child_with_mounted_proc -->
<!--pause -->
🎉🎉🎉 Container checklist 🎉🎉🎉
* ✅ Rootless
* ✅ Isolated Hostname
* ✅ Believes it is PID 1
* ✅ Isolated root filesystem

<!-- end_slide -->
# Bento 🍱


A rootless container runtime built from scratch in Rust.

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->

**What it does:**
- Parses OCI-compliant container images
- Isolates processes using Linux namespaces (user, PID, mount, UTS)
- Implements overlay filesystem for copy-on-write layers
- Manages container lifecycle


**How it works:**
- No root required — user namespaces for unprivileged isolation
- Extracts and layers OCI images (same format as Docker)
- Forks into isolated namespaces, mounts overlay, executes command

<!-- column: 1 -->

# CLI Commands
```bash
# Create a container
cargo run -- create my-container busybox

# Start it
cargo run -- start my-container

# Run a command inside it
cargo run -- exec my-container ls -la

# Check status
cargo run -- status my-container
cargo run -- status --all

# Graceful shutdown
cargo run -- stop my-container

# Force kill
cargo run -- kill my-container
```

**Future Plans:**
- Cgroups
- Network Namespaces
- Split into 2 crates (bentod + bento)
- Pseudoterminals

<!-- end_slide -->

references
===
* [Docker Install](https://docs.docker.com/engine/install/ubuntu/)
* [Docker Linux Post-installation](https://docs.docker.com/engine/install/linux-postinstall)
* [Docker Rootless](https://docs.docker.com/engine/security/rootless)
* [Redhat: What is Podman](https://www.redhat.com/en/topics/containers/what-is-podman)
* [AppArmor: Restrict Unprivileged User Namespaces](https://ubuntu.com/blog/ubuntu-23-10-restricted-unprivileged-user-namespaces)
* [fork(2)](https://man7.org/linux/man-pages/man2/fork.2.html)
* [nix::unistd::fork()](https://docs.rs/nix/latest/nix/unistd/fn.fork.html)
* [CloneFlags](https://man7.org/linux/man-pages/man7/namespaces.7.html)
* [syscalls](https://man7.org/linux/man-pages/man2/syscalls.2.html)
* [youki: A container runtime in Rust](https://github.com/youki-dev/youki)
* [Liz Rice](https://www.lizrice.com/)
* [Container Security](https://containersecurity.tech/)
* [Rootless Containers from Scratch - Liz Rice](https://www.youtube.com/watch?v=jeTKgAEyhsA)
* [cgroups(7)](https://man7.org/linux/man-pages/man7/cgroups.7.html)
* [unshare(2)](https://man7.org/linux/man-pages/man2/unshare.2.html)
* [umount(2)](https://man7.org/linux/man-pages/man2/umount.2.html)
* [mount(8)](https://man7.org/linux/man-pages/man8/mount.8.html)
* [execve(2)](https://man7.org/linux/man-pages/man2/execve.2.html)
* [fork(2)](https://man7.org/linux/man-pages/man2/fork.2.html)
* [chroot(2)](https://man7.org/linux/man-pages/man2/chroot.2.html)
<!-- end_slide -->
thanks
===
