Outcome
===

By the end of this talk, you’ll have a concrete mental model of how containers work, tools to make your own, and why Rust makes exploring Linux kernel concepts far more approachable.

Container properties checklist
* ✅ Rootless
* ✅ Isolated Hostname
* ✅ Believes it is PID 1
* ✅ Isolated root filesystemv
<!-- end_slide -->

Intro
===

# Bio

Carlo Quick - Software Engineer, Watahan Holdings

- Tokyo, Japan

# Talk Inspiration

This whole thing started on a lunch break, staring at a bento— basically a Japanese lunch box — and I caught myself thinking: I use containers every day… and I don’t actually know what a container is.

Also, If you [Liz Rice](https://www.lizrice.com/) has multiple excellent videos on youtube of her building containers from scratch in Go. She's an incredible speaker and author - who literally wrote the book on [Container security"](https://containersecurity.tech/). Many portions of this section are inspired by Liz

Alright, it's time to start coding ourselves a MVRC. We'll be focusing more today on using namespaces to get process isolation and will save cgroups for later.
<!-- end_slide -->
