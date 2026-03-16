
Rust + exploring Linux kernel = ❤️
===
<!-- font_size: 2 -->
<!-- pause -->
# Rust doesn't invent new container primitives. It doesn't replace syscalls.

🦀
<!-- pause -->
# It gives you **compiler-enforced honesty**!
<!-- pause -->
* Fallible operation returns a `Result`
* Unsafe operation is explicitly marked
* Boundaries between safe and dangerous are **visible in the code**

The language refuses to let you gloss over the hard parts.
<!-- end_slide -->

fork(): C vs. Rust
===
* `fork()` creates a new process by duplicating the calling process. The new process is referred to as the child process.
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
* Returns `-1`, `0`, or a PID — you check manually
* Errors surface via `errno`, not the return value
* Nothing stops you from ignoring the error case

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
* Returns a `Result<ForkResult>` — exhaustive by design
* The compiler requires you handle `Parent`, `Child`, and `Err`
* `unsafe` is explicit — the danger is visible, not hidden
<!-- end_slide -->
