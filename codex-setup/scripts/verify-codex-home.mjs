#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';

const homeDir = process.argv[2];

if (!homeDir) {
  console.error('Usage: node scripts/verify-codex-home.mjs <snapshot-home-dir>');
  process.exit(2);
}

const root = path.resolve(homeDir);
const requiredPaths = [
  'AGENTS.md',
  'config.toml',
  'hooks.json',
  'agents',
  'hooks',
  'skills',
  'rules',
  'memory',
  'reference',
  'get-shit-done',
  'plugins/cache',
  '.tmp/bundled-marketplaces/openai-bundled',
];

const forbiddenRelativePaths = [
  '.env',
  'auth.json',
  'history.jsonl',
  'installation_id',
  'log',
  'logs',
  'logs_2.sqlite',
  'logs_2.sqlite-shm',
  'logs_2.sqlite-wal',
  'sessions',
  'shell_snapshots',
  'sqlite',
  'state_5.sqlite',
  'state_5.sqlite-shm',
  'state_5.sqlite-wal',
  'tmp',
];

const forbiddenGlobalText = ['/Users/gabrielmagno/.codex'];
const forbiddenRuntimeNotificationText = [
  'notify.sh',
  'PermissionRequest',
  'notification_method',
  'notification_condition',
];
const runtimeNotificationFiles = new Set(['config.toml', 'hooks.json']);

function exists(relativePath) {
  return fs.existsSync(path.join(root, relativePath));
}

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];

  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory() && entry.name === '.git') {
      failures.push(`Forbidden nested git repository present: ${path.relative(root, fullPath).replaceAll(path.sep, '/')}`);
      continue;
    }
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }

  return files;
}

const failures = [];

for (const relativePath of requiredPaths) {
  if (!exists(relativePath)) {
    failures.push(`Missing required path: ${relativePath}`);
  }
}

for (const relativePath of forbiddenRelativePaths) {
  if (exists(relativePath)) {
    failures.push(`Forbidden runtime or secret path present: ${relativePath}`);
  }
}

if (exists('.tmp')) {
  const allowedTmpPrefix = '.tmp/bundled-marketplaces/openai-bundled/';
  const tmpFiles = walk(path.join(root, '.tmp'));
  for (const filePath of tmpFiles) {
    const relativePath = path.relative(root, filePath).replaceAll(path.sep, '/');
    if (relativePath === '.tmp/bundled-marketplaces/openai-bundled' || relativePath.startsWith(allowedTmpPrefix)) {
      continue;
    }
    failures.push(`Forbidden runtime .tmp path present: ${relativePath}`);
  }
}

const textFiles = walk(root).filter((filePath) => {
  const relativePath = path.relative(root, filePath).replaceAll(path.sep, '/');
  return /\.(json|toml|md|sh|ps1|mjs|js|txt|rules)$/.test(relativePath) || relativePath === 'AGENTS.md';
});

for (const filePath of textFiles) {
  const relativePath = path.relative(root, filePath).replaceAll(path.sep, '/');
  const content = fs.readFileSync(filePath, 'utf8');

  for (const text of forbiddenGlobalText) {
    if (content.includes(text)) {
      failures.push(`Forbidden text "${text}" found in ${relativePath}`);
    }
  }

  const isRuntimeNotificationFile =
    runtimeNotificationFiles.has(relativePath) || relativePath.startsWith('hooks/');

  if (!isRuntimeNotificationFile) {
    continue;
  }

  for (const text of forbiddenRuntimeNotificationText) {
    if (content.includes(text)) {
      failures.push(`Forbidden runtime notification text "${text}" found in ${relativePath}`);
    }
  }
}

if (failures.length > 0) {
  console.error('Codex home snapshot verification failed:');
  for (const failure of failures) {
    console.error(`- ${failure}`);
  }
  process.exit(1);
}

console.log(`Verified Codex home snapshot: ${root}`);
