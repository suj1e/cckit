## Why

The barnhk hooks install script (`install.sh`) fails on Linux systems. While the script includes basic Linux detection, there are likely issues with shell compatibility, path handling, or jq operations that prevent successful installation on Linux environments.

## What Changes

- Fix shell compatibility issues in `install.sh` for Linux (bash vs sh differences)
- Ensure all path operations work correctly on Linux
- Fix jq JSON parsing operations that may behave differently on Linux
- Add proper error handling and diagnostics for Linux-specific failures
- Verify script works across common Linux distributions (Ubuntu, Debian, Fedora, etc.)

## Capabilities

### New Capabilities

- `linux-install-support`: Robust Linux installation support with proper error handling and cross-distribution compatibility

### Modified Capabilities

- None (this is a bug fix, not a requirement change)

## Impact

- `hooks/barnhk/install.sh` - Main installation script
- `hooks/barnhk/lib/*.sh` - Hook scripts may need minor fixes for Linux compatibility
- Users on Linux will be able to successfully install and use barnhk hooks
