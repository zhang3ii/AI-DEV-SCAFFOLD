#!/bin/bash
# ================================================
# ai-dev-scaffold — AI 开发系统初始化脚本
# Version: 1.0.0
# License: MIT
# Repository: https://github.com/your-org/ai-dev-scaffold
#
# 融合 GitHub 高星项目最佳实践:
#   • shanraisshan/claude-code-best-practice (17.5k⭐) → 规则分拆/compact策略/subagent
#   • liatrio-labs/spec-driven-workflow (66⭐)         → 上下文腐烂检测标记
#   • VAMFI/claude-user-memory (163⭐)                → 质量门控 + 熔断机制
#   • SebastienDegodez/copilot-instructions (161⭐)   → 模块化指令 + 澄清强制
#
# 核心特性:
#   ✅ 上下文腐烂检测 (Context Rot Detection) — emoji 标记证明 AI 在遵守规则
#   ✅ 三级上下文加载 (Tiered Context)        — 永远加载/按需加载/归档
#   ✅ 质量门控 (Quality Gates)                — 阶段性通过标准
#   ✅ 熔断器 (Circuit Breaker)               — 最多 N 轮重试后停止报告
#   ✅ 渐进式披露 (Progressive Disclosure)    — 不一次性 dump 所有上下文
#   ✅ 规则分拆 (.claude/rules/)              — CLAUDE.md 保持精简，规则模块化
#   ✅ 上下文压缩策略                          — 50% 使用量时主动 compact
#
# 用法:
#   bash init.sh [项目名称]
#   bash init.sh --project my-app [--force] [--dry-run]
# ================================================

set -euo pipefail

PROJECT_NAME="my-project"
FORCE_OVERWRITE="false"
DRY_RUN="false"

