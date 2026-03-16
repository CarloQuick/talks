unshare
===

# unshare(2)
"disassociate parts of the process execution context"

<!-- pause -->
It takes a flag argument that specifies which parts of the process' execution should be "unshared".

For today's talk, we'll only be using:

<!-- incremental_lists: true -->

- CloneFlags::CLONE_NEWUSER - new user namespace
- CloneFlags::CLONE_NEWUTS - new uts (hostname) namespace
- CloneFlags::CLONE_NEWPID - new pid namespace
- CloneFlags::CLONE_NEWNS - new mount namespace

<!-- end_slide -->
