
Bento 🍱
===
<!-- alignment: center -->

_A rootless container runtime, built from scratch in Rust._

<!-- new_lines: 1 -->

![](./assets/bento.png)

<!-- new_lines: 1 -->

* Parses and runs real OCI images (same format as Docker)
* Isolates via Linux namespaces — no root required
* Implements overlay filesystem for copy-on-write layers

<!-- end_slide -->
Bento 🍱 — under the hood
===
<!-- column_layout: [1, 1] -->
<!-- column: 0 -->
```bash
# Pull and create a container
cargo run -- create my-container busybox

# Attach to a running container's namespaces
# and execute a command inside it
cargo run -- exec my-container ls -la

# Force kill
cargo run -- kill my-container
```

<!-- column: 1 -->
**Future Plans**
* Cgroups
* Network namespaces
* Split into `bentod` + `bento`
* Pseudoterminals

<!-- end_slide -->