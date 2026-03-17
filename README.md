# ai-dev-scaffold

<div align="right">
  🌐 语言 / Language：
  <a href="#-中文">中文</a> |
  <a href="#-english">English</a>
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Shell Script](https://img.shields.io/badge/shell-bash-blue.svg)](init.sh)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## 🇨🇳 中文

> 🚀 一条命令，从混乱走向秩序——让 AI 永远不再「忘记你说过什么」。

### 是什么

`ai-dev-scaffold` 是一个单文件 Bash 脚本。你是否有过这种痛苦：给 AI 反复解释同一条规则，刚说完它就忘了？新开一个对话，项目上下文清零，从头再来？这个脚本就是为终结这种折磨而生的——**一次初始化，永久记忆**，让 Copilot 和 Claude 在整个项目生命周期中始终如一地听你的话。

**脚本会做什么：**

```
your-project/
├── .github/copilot-instructions.md   ← Copilot 自动加载（规则直接内联）
├── .ai/
│   ├── SUMMARY.md                    ← 单文件项目快照（≤80行，AI 每次新任务必读）
│   ├── mistakes.md                   ← 错误记忆（≤60行，防止重复犯错）
│   ├── tasks/history.md              ← 任务历史（≤40行，自动归档）
│   └── memory/*_archive.md           ← 归档存储
├── CLAUDE.md                         ← Claude 工作内存（<30行，极简入口）
├── .claude/
│   ├── rules/coding.md               ← 编码规则（分拆，按需加载）
│   ├── rules/workflow.md             ← 工作流规则
│   ├── rules/context.md              ← 上下文管理规则
│   └── commands/refresh.md          ← 上下文刷新命令
├── .vscode/settings.json             ← Copilot 指令文件绑定
├── architecture/ARCHITECTURE.md      ← 架构文档模板
├── docs_generated/README.md          ← AI 维护的文档
└── src/ tests/                       ← 源码 & 测试占位
```

### 核心机制

借鉴了 4 个 GitHub 高星项目的精华：

| 机制 | 来源 | 作用 |
|------|------|------|
| **上下文腐烂检测** (Context Rot) | [spec-driven-workflow](https://github.com/liatrio-labs/spec-driven-workflow) | AI 每条回复必须带 🟢AI/🔄AI/⚠️AI 标记，标记消失 = 规则失效，立即干预 |
| **澄清优先** | [copilot-instructions](https://github.com/SebastienDegodez/copilot-instructions) | 模糊需求强制先问后做，杜绝 AI 瞎猜 |
| **熔断器** (Circuit Breaker) | [claude-user-memory](https://github.com/VAMFI/claude-user-memory) | 修复最多 3 轮，超出强制停止并报告阻塞原因 |
| **CLAUDE.md 极简 + rules/ 分拆** | [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | 主入口 <30 行，规则模块化，越短越不容易被忽略 |

**三级上下文加载（按需，节省 token）：**

| 级别 | 文件 | 加载时机 |
|:---:|------|----------|
| L0 | `copilot-instructions.md` | 每轮自动 |
| L1 | `.ai/SUMMARY.md`、`.ai/mistakes.md` | 每个新任务 / bugfix |
| L2 | `architecture/`、`.ai/tasks/history.md` | 架构变更 / 查历史 |
| L3 | `.ai/memory/*_archive.md` | 仅用户指示时 |

### 快速开始

```bash
# 克隆工具
git clone https://github.com/your-org/ai-dev-scaffold.git
cd ai-dev-scaffold

# 进入你的项目目录
cd /path/to/your-project

# 初始化 AI 开发系统（默认项目名: my-project）
bash /path/to/ai-dev-scaffold/init.sh

# 指定项目名
bash /path/to/ai-dev-scaffold/init.sh my-awesome-app

# 完整参数
bash init.sh --project my-app --force   # 覆盖已有模板文件
bash init.sh --project my-app --dry-run # 预演，不写入任何文件
```

**或者直接下载单文件运行：**

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/ai-dev-scaffold/main/init.sh | bash -s -- my-project
```

### 参数说明

| 参数 | 简写 | 说明 |
|------|------|------|
| `--project NAME` | `-p` | 项目名称（默认: `my-project`） |
| `--force` | `-f` | 覆盖已存在的模板文件 |
| `--dry-run` | `-n` | 预演模式，仅打印动作，不写入 |
| `--help` | `-h` | 显示帮助 |

### 使用技巧

| 场景 | 做法 |
|------|------|
| AI 回复没有 🟢AI 标记 | 直接说「刷新规则」—— AI 会重新加载上下文 |
| AI 在同一个错误上反复兜圈 | 熔断器生效后 AI 会自动停止并报告，你只需处理阻塞点 |
| 切换新功能模块 | 建议开新会话，保持上下文干净 |
| 上下文文件超出行数上限 | AI 会自动将旧内容归档到 `.ai/memory/` |
| 想在 Claude Code 里用 | `CLAUDE.md` 已就绪，直接启动 `claude` 即可 |

### 与现有项目集成

脚本采用**非破坏性写入**：若文件已存在，默认跳过（不覆盖）。加 `--force` 才会覆盖。`.gitignore` 条目采用追加而非替换。

### 兼容性

| 工具 | 状态 |
|------|------|
| GitHub Copilot (VS Code) | ✅ 完整支持 |
| Claude Code (Anthropic) | ✅ 完整支持 |
| Cursor | ✅ 兼容（`.cursor/rules/` 可手动映射） |
| Windsurf | ✅ 兼容 |

### 贡献

欢迎 PR 和 Issue！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

### License

[MIT](LICENSE) © 2025

<div align="right"><a href="#ai-dev-scaffold">↑ 回到顶部</a></div>

---

## 🇺🇸 English

> 🚀 One command to go from chaos to order — so your AI never "forgets what you told it" again.

### What is it

`ai-dev-scaffold` is a single-file Bash script. You know the pain: you explain the same rule to your AI, it nods along — then forgets it the moment a new chat starts. Context wiped. Back to square one. This script exists to end that torture. **Initialize once, remember forever.** Copilot and Claude will follow your rules consistently for the entire project lifecycle — no more repetition, no more guessing.

**What the script generates:**

```
your-project/
├── .github/copilot-instructions.md   ← Auto-loaded by Copilot (rules inlined)
├── .ai/
│   ├── SUMMARY.md                    ← Single-file project snapshot (≤80 lines, AI reads on every new task)
│   ├── mistakes.md                   ← Error memory (≤60 lines, prevents repeated mistakes)
│   ├── tasks/history.md              ← Task history (≤40 lines, auto-archived)
│   └── memory/*_archive.md           ← Archive storage
├── CLAUDE.md                         ← Claude working memory (<30 lines, minimal entry point)
├── .claude/
│   ├── rules/coding.md               ← Coding rules (modular, loaded on demand)
│   ├── rules/workflow.md             ← Workflow rules
│   ├── rules/context.md              ← Context management rules
│   └── commands/refresh.md          ← Context refresh command
├── .vscode/settings.json             ← Copilot instruction file binding
├── architecture/ARCHITECTURE.md      ← Architecture document template
├── docs_generated/README.md          ← AI-maintained documentation
└── src/ tests/                       ← Source & test placeholders
```

### Core Mechanisms

Distilled from 4 high-star GitHub projects:

| Mechanism | Source | Purpose |
|-----------|--------|---------|
| **Context Rot Detection** | [spec-driven-workflow](https://github.com/liatrio-labs/spec-driven-workflow) | Every AI reply must include 🟢AI/🔄AI/⚠️AI markers; missing markers = rules forgotten, intervene immediately |
| **Clarify First** | [copilot-instructions](https://github.com/SebastienDegodez/copilot-instructions) | Ambiguous requirements must be questioned before action, preventing AI guessing |
| **Circuit Breaker** | [claude-user-memory](https://github.com/VAMFI/claude-user-memory) | Max 3 fix attempts; beyond that, AI halts and reports the blocker |
| **Minimal CLAUDE.md + rules/ split** | [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) | Main entry <30 lines, modular rules — shorter = harder to ignore |

**Three-tier context loading (on-demand, saves tokens):**

| Level | File | When Loaded |
|:---:|------|-------------|
| L0 | `copilot-instructions.md` | Every turn, automatically |
| L1 | `.ai/SUMMARY.md`, `.ai/mistakes.md` | Each new task / bugfix |
| L2 | `architecture/`, `.ai/tasks/history.md` | Architecture changes / history lookup |
| L3 | `.ai/memory/*_archive.md` | Only when explicitly instructed |

### Quick Start

```bash
# Clone the tool
git clone https://github.com/your-org/ai-dev-scaffold.git
cd ai-dev-scaffold

# Navigate to your project directory
cd /path/to/your-project

# Initialize the AI development system (default project name: my-project)
bash /path/to/ai-dev-scaffold/init.sh

# Specify a project name
bash /path/to/ai-dev-scaffold/init.sh my-awesome-app

# Full options
bash init.sh --project my-app --force   # Overwrite existing template files
bash init.sh --project my-app --dry-run # Dry run — print actions without writing
```

**Or download and run the single file directly:**

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/ai-dev-scaffold/main/init.sh | bash -s -- my-project
```

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--project NAME` | `-p` | Project name (default: `my-project`) |
| `--force` | `-f` | Overwrite existing template files |
| `--dry-run` | `-n` | Dry run mode — print actions only, no writes |
| `--help` | `-h` | Show help |

### Tips

| Scenario | Action |
|----------|--------|
| AI reply missing 🟢AI marker | Say "refresh rules" — AI reloads its context |
| AI looping on the same error | Circuit breaker fires; AI halts and reports — just fix the blocker |
| Switching to a new feature module | Open a new session to keep context clean |
| Context file exceeds line limit | AI automatically archives old content to `.ai/memory/` |
| Using with Claude Code | `CLAUDE.md` is ready — just launch `claude` |

### Integrating with Existing Projects

The script uses **non-destructive writes**: if a file already exists, it is skipped by default (no overwrite). Use `--force` to overwrite. `.gitignore` entries are appended, not replaced.

### Compatibility

| Tool | Status |
|------|--------|
| GitHub Copilot (VS Code) | ✅ Full support |
| Claude Code (Anthropic) | ✅ Full support |
| Cursor | ✅ Compatible (`.cursor/rules/` can be manually mapped) |
| Windsurf | ✅ Compatible |

### Contributing

PRs and Issues are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

### License

[MIT](LICENSE) © 2025

<div align="right"><a href="#ai-dev-scaffold">↑ Back to top</a></div>
