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
