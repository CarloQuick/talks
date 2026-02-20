#!/bin/bash
# build.sh

DIR="talks/seattle"

cat > "$DIR/presentation.md" << 'FRONTMATTER'
---
theme:
  override:
    code:
      alignment: left
      background: true
title: "Building a Minimal **Rootless** container in Rust"
author: Carlo Quick
---
FRONTMATTER

cat >> "$DIR/presentation.md" \
    "$DIR/outcome.md" \
    "$DIR/intro.md" \
    "$DIR/vm_vs_containers.md" \
    "$DIR/namespaces_and_cgroups.md" \
    "$DIR/root_problem.md" \
    "$DIR/rootless_containers.md" \
    "$DIR/why_rust.md" \
    "$DIR/tools.md" \
    "$DIR/guided_build.md" \
    "$DIR/process_baseline.md" \
    "$DIR/trying_set_hostname.md" \
    "$DIR/unshare.md" \
    "$DIR/unshare_uts_namespace_attempt.md" \
    "$DIR/uid_gid_map_explanation.md" \
    "$DIR/unshare_user_uts_namespace_success.md" \
    "$DIR/unshare_pid_namespace_attempt.md" \
    "$DIR/fork.md" \
    "$DIR/fn_child.md" \
    "$DIR/fork_child.md" \
    "$DIR/inspect_child_process.md" \
    "$DIR/unshare_mount_namespace.md" \
    "$DIR/recap.md" \
    "$DIR/finishline.md" \
    "$DIR/bento.md" \
    "$DIR/refs.md" \
    "$DIR/thanks.md"

presenterm "$DIR/presentation.md" -x