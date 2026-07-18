#!/usr/bin/env node

'use strict';

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// ── Constants ────────────────────────────────────────────────────────────────

const PKG_ROOT = path.resolve(__dirname, '..');
const MARKETPLACE_NAME = 'cckit';
const MARKETPLACE_JSON = path.join(PKG_ROOT, '.claude-plugin', 'marketplace.json');
const KNOWN_MARKETPLACES = path.join(os.homedir(), '.claude', 'plugins', 'known_marketplaces.json');

const ALL_PLUGINS = ['barnhk', 'review-merge-sync'];

const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const NC = '\x1b[0m'; // No Color

// ── Utilities ────────────────────────────────────────────────────────────────

function run(cmd, opts = {}) {
  const defaults = { stdio: 'inherit', encoding: 'utf8' };
  return execSync(cmd, { ...defaults, ...opts });
}

function runSilent(cmd) {
  try {
    return execSync(cmd, { stdio: 'pipe', encoding: 'utf8' }).trim();
  } catch {
    return '';
  }
}

function check(ok, msg) {
  return ok ? `${GREEN}✓${NC} ${msg}` : `${RED}✗${NC} ${msg}`;
}

function log(msg) {
  console.log(msg);
}

function warn(msg) {
  console.error(`${YELLOW}⚠${NC} ${msg}`);
}

function error(msg) {
  console.error(`${RED}✗${NC} ${msg}`);
}

function exit(msg, code = 1) {
  error(msg);
  process.exit(code);
}

// Check if claude CLI is available
function claudeExists() {
  const cmd = process.platform === 'win32' ? 'where claude' : 'which claude';
  try {
    execSync(cmd, { stdio: 'pipe' });
    return true;
  } catch {
    return false;
  }
}

// Read JSON file, return null on failure
function readJSON(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return null;
  }
}

// Read marketplace.json from package root to get plugin list
function getMarketplacePlugins() {
  const mkt = readJSON(MARKETPLACE_JSON);
  if (!mkt || !mkt.plugins) return [];
  return mkt.plugins.map(p => p.name);
}

// Resolve plugins: if user specified names, use those; otherwise use all from marketplace
function resolvePlugins(args) {
  if (args.length > 0) {
    const valid = getMarketplacePlugins();
    for (const name of args) {
      if (!valid.includes(name)) {
        warn(`Unknown plugin "${name}". Available: ${valid.join(', ')}`);
      }
    }
    return args.filter(n => valid.includes(n));
  }
  return ALL_PLUGINS;
}

// Check if marketplace is already registered
function isMarketplaceRegistered() {
  const kf = readJSON(KNOWN_MARKETPLACES);
  return kf && kf[MARKETPLACE_NAME] !== undefined;
}

// ── Commands ─────────────────────────────────────────────────────────────────

function cmdInstall(args) {
  if (!claudeExists()) {
    exit('Claude Code is not installed. Please install it first: https://claude.ai/code');
  }

  // Check for --local flag (dev testing)
  const isLocal = args.includes('--local');
  const pluginArgs = args.filter(a => a !== '--local');

  // Validate marketplace.json exists
  if (!fs.existsSync(MARKETPLACE_JSON)) {
    exit(`Marketplace definition not found: ${MARKETPLACE_JSON}`);
  }

  const plugins = resolvePlugins(pluginArgs);
  if (plugins.length === 0) {
    exit('No valid plugins to install.');
  }

  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log(`${CYAN}  cckit — Installing plugins${NC}`);
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log('');

  // Step 1: Register/update marketplace
  // Default: GitHub source (same experience for everyone)
  // --local: local directory (dev testing of unreleased changes)
  const marketSource = isLocal ? PKG_ROOT : 'https://github.com/suj1e/cckit';
  const sourceLabel = isLocal ? 'directory' : 'github';
  log(`${CYAN}→ Registering cckit marketplace (${sourceLabel})...${NC}`);
  try {
    run(`claude plugin marketplace add "${marketSource}"`, { stdio: 'pipe' });
    log(`${GREEN}✓${NC} Marketplace registered (${sourceLabel})`);
  } catch (err) {
    exit(`Failed to register marketplace: ${err.message}`);
  }
  log('');

  // Step 2: Install plugins
  let success = 0;
  let fail = 0;

  for (const name of plugins) {
    log(`${CYAN}→ Installing ${name}...${NC}`);
    try {
      run(`claude plugin install ${name}@${MARKETPLACE_NAME} --scope user`, { stdio: 'pipe' });
      log(`${GREEN}✓${NC} ${name} installed`);
      success++;
    } catch (err) {
      const msg = (err.stderr || err.message || '').toString();
      log(`${RED}✗${NC} ${name} failed: ${msg.trim()}`);
      fail++;
    }
  }

  log('');
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log(`  Complete: ${success} installed, ${fail} failed`);
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);

  if (success > 0 && fail === 0) {
    log('');
    log('Installed plugins:');
    log('  barnhk hooks          Safety hooks');
    log('  /review-merge-sync    Code review → merge → sync workflow');
    log('');
    log('Uninstall: npx @suj1e/cckit uninstall [name]');
  }
}

