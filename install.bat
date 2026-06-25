@echo off
REM ==============================================================================
REM cckit - Claude Code Kit Installer (CMD Entry Point)
REM Launches install.ps1 with forwarded arguments
REM ==============================================================================

REM Set UTF-8 code page for correct character display
chcp 65001 >nul 2>&1

REM Forward all arguments to PowerShell installer
powershell -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
