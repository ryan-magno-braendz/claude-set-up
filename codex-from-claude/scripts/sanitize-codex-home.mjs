#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const homeDir = process.argv[2];

if (!homeDir) {
  console.error('Usage: node scripts/sanitize-codex-home.mjs <snapshot-home-dir>');
  process.exit(2);
}

const resolvedHome = path.resolve(homeDir);
const configPath = path.join(resolvedHome, 'config.toml');
const hooksPath = path.join(resolvedHome, 'hooks.json');
const sourceCodexHome = '/Users/gabrielmagno/.codex';
const placeholder = '__CODEX_HOME__';
const portableTextPattern = /\.(json|toml|md|sh|ps1|mjs|js|txt|rules)$/;

function readFile(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Required file missing: ${filePath}`);
  }
  return fs.readFileSync(filePath, 'utf8');
}

function writeFile(filePath, content) {
  fs.writeFileSync(filePath, content.endsWith('\n') ? content : `${content}\n`);
}

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }

  return files;
}

function replaceSourcePaths() {
  for (const filePath of walk(resolvedHome)) {
    const relativePath = path.relative(resolvedHome, filePath).replaceAll(path.sep, '/');
    if (!portableTextPattern.test(relativePath) && relativePath !== 'AGENTS.md') {
      continue;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    if (content.includes(sourceCodexHome)) {
      writeFile(filePath, content.replaceAll(sourceCodexHome, placeholder));
    }
  }
}

function stripTomlTrailingWhitespace() {
  for (const filePath of walk(resolvedHome)) {
    if (path.extname(filePath) !== '.toml') {
      continue;
    }

    const content = fs.readFileSync(filePath, 'utf8');
    const nextContent = content.replace(/[ \t]+$/gm, '');
    if (nextContent !== content) {
      writeFile(filePath, nextContent);
    }
  }
}

function sanitizeConfigToml() {
  const input = readFile(configPath).split(/\r?\n/);
  const output = [];
  let skippingSection = false;

  for (const line of input) {
    const section = line.match(/^\[([^\]]+)\]\s*$/);
    if (section) {
      const sectionName = section[1];
      skippingSection =
        sectionName === 'hooks.state' ||
        sectionName.startsWith('hooks.state.') ||
        sectionName.startsWith('projects."/Users/');
    }

    if (skippingSection) {
      continue;
    }

    if (/^notify\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notifications\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notification_condition\s*=/.test(line)) {
      continue;
    }

    if (/^\s*notification_method\s*=/.test(line)) {
      continue;
    }

    output.push(line.replaceAll(sourceCodexHome, placeholder));
  }

  writeFile(configPath, output.join('\n').replace(/\n{3,}/g, '\n\n'));
}

function commandMentionsNotification(command) {
  return /\bnotify\.sh\b|\bding\.sh\b/.test(command);
}

function sanitizeHooksJson() {
  const parsed = JSON.parse(readFile(hooksPath));
  const hooks = parsed.hooks ?? {};

  delete hooks.PermissionRequest;
  delete hooks.Notification;

  for (const [eventName, groups] of Object.entries(hooks)) {
    if (!Array.isArray(groups)) {
      continue;
    }

    hooks[eventName] = groups
      .map((group) => {
        const nextGroup = { ...group };
        nextGroup.hooks = (group.hooks ?? []).filter((hook) => {
          return !commandMentionsNotification(String(hook.command ?? ''));
        });
        return nextGroup;
      })
      .filter((group) => Array.isArray(group.hooks) && group.hooks.length > 0);
  }

  parsed.hooks = hooks;
  parsed._note = 'Generated from live ~/.codex. Notification hooks were intentionally removed for the Windows mirror.';

  writeFile(hooksPath, JSON.stringify(parsed, null, 2));
}

sanitizeHooksJson();
replaceSourcePaths();
stripTomlTrailingWhitespace();
sanitizeConfigToml();