function cmdUninstall(args) {
  if (!claudeExists()) {
    exit('Claude Code is not installed. Please install it first: https://claude.ai/code');
  }

  // Read which plugins exist in marketplace
  const available = getMarketplacePlugins();

  // If args given, uninstall specific; otherwise all cckit plugins
  let targets;
  if (args.length > 0) {
    targets = args.filter(n => available.includes(n));
    if (targets.length === 0) {
      exit(`None of [${args.join(', ')}] are known cckit plugins. Available: ${available.join(', ')}`);
    }
  } else {
    // Try to uninstall all known cckit plugins (not just marketplace ones, but any that might be installed)
    targets = available;
  }

  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log(`${CYAN}  cckit — Uninstalling plugins${NC}`);
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log('');

  let success = 0;
  let fail = 0;

  for (const name of targets) {
    log(`${CYAN}→ Uninstalling ${name}...${NC}`);
    try {
      run(`claude plugin uninstall ${name}@${MARKETPLACE_NAME} --scope user`, { stdio: 'pipe' });
      log(`${GREEN}✓${NC} ${name} uninstalled`);
      success++;
    } catch (err) {
      const msg = (err.stderr || err.message || '').toString();
      // "not installed" is not really a failure
      if (msg.includes('not installed') || msg.includes('not found')) {
        log(`${YELLOW}⚠${NC} ${name} was not installed`);
        success++;
      } else {
        log(`${RED}✗${NC} ${name}: ${msg.trim()}`);
        fail++;
      }
    }
  }

  // If all plugins uninstalled, offer to remove marketplace
  if (success === targets.length && isMarketplaceRegistered()) {
    log('');
    log(`${YELLOW}All cckit plugins uninstalled.${NC}`);
    log(`To remove the marketplace, run: claude plugin marketplace remove ${MARKETPLACE_NAME}`);
  }

  log('');
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
  log(`  Complete: ${success} uninstalled, ${fail} failed`);
  log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
}

function cmdList() {
  log(`${CYAN}─── cckit Plugins ───${NC}`);
  log('');

  // Check marketplace
  const mkt = readJSON(KNOWN_MARKETPLACES);
  const mktEntry = mkt?.[MARKETPLACE_NAME];
  const mktPath = mktEntry?.path || mktEntry?.installLocation || 'unknown';
  log(`Marketplace "cckit": ${check(registered, registered ? `registered → ${mktPath}` : 'not registered')}`);

  if (registered) {
    const kf = readJSON(KNOWN_MARKETPLACES);
    if (kf && kf[MARKETPLACE_NAME]) {
      const mktPath = kf[MARKETPLACE_NAME].path || kf[MARKETPLACE_NAME];
      log(`  Source: ${typeof mktPath === 'string' ? mktPath : JSON.stringify(mktPath)}`);
    }
  }
  log('');

  // List plugins from marketplace
  const marketplacePlugins = getMarketplacePlugins();
  if (marketplacePlugins.length === 0) {
    warn('No plugins found in marketplace.json');
    return;
  }

  // Try to read installed plugin info from the plugin cache
  for (const name of marketplacePlugins) {
    const cacheDir = path.join(os.homedir(), '.claude', 'plugins', 'cache', 'cckit', name);
    const installed = fs.existsSync(cacheDir);

    // Try to find version from installed plugin.json
    let version = '—';
    if (installed) {
      try {
        const versions = fs.readdirSync(cacheDir);
        if (versions.length > 0) {
          const pluginJson = path.join(cacheDir, versions[0], '.claude-plugin', 'plugin.json');
          const pj = readJSON(pluginJson);
          if (pj && pj.version) version = pj.version;
        }
      } catch { /* ignore */ }
    }

    // Read description from marketplace source
    let desc = '';
    try {
      const pluginJson = path.join(PKG_ROOT, 'hooks', name, '.claude-plugin', 'plugin.json');
      const altJson = path.join(PKG_ROOT, 'skills', name, '.claude-plugin', 'plugin.json');
      const pj = readJSON(fs.existsSync(pluginJson) ? pluginJson : altJson);
      if (pj && pj.description) desc = ` — ${pj.description}`;
    } catch { /* ignore */ }

    const status = installed ? `${GREEN}installed${NC}` : `${YELLOW}not installed${NC}`;
    log(`  ${CYAN}${name}${NC} ${version} [${status}]${desc}`);
  }

  log('');
}

