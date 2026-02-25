<!-- font_size: 4 -->
Why Rust?
===
<!-- alignment: center -->
<!-- font_size: 2 -->
<!-- pause -->
# How does Rust make exploring Linux kernel concepts far more approachable
<!-- pause -->
# Rust doesn't invent new container primitives. It doesn't replace syscalls.

* It gives you **compiler-enforced honesty**.
* Fallible operation returns a `Result`
* Unsafe operation is explicitly marked
* Boundaries between safe and dangerous are **visible in the code**

The language refuses to let you gloss over the hard parts.
<!-- end_slide -->

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->
```c
// C — fork(2)
pid = fork();
switch (pid) {
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
    case 0:
        puts("Child exiting.");
        _exit(EXIT_SUCCESS);
    default:
        printf("Child is PID %jd\n",
               (intmax_t) pid);
        exit(EXIT_SUCCESS);
}
```
<!-- column: 1 -->
```rust
// Rust — nix::unistd::fork
match unsafe { fork() } {
    Ok(Parent { child, .. }) => {
        println!("Child PID {}", child);
        waitpid(child, None)?;
    }
    Ok(Child) => {
        write(stdout(),
        b"Child process\n").ok();
        unsafe { libc::_exit(0) };
    }
    Err(_) => bail!("Fork failed."),
}
```
<!-- end_slide -->
