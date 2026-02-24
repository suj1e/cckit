## Context

The barnhk hooks provide safety and notification features for Claude Code. The installation script (`install.sh`) was primarily developed and tested on macOS. While it includes basic Linux detection, users report installation failures on Linux systems.

Common Linux-specific issues in shell scripts:
- Shebang differences (`#!/bin/bash` vs `#!/bin/sh`)
- `BASH_SOURCE` availability (not available in POSIX sh)
- `[[ ]]` vs `[ ]` test syntax compatibility
- `source` vs `.` for sourcing files
- `readlink` vs `greadlink` for path resolution
- jq behavior differences across distributions

## Goals / Non-Goals

**Goals:**
- Fix all Linux compatibility issues in `install.sh` and hook scripts
- Ensure consistent behavior across macOS and Linux
- Add better error messages for debugging install failures
- Support common Linux distributions (Ubuntu, Debian, Fedora, Arch)

**Non-Goals:**
- Adding new features or capabilities
- Supporting non-bash shells (zsh, fish, etc.)
- Windows/WSL support (out of scope)

## Decisions

1. **Use `#!/usr/bin/env bash` shebang**
   - More portable than `#!/bin/bash` which may not exist on some systems
   - Alternative: Keep `#!/bin/bash` - simpler but less portable

2. **Replace `BASH_SOURCE` with `$0` where appropriate**
   - `BASH_SOURCE` is bash-specific; `$0` works in more shells
   - Alternative: Keep `BASH_SOURCE` and document bash requirement

3. **Use POSIX-compatible constructs where possible**
   - Use `[ ]` instead of `[[ ]]` for simple tests
   - Use `.` instead of `source` for POSIX compatibility
   - Alternative: Require bash explicitly and use bash features

4. **Add explicit error checking**
   - Check for bash version compatibility
   - Verify jq is working before proceeding
   - Add verbose mode for debugging

## Risks / Trade-offs

- **Risk**: Changes may break macOS compatibility
  - Mitigation: Test on both macOS and Linux after changes

- **Risk**: Some edge cases on less common distributions
  - Mitigation: Focus on Ubuntu/Debian/Fedora, document requirements
