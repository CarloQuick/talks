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
