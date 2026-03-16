#!/bin/bash
# build.sh

DIR="talks/seattle"
INTRO="$DIR"/intro
TECH="$DIR"/technical
BUILD="$DIR"/build
ROADMAP="$DIR"/roadmap
OUTRO="$DIR"/outro
RECAP="$DIR"/recap

cat > "$DIR/presentation.md" << 'FRONTMATTER'
---
theme:
  override:
    code:
      alignment: left
      background: true
title: "Building a Minimal, Rootless Container in Rust"
author: Carlo Quick
---
FRONTMATTER

cat >> "$DIR/presentation.md" \
    "$INTRO/intro.md" \
    "$TECH/vm_vs_containers.md" \
    "$TECH/namespaces_and_cgroups.md" \
    "$TECH/rootless_containers.md" \
    "$TECH/why_rust.md" \
    "$TECH/tools.md" \
    "$BUILD/01_guided_build.md" \
    "$ROADMAP/0_roadmap.md" \
    "$BUILD/02_process_baseline.md" \
    "$BUILD/03_trying_set_hostname.md" \
    "$TECH/unshare.md" \
    "$BUILD/04_unshare_uts_namespace_attempt.md" \
    "$BUILD/05_uid_gid_map_explanation.md" \
    "$BUILD/06_unshare_user_uts_namespace_success.md" \
    "$ROADMAP/1_roadmap.md" \
    "$BUILD/07_unshare_pid_namespace_attempt.md" \
    "$BUILD/08_fork.md" \
    "$BUILD/09_fn_child.md" \
    "$BUILD/10_fork_child.md" \
    "$ROADMAP/2_roadmap.md" \
    "$BUILD/11_inspect_child_process.md" \
    "$BUILD/12_unshare_mount_namespace.md" \
    "$BUILD/13_finishline.md" \
    "$ROADMAP/3_roadmap.md" \
    "$OUTRO/bento.md" \
    "$OUTRO/refs.md" \
    "$OUTRO/thanks.md"

presenterm "$DIR/presentation.md" -x 