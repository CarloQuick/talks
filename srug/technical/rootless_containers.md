
the root problem
===
<!-- font_size: 2 -->
A **container** is a process with a restricted view of the system.
<!-- new_lines: 1 -->
<!-- pause -->
What privileges does that process actually have?
<!-- pause -->
<!-- new_lines: 1 -->
<!-- alignment: center -->
```bash
$ docker run --rm alpine whoami
root
```
<!-- pause -->
🚨 By default, the Docker engine runs containers as **root**.

Docker does support rootless mode — but it requires additional configuration.
<!-- pause -->
![image:width:60%](./assets/term_shot.png)
<!-- end_slide -->

Rootless Containers
===
<!-- font_size: 2 -->
Rootless containers run as an unprivileged user — no root required.

<!-- pause -->

If the process escapes isolation, it's still just **you** on the host.

<!-- pause -->
<!-- alignment: center -->

<!-- new_lines: 1 -->

_Smaller blast radius. Safer by default._

<!-- end_slide -->