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
