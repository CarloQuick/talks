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