function cmdUpdate(args) {
  if (!claudeExists()) {
    exit('Claude Code is not installed. Please install it first: https://claude.ai/code');
  }

  const plugins = resolvePlugins(args);
  if (plugins.length === 0) {
    exit('No valid plugins to update.');
  }

  log(`${CYAN}→ Updating cckit plugins...${NC}`);
  log('');

  for (const name of plugins) {
    log(`${CYAN}→ Updating ${name}...${NC}`);
    try {
      run(`claude plugin update ${name}@${MARKETPLACE_NAME} --scope user`, { stdio: 'pipe' });
      log(`${GREEN}✓${NC} ${name} updated`);
    } catch (err) {
      const msg = (err.stderr || err.message || '').toString();
      log(`${RED}✗${NC} ${name}: ${msg.trim()}`);
    }
  }

  log('');
  log('Tip: update the CLI itself with: npm update -g @suj1e/cckit');
}

function cmdInfo(name) {
  if (!name) {
    exit('Usage: cckit info <plugin-name>');
  }

  const available = getMarketplacePlugins();
  if (!available.includes(name)) {
    exit(`Unknown plugin "${name}". Available: ${available.join(', ')}`);
  }

  // Try to read from source
  let info = null;
  const sourcePaths = [
    path.join(PKG_ROOT, 'skills', name, '.claude-plugin', 'plugin.json'),
    path.join(PKG_ROOT, 'hooks', name, '.claude-plugin', 'plugin.json'),
  ];

  for (const p of sourcePaths) {
    if (fs.existsSync(p)) {
      info = readJSON(p);
      break;
    }
  }

  if (!info) {
    exit(`Plugin metadata not found for "${name}".`);
  }

  log(`${CYAN}─── ${name} ───${NC}`);
  log(`  Name:        ${info.name || name}`);
  log(`  Version:     ${info.version || '—'}`);
  log(`  Description: ${info.description || '—'}`);
  if (info.author) {
    log(`  Author:      ${info.author.name || info.author || '—'}`);
  }
  log(`  License:     ${info.license || '—'}`);

  // Show hooks if applicable
  if (info.hooks) {
    log(`  Hook Events: ${Object.keys(info.hooks).join(', ')}`);
  }

  // Show plugin type
  if (info.keywords && info.keywords.length > 0) {
    log(`  Keywords:    ${info.keywords.join(', ')}`);
  }

  log('');

  // Check installation status
  const cacheDir = path.join(os.homedir(), '.claude', 'plugins', 'cache', 'cckit', name);
  if (fs.existsSync(cacheDir)) {
    log(`  Status: ${GREEN}installed${NC}`);
  } else {
    log(`  Status: ${YELLOW}not installed${NC}`);
    log(`  Install: npx @suj1e/cckit install ${name}`);
  }
}

// ── Main ─────────────────────────────────────────────────────────────────────

function main() {
  const args = process.argv.slice(2);
  const cmd = args[0] || 'install';
  const rest = args.slice(1);

  switch (cmd) {
    case 'install':
    case 'i':
      cmdInstall(rest);
      break;
    case 'uninstall':
    case 'remove':
    case 'rm':
      cmdUninstall(rest);
      break;
    case 'list':
    case 'ls':
      cmdList();
      break;
    case 'update':
    case 'up':
      cmdUpdate(rest);
      break;
    case 'info':
      cmdInfo(rest[0]);
      break;
    case '--help':
    case '-h':
    case 'help':
      log(`cckit — Claude Code Kit CLI

Usage: cckit <command> [args]

Commands:
  install [name]    Install all plugins or a specific one (default)
  uninstall [name]  Uninstall all plugins or a specific one
  list              List all cckit plugins and their status
  update [name]     Update plugins to latest from marketplace
  info <name>       Show plugin metadata

Examples:
  npx @suj1e/cckit                     # Install all plugins
  npx @suj1e/cckit install barnhk       # Install barnhk only
  cckit list                            # Show installed plugins
  cckit info barnhk                     # Show barnhk details
`);
      break;
    default:
      error(`Unknown command: ${cmd}`);
      log('Usage: cckit [install|uninstall|list|update|info] [args]');
      log('       cckit --help for more info');
      process.exit(1);
  }
}

main();
