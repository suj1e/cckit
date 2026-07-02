# ==============================================================================
# cckit - Claude Code Kit Uninstaller (PowerShell)
# Uninstalls cckit plugins on Windows
# ==============================================================================

param(
    [string]$PluginName = ""
)

$ErrorActionPreference = "Stop"

# Available plugins
$Plugins = @("jbrick", "barnhk", "just-task")

# ==============================================================================
# Helper Functions
# ==============================================================================

function Write-Banner {
    Write-Host "------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "       cckit - Claude Code Kit Uninstaller (Windows)  " -ForegroundColor Cyan
    Write-Host "------------------------------------------------------" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "  -> " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERR] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

# Uninstall a single plugin
function Uninstall-Plugin {
    param([string]$Name)

    Write-Info "Uninstalling $Name..."
    try {
        $result = claude plugin uninstall "${Name}@cckit" --scope user 2>&1
        if ($LASTEXITCODE -ne 0) {
            # "already removed" is not an error
            if ($result -match "not installed|already removed") {
                Write-Host "  $Name not installed or already removed" -ForegroundColor Gray
                return
            }
            throw "Failed: $result"
        }
        Write-Success "$Name uninstalled"
    } catch {
        Write-Error "Failed to uninstall $Name"
        Write-Host "  $result" -ForegroundColor Gray
    }
}

# ==============================================================================
# Main
# ==============================================================================

Write-Banner

# Check for claude CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Error "claude CLI not found."
    exit 1
}

if ($PluginName) {
    if ($PluginName -in $Plugins) {
        Uninstall-Plugin $PluginName
    } else {
        Write-Error "Unknown plugin: $PluginName"
        Write-Host "Available plugins: $($Plugins -join ', ')" -ForegroundColor Gray
        exit 1
    }
} else {
    foreach ($p in $Plugins) {
        Uninstall-Plugin $p
    }
}

Write-Host ""
Write-Success "Uninstallation complete!"
exit 0
