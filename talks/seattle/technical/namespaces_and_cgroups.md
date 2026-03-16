
Namespaces and Cgroups
===

<!-- column_layout: [1, 1] -->
<!-- column: 0 -->
<!-- pause -->
<!-- font_size: 2 -->
# Namespaces

- control what a process can **see**.

<!-- pause -->
<!-- column: 1 -->

# Cgroups
- control what a process can **use**.

<!-- pause -->
<!-- reset_layout -->
<!-- new_lines: 2 -->
**Namespaces** give a process its own view of things like PIDs, hostnames, and filesystems. **Cgroups** keep it from eating all your CPU and memory.

Today, we're focusing entirely on **namespaces**. Cgroups are important — but that's a whole other talk.
<!-- end_slide -->

Namespaces
===
# Each process has a /proc/[pid]/ns subdirectory for its namespaces.
* PID
* Network (network stack)
* Mount (fs mount point)
* UTS (hostname and system identifier)
* IPC (inter-process communication)
* User (user and group id)
* Cgroup
<!-- alignment: center -->
![](./assets/proc_sleep.png)
_Each symlink points to the namespace instance the process currently belongs to._
<!-- end_slide -->
<!-- skip_slide -->
Namespaces
===
<!-- alignment: center -->
| Namespace | Flag | Page | Isolates | 
|:---|:---|:---|:---|
| Cgroup |CLONE_NEWCGROUP |cgroup_namespaces(7) |  Cgroup root directory |
| IPC | CLONE_NEWIPC | ipc_namespaces(7) |System V IPC, POSIX message queues |
| Network | CLONE_NEWNET | network_namespaces(7) | Network devices,stacks,ports, etc. |
| Mount | CLONE_NEWNS | mount_namespaces(7) | Mount points |
| PID | CLONE_NEWPID | pid_namespaces(7) | Process IDs |
| Time | CLONE_NEWTIME | time_namespaces(7) | Boot and monotonic clocks |
| User | CLONE_NEWUSER | user_namespaces(7) | User and group IDs |
| UTS | CLONE_NEWUTS | uts_namespaces(7) | Hostname and NIS domain name |

![](./assets/proc_sleep.png)

<!-- end_slide -->
<!-- skip_slide -->
Container vs Host's Perspective
===
<!-- column_layout: [1, 1] -->
<!-- column: 0 -->
<!-- alignment: center -->
<!-- font_size: 2 -->
**Container's View**

"I'm the whole machine"

* PID:  1
👑 I am alone!

![](./assets/alone.jpg)
<!-- column: 1 -->
<!-- alignment: center -->
**Host's View**

* PID 1     systemd
* PID 435   sshd
* PID 1200  nginx
* PID 4812  "container"  ←
* PID 4999  postgres
...

<!-- end_slide -->
