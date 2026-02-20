
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
