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
