# ==============================================================================
# cckit - Claude Code Kit Installer (PowerShell)
# Installs cckit plugins via marketplace on Windows
# ==============================================================================

param(
    [string]$PluginName = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MarketplaceJson = "$env:USERPROFILE\.claude\plugins\known_marketplaces.json"

# Available plugins
$Plugins = @("jbrick", "barnhk")

# ==============================================================================
# Helper Functions
# ==============================================================================

function Write-Banner {
    Write-Host "------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "         cckit - Claude Code Kit Installer (Windows)  " -ForegroundColor Cyan
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

function Write-Warn {
    param([string]$Message)
    Write-Host "[!] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

# Test if claude CLI is available
function Test-ClaudeCLI {
    $result = Get-Command claude -ErrorAction SilentlyContinue
    if (-not $result) {
        Write-Error "claude CLI not found. Please install Claude Code first."
        Write-Host "  https://claude.ai/code" -ForegroundColor Gray
        exit 1
    }
}

# Ensure cckit marketplace is registered
function Register-Marketplace {
    # Create directory if needed
    $marketplaceDir = Split-Path -Parent $MarketplaceJson
    if (-not (Test-Path $marketplaceDir)) {
        New-Item -ItemType Directory -Path $marketplaceDir -Force | Out-Null
    }

    # Check if already registered
    if (Test-Path $MarketplaceJson) {
        try {
            $json = Get-Content $MarketplaceJson -Raw | ConvertFrom-Json
            if ($json.PSObject.Properties.Name -contains "cckit") {
                Write-Info "cckit marketplace already registered"
                return
            }
        } catch {
            # File exists but is invalid JSON, proceed to add
        }
    }

    Write-Info "Adding cckit marketplace..."
    try {
        $result = claude plugin marketplace add $ScriptDir 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed: $result"
        }
        Write-Success "cckit marketplace registered"
    } catch {
        Write-Error "Failed to add cckit marketplace."
        Write-Host "  Make sure .claude-plugin/marketplace.json exists in the cckit directory." -ForegroundColor Gray
        exit 1
    }
}

# Temporarily patch plugin.json for Windows (.ps1 extension)
# Returns the backup path for later restoration
function Set-PluginJsonWindows {
    $pluginDir = "$ScriptDir\hooks\barnhk\.claude-plugin"
    $pluginJson = "$pluginDir\plugin.json"
    $backupJson = "$pluginDir\plugin.json.bak"

    if (-not (Test-Path $pluginJson)) {
        Write-Error "plugin.json not found at $pluginJson"
        exit 1
    }

    Write-Info "Patching plugin.json for Windows (.ps1 hooks)..."
    Copy-Item $pluginJson $backupJson -Force

    $content = Get-Content $pluginJson -Raw
    $content = $content -replace '\.sh"', '.ps1"'
    Set-Content $pluginJson $content -NoNewline

    return $backupJson
}

# Restore original plugin.json
function Restore-PluginJson {
    param([string]$BackupPath)

    $pluginJson = [System.IO.Path]::ChangeExtension($BackupPath, ".json")
    if (Test-Path $BackupPath) {
        Move-Item $BackupPath $pluginJson -Force
        Write-Info "Restored original plugin.json"
    }
}

# Install a single plugin
function Install-Plugin {
    param([string]$Name)

    Write-Info "Installing $Name..."
    try {
        $result = claude plugin install "${Name}@cckit" --scope user 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed: $result"
        }
        Write-Success "$Name installed"
    } catch {
        Write-Error "Failed to install $Name"
        Write-Host "  $result" -ForegroundColor Gray
        return $false
    }
    return $true
}

# ==============================================================================
# Main
# ==============================================================================

Write-Banner

# Pre-flight checks
Test-ClaudeCLI

# Register marketplace
Register-Marketplace

# Patch plugin.json for Windows
$backup = Set-PluginJsonWindows

try {
    # Install plugins
    if ($PluginName) {
        # Install specific plugin
        if ($PluginName -in $Plugins) {
            $ok = Install-Plugin $PluginName
            if (-not $ok) { exit 1 }
        } else {
            Write-Error "Unknown plugin: $PluginName"
            Write-Host "Available plugins: $($Plugins -join ', ')" -ForegroundColor Gray
            exit 1
        }
    } else {
        # Install all plugins
        $failed = 0
        foreach ($p in $Plugins) {
            if (-not (Install-Plugin $p)) {
                $failed++
            }
        }
        if ($failed -gt 0) {
            Write-Warn "$failed plugin(s) failed to install"
        }
    }
} finally {
    # Always restore original plugin.json
    Restore-PluginJson -BackupPath $backup
}

Write-Host ""
Write-Success "Installation complete!"
Write-Host ""
Write-Host "Installed plugins:" -ForegroundColor White
Write-Host "  - jbrick:   /jbrick <service-name>" -ForegroundColor Gray
Write-Host "  - barnhk:   Safety & notification hooks" -ForegroundColor Gray
Write-Host ""
Write-Host "To uninstall, run: .\uninstall.ps1 [plugin-name]" -ForegroundColor Gray
exit 0