if [[ $# -gt 0 && "${1:-}" != "-"* ]]; then
    PROJECT_NAME="$1"
    shift
fi

usage() {
    cat << 'USAGE_EOF'
用法:
    bash init.sh [项目名称]
    bash init.sh --project my-app [--force] [--dry-run]

参数:
    -p, --project NAME   指定项目名称（默认: my-project）
    -f, --force          覆盖已存在的模板文件
    -n, --dry-run        仅打印将执行的动作，不写入文件
    -h, --help           显示帮助
USAGE_EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--project)
            if [[ $# -lt 2 ]]; then
                echo "❌ 参数错误: --project 需要一个值" >&2; exit 1
            fi
            PROJECT_NAME="$2"; shift 2 ;;
        -f|--force)   FORCE_OVERWRITE="true"; shift ;;
        -n|--dry-run) DRY_RUN="true"; shift ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "❌ 未知参数: $1" >&2; usage; exit 1 ;;
    esac
done

DATE="$(date +%Y-%m-%d)"

log() { echo "$1"; }

write_file() {
    local target="$1"
    if [[ -f "${target}" && "${FORCE_OVERWRITE}" != "true" ]]; then
        log "⏭️  跳过: ${target}"; cat >/dev/null; return
    fi
    if [[ "${DRY_RUN}" == "true" ]]; then
        log "🧪 [dry-run] ${target}"; cat >/dev/null; return
    fi
    cat > "${target}"
    log "📝 已写入: ${target}"
}

append_if_missing() {
    local target="$1" line="$2"
    if [[ "${DRY_RUN}" == "true" ]]; then return; fi
    if ! grep -Fxq "${line}" "${target}" 2>/dev/null; then
        echo "${line}" >> "${target}"
    fi
}

log "🚀 初始化 AI 开发系统: ${PROJECT_NAME}"
log "=================================="
[[ "${FORCE_OVERWRITE}" == "true" ]] && log "⚠️  覆盖模式"
[[ "${DRY_RUN}" == "true" ]] && log "🧪 预演模式"

# ---- 创建目录 ----
for dir in .github .ai/memory .ai/tasks .claude/commands .claude/rules .vscode architecture docs_generated src tests; do
    if [[ "${DRY_RUN}" != "true" ]]; then mkdir -p "${dir}"; fi
done
log "📁 目录已准备"

# ================================================================
# 核心文件 1: copilot-instructions.md
# 【设计哲学】
#   借鉴 spec-driven-workflow 的"上下文验证标记"
#   借鉴 VAMFI 的"质量门控 + 熔断器"
#   借鉴 SebastienDegodez 的"澄清问题强制"
#   规则直接内联 → AI 永远无法"忘记"
# ================================================================
write_file .github/copilot-instructions.md << 'COPILOT_EOF'
# AI 开发系统 — 主指令 (Auto-loaded)

> ⚡ 本文件每轮对话自动加载。关键规则已内联，无需额外读取。

---

## § 0 — 上下文腐烂检测 (Context Rot Detection)

**每次回复开头必须包含状态标记**，证明你仍在遵守规则：

- `🟢AI` — 正常状态，规则已加载
- `🔄AI` — 上下文已刷新（重读后使用）
- `⚠️AI` — 有阻塞问题需要用户决策

**如果用户发现回复没有标记** → 说明上下文已腐烂，立即说"刷新规则"。
**每 10 轮对话** → 主动重读本文件 + `.ai/SUMMARY.md`，使用 `🔄AI` 标记。
**收到新任务时** → 读取 `.ai/SUMMARY.md`（≤80行），用 `🟢AI` 开头回复。

---

## § 1 — 澄清优先 (Clarify Before Code)

**收到模糊需求时，必须先问澄清问题，不可直接编码。**
至少确认：
1. 预期行为是什么？
2. 边界情况如何处理？
3. 是否有现有代码需要兼容？

小而明确的任务可跳过此步骤。

---

## § 2 — 内联编码规则 (始终生效)

**代码质量**
- 代码必须可运行，优先标准库
- 函数 ≤50行，嵌套 ≤3层
- 不硬编码密钥/密码，用户输入必须验证

**命名**
- Python: snake_case | JS/TS: camelCase | 类: PascalCase | 常量: UPPER_SNAKE_CASE

**架构**
- src/ → 源码 | tests/ → 测试 | docs_generated/ → 文档
- 单一职责，禁止循环依赖，配置走环境变量

**测试**
- 核心逻辑必须有测试 | 文件名: test_*.py 或 *.test.ts

**Git**
- feat/fix/refactor/docs/test/chore(scope): subject

---

## § 3 — 质量门控工作流 (Quality-Gated Workflow)

| 阶段 | 角色 | 动作 | 通过标准 | 小任务可跳过 |
|------|------|------|----------|:---:|
| 1. 澄清 | PM | 问澄清问题 + 验收标准 | 需求无歧义 | ✅ |
| 2. 调研 | Research | 查历史错误 + 可行性 | 无已知阻塞 | ✅ |
| 3. 设计 | Architect | 模块/接口设计 | 方案可解释 | ✅ |
| 4. 开发 | Developer | 编码 + 单元测试 | 代码可运行 | ❌ |
| 5. 验证 | Tester | build + run + test | 全部通过 | ❌ |
| 6. 修复 | Debugger | 修复循环 | 问题已解决 | ❌ |
| 7. 同步 | — | 更新 SUMMARY + 文档 | 记忆已更新 | ❌ |

**🔴 熔断器：修复循环最多 3 轮。第 3 轮仍失败 → 停止，报告阻塞原因，等待用户决策。**

---

## § 3.5 — 上下文健康管理 (Context Hygiene)

**避免 Agent Dumb Zone（上下文超载导致 AI 变笨）：**
- 感觉上下文过长时 → 主动压缩/总结之前的对话
- 切换到全新任务时 → 建议用户开新会话，而不是在旧会话继续
- 复杂子任务 → 建议用 subagent 隔离上下文，保持主线干净

**任务拆分原则：**
- 小任务 → 直接做（vanilla，不需要复杂工作流）
- 中任务 → plan → implement → verify
- 大任务 → 拆成多个独立子任务，每个子任务在干净上下文中执行

---

## § 4 — 三级上下文加载 (Tiered Context Loading)

| 级别 | 文件 | 何时加载 | 最大行数 |
|:---:|------|----------|:---:|
| L0 | 本文件 (copilot-instructions.md) | 每轮自动 | — |
| L1 | `.ai/SUMMARY.md` | 每个新任务 | 80 |
| L1 | `.ai/mistakes.md` | 做 bugfix 时 | 60 |
| L2 | `architecture/ARCHITECTURE.md` | 做架构变更时 | — |
| L2 | `.ai/tasks/history.md` | 需要查历史时 | 40 |
| L3 | `.ai/memory/*_archive.md` | 仅用户指示时 | — |

**永远不要一次性读取所有文件。按需、分级加载。**

---

## § 5 — 上下文预算 (Context Budget)

| 文件 | 上限 | 超限动作 |
|------|:---:|------|
| `.ai/SUMMARY.md` | 80 行 | 压缩旧条目，保留最近 5 条决策 |
| `.ai/mistakes.md` | 60 行 | 归档到 `.ai/memory/mistakes_archive.md` |
| `.ai/tasks/history.md` | 40 行 | 归档到 `.ai/memory/tasks_archive.md` |

**写入记忆文件前，先检查行数。超限 → 先归档旧条目 → 再写入新条目。**

---

## § 6 — 禁止行为

- ❌ 模糊需求直接编码（必须先澄清）
- ❌ 跳过验证直接交付
- ❌ 修改代码后不同步 SUMMARY.md
- ❌ 创建 _backup/_v2 等冗余文件
- ❌ 重复 `.ai/mistakes.md` 中的已知错误
- ❌ 修复超过 3 轮不报告阻塞
- ❌ 回复不带状态标记 (🟢AI/🔄AI/⚠️AI)
COPILOT_EOF

# ================================================================
# 核心文件 2: .ai/SUMMARY.md — 单文件项目快照
# 【设计哲学】
#   借鉴 VAMFI 的 Knowledge Graph — 结构化 key-value 而非冗长 Markdown
#   AI 只需读这一个文件即可获取全部上下文
# ================================================================
write_file .ai/SUMMARY.md << SUMMARY_EOF
# 项目快照 (Single Source of Context) — 上限80行

> AI 每次新任务只需读本文件。超限时压缩旧内容。

## 项目信息
- 名称: $PROJECT_NAME
- 阶段: 初始化
- 技术栈: [待定]
- 主入口: [待定]
- 更新: $DATE

## 架构概要
[用 1-3 句话描述，开发时自动填写]

## 关键依赖
[格式: 包名@版本 — 用途]

## 最近决策 (保留最近5条，旧的归档到 memory/decisions_archive.md)
| # | 日期 | 决策 | 原因 |
|---|------|------|------|

## 当前任务
[无]

## 已知风险/约束
[无]
SUMMARY_EOF

# ================================================================
# 记忆文件 — 带预算控制
# ================================================================

# ---- .ai/mistakes.md (上限60行) ----
write_file .ai/mistakes.md << 'MISTAKES_EOF'
# 错误记忆 (上限60行 → 超限归档到 memory/mistakes_archive.md)

> 格式: [日期] 错误描述 → 正确做法

MISTAKES_EOF

# ---- .ai/tasks/history.md (上限40行) ----
write_file .ai/tasks/history.md << 'HISTORY_EOF'
# 任务历史 (上限40行 → 超限归档到 memory/tasks_archive.md)

> 格式: [日期] 任务摘要 | 状态

HISTORY_EOF

# ---- .ai/memory/ 归档文件(空占位) ----
write_file .ai/memory/mistakes_archive.md << 'EOF'
# 错误归档 (从 mistakes.md 溢出的旧条目)
EOF

write_file .ai/memory/tasks_archive.md << 'EOF'
# 任务归档 (从 history.md 溢出的旧条目)
EOF

write_file .ai/memory/decisions_archive.md << 'EOF'
# 决策归档 (从 SUMMARY.md 溢出的旧决策)
EOF

# ================================================================
# Claude 支持文件 — 融合 VAMFI 的 Research→Plan→Implement→Learn
# ================================================================

# ---- CLAUDE.md (< 30行，规则分拆到 .claude/rules/) ----
# Boris Cherny (Claude Code 创建者) 推荐: CLAUDE.md < 200行，越短越好
write_file CLAUDE.md << 'CLAUDE_EOF'
# Claude Working Memory

## Boot
1. Read `.ai/SUMMARY.md` (≤80 lines)
2. Bugfix → also read `.ai/mistakes.md`
3. Respond with 🟢AI marker

## Gates
- Clarify → Implement → Verify → max 3 fix rounds → STOP if stuck (⚠️AI)

## Context Hygiene
- 🟢AI / 🔄AI / ⚠️AI marker on every response
- New task → start fresh session when possible
- Complex subtask → use subagent to isolate context
- Context feels heavy → compact/summarize proactively

## Core Rules
- Small diffs, verify before deliver
- Update `.ai/SUMMARY.md` after code changes
- No _backup/_v2 files
- See `.claude/rules/` for detailed rules
CLAUDE_EOF

# ---- .claude/rules/ 分拆规则 (Boris推荐: 用 rules/ 拆分大指令) ----
write_file .claude/rules/coding.md << 'RULES_CODING_EOF'
# Coding Rules
- Code must be runnable, prefer stdlib
- Functions ≤50 lines, nesting ≤3 levels
- No hardcoded secrets, validate all user input
- Python: snake_case | JS/TS: camelCase | Class: PascalCase | Const: UPPER_SNAKE
RULES_CODING_EOF

write_file .claude/rules/workflow.md << 'RULES_WORKFLOW_EOF'
# Workflow Rules
- Small task → just do it (no overhead)
- Medium task → plan → implement → verify
- Large task → split into subtasks, each in clean context
- Always verify before delivering
- Max 3 fix loops, then report blocker
RULES_WORKFLOW_EOF

write_file .claude/rules/context.md << 'RULES_CONTEXT_EOF'
# Context Management Rules
- SUMMARY.md ≤ 80 lines → compress old entries
- mistakes.md ≤ 60 lines → archive to memory/
- history.md ≤ 40 lines → archive to memory/
- Switch tasks → suggest new session
- Heavy context → compact proactively
RULES_CONTEXT_EOF

# ---- .claude/commands/refresh.md (上下文刷新) ----
write_file .claude/commands/refresh.md << 'CMD_REFRESH_EOF'
# Context Refresh (上下文刷新)

当上下文腐烂时使用。重新加载核心文件并报告状态。

## Steps
1. Read `.ai/SUMMARY.md`
2. Read `.ai/mistakes.md`
3. Read `.github/copilot-instructions.md` §2 rules section
4. Output: "🔄AI Context reloaded. 项目: [名称] | 阶段: [阶段] | 当前任务: [任务]"
CMD_REFRESH_EOF

# ================================================================
# 项目结构文件
# ================================================================

write_file architecture/ARCHITECTURE.md << 'ARCH_EOF'
# 项目架构

## 总览
[初始化时填写]

## 模块
| 模块 | 职责 | 入口 |
|------|------|------|

## 技术选型
| 领域 | 选择 | 理由 |
|------|------|------|
ARCH_EOF

write_file docs_generated/README.md << README_EOF
# $PROJECT_NAME

## 快速开始
[开发后自动填写]

## 结构
[开发后自动填写]

---
*更新: $DATE*
README_EOF

# ---- .vscode/settings.json (可选: 推荐 Copilot 配置) ----
write_file .vscode/settings.json << 'VSCODE_EOF'
{
    "github.copilot.chat.codeGeneration.instructions": [
        { "file": ".github/copilot-instructions.md" }
    ]
}
VSCODE_EOF

# ---- .gitignore ----
if [[ ! -f .gitignore ]]; then
    write_file .gitignore << 'GITIGNORE_EOF'
__pycache__/
*.pyc
.env
node_modules/
.DS_Store
GITIGNORE_EOF
else
    for rule in "__pycache__/" "*.pyc" ".env" "node_modules/" ".DS_Store"; do
        append_if_missing .gitignore "${rule}"
    done
fi

# ---- 完成 ----
log ""
log "✅ AI 开发系统初始化完成！(v1.0.0 — 融合 17.5k⭐ 最佳实践)"
log ""
log "📂 文件结构："
log "  .github/copilot-instructions.md  ← Copilot 自动加载，规则内联"
log "  .ai/SUMMARY.md                   ← 单文件快照（≤80行）"
log "  .ai/mistakes.md                  ← 错误记忆（≤60行）"
log "  .ai/tasks/history.md             ← 任务历史（≤40行）"
log "  .ai/memory/*_archive.md          ← 归档存储"
log "  CLAUDE.md                        ← Claude 入口（<30行，极简）"
log "  .claude/rules/coding.md          ← 编码规则（分拆）"
log "  .claude/rules/workflow.md        ← 工作流规则（分拆）"
log "  .claude/rules/context.md         ← 上下文管理规则（分拆）"
log "  .claude/commands/refresh.md      ← 上下文刷新命令"
log "  .vscode/settings.json            ← Copilot 配置"
log "  architecture/ARCHITECTURE.md     ← 架构文档"
log "  docs_generated/README.md         ← 自动维护"
log "  src/ tests/                      ← 代码 & 测试"
log ""
log "🔑 核心优化（来源）："
log "  1. 🟢 上下文腐烂检测 — AI回复带标记，消失=规则失效 (spec-driven-workflow)"
log "  2. ❓ 澄清优先 — 模糊需求先问后做 (copilot-instructions)"
log "  3. 🔴 熔断器 — 修复最多3轮 (claude-user-memory)"
log "  4. 📏 CLAUDE.md <30行 + rules/分拆 — 越短越不容易被忽略 (claude-code-best-practice)"
log "  5. 🧹 上下文健康管理 — 切任务开新会话/复杂用subagent (claude-code-best-practice)"
log "  6. 📊 三级上下文 + 预算制 — 按需加载，自动归档"
log ""
log "💡 使用技巧："
log "  • AI 回复没 🟢AI 标记 → 说\"刷新规则\""
log "  • AI 不断重试同一错误  → 熔断器 3 轮后自动停止"
log "  • 上下文文件太长       → 自动归档"
log "  • 切换新任务时         → 建议开新会话（保持上下文干净）"
