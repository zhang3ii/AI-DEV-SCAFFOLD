# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] — 2025-03-17

### Added
- 初始版本发布
- 核心脚本 `init.sh`，支持 `--project`、`--force`、`--dry-run` 参数
- `copilot-instructions.md` — GitHub Copilot 自动加载主指令（规则内联）
- `.ai/SUMMARY.md` — 单文件项目快照（≤80行预算控制）
- `.ai/mistakes.md` — 错误记忆（≤60行）
- `.ai/tasks/history.md` — 任务历史（≤40行）
- `CLAUDE.md` — Claude Code 极简入口（<30行）
- `.claude/rules/` — 模块化规则分拆（coding / workflow / context）
- `.claude/commands/refresh.md` — 上下文刷新命令
- `.vscode/settings.json` — Copilot 指令绑定
- `architecture/` 和 `docs_generated/` 文档模板
- 上下文腐烂检测机制（🟢AI/🔄AI/⚠️AI 标记）
- 熔断器机制（最多 3 轮修复循环）
- 三级上下文加载（L0/L1/L2/L3）

### Credits
- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) — 规则分拆策略
- [liatrio-labs/spec-driven-workflow](https://github.com/liatrio-labs/spec-driven-workflow) — 上下文腐烂检测
- [VAMFI/claude-user-memory](https://github.com/VAMFI/claude-user-memory) — 质量门控 + 熔断器
- [SebastienDegodez/copilot-instructions](https://github.com/SebastienDegodez/copilot-instructions) — 模块化指令
