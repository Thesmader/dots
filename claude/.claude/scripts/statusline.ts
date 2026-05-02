#!/usr/bin/env bun

import { execSync } from "child_process";

// ANSI colors
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const BLUE = "\x1b[34m";
const GRAY = "\x1b[90m";
const RESET = "\x1b[0m";

interface StdinData {
  cwd?: string;
  context_window?: {
    used_percentage?: number;
  };
}

async function readStdin(): Promise<StdinData | null> {
  if (process.stdin.isTTY) return null;
  const chunks: string[] = [];
  process.stdin.setEncoding("utf8");
  for await (const chunk of process.stdin) chunks.push(chunk as string);
  const raw = chunks.join("");
  if (!raw.trim()) return null;
  return JSON.parse(raw);
}

function getContextColor(percent: number): string {
  if (percent >= 80) return RED;
  if (percent >= 50) return YELLOW;
  return GREEN;
}

function renderContextBar(percent: number): string {
  const BAR_WIDTH = 20;
  const filled = Math.round((percent / 100) * BAR_WIDTH);
  const empty = BAR_WIDTH - filled;
  const color = getContextColor(percent);
  return `${color}${"█".repeat(filled)}${"░".repeat(empty)} ${percent}%${RESET}`;
}

function getAccessToken(): string | null {
  if (process.platform !== "darwin") return null;
  try {
    const data = execSync(
      '/usr/bin/security find-generic-password -s "Claude Code-credentials" -w',
      { encoding: "utf8", timeout: 3000, stdio: ["pipe", "pipe", "pipe"] }
    ).trim();
    const parsed = JSON.parse(data);
    return parsed.claudeAiOauth?.accessToken ?? null;
  } catch {
    return null;
  }
}

interface UsageData {
  utilization: number;
  timeLeft: string;
}

const CACHE_FILE = `${process.env.HOME}/.claude/scripts/.usage-cache.json`;
const CACHE_TTL_MS = 60_000;

function readCache(): UsageData | null {
  try {
    const raw = require("fs").readFileSync(CACHE_FILE, "utf8");
    const cached = JSON.parse(raw);
    if (Date.now() - cached.ts < CACHE_TTL_MS) return cached.data;
  } catch {}
  return null;
}

function writeCache(data: UsageData) {
  try {
    require("fs").writeFileSync(CACHE_FILE, JSON.stringify({ ts: Date.now(), data }));
  } catch {}
}

async function getUsage(token: string): Promise<UsageData | null> {
  const cached = readCache();
  if (cached) return cached;

  try {
    const res = await fetch("https://api.anthropic.com/api/oauth/usage", {
      headers: {
        Authorization: `Bearer ${token}`,
        "anthropic-beta": "oauth-2025-04-20",
      },
    });
    if (!res.ok) return null;
    const data = await res.json();
    const val = data.five_hour?.utilization;
    if (typeof val !== "number") return null;

    const resetAt = data.five_hour?.resets_at;
    let timeLeft = "";
    if (resetAt) {
      const msLeft = new Date(resetAt).getTime() - Date.now();
      if (msLeft > 0) {
        const mins = Math.floor(msLeft / 60000);
        const hrs = Math.floor(mins / 60);
        const m = mins % 60;
        timeLeft = hrs > 0 ? `${hrs}h ${m}m` : `${m}m`;
      }
    }
    const usage = { utilization: Math.round(val), timeLeft };
    writeCache(usage);
    return usage;
  } catch {
    return null;
  }
}

function getGitBranch(cwd?: string): string | null {
  try {
    return execSync("git branch --show-current", {
      cwd,
      encoding: "utf8",
      timeout: 1000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim() || null;
  } catch {
    return null;
  }
}

async function main() {
  const stdin = await readStdin();
  if (!stdin) {
    console.log("[statusline] init");
    return;
  }

  const parts: string[] = [];

  // Context bar (colored)
  const contextPct = stdin.context_window?.used_percentage ?? 0;
  parts.push(renderContextBar(contextPct));

  // Git branch (blue)
  const branch = getGitBranch(stdin.cwd);
  if (branch) parts.push(`${BLUE}git:${branch}${RESET}`);

  console.log(parts.join(" | "));
}

main();
