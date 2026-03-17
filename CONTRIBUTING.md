# Contributing to ai-dev-scaffold

感谢你有兴趣贡献！以下是参与指南。

## 提 Issue

- **Bug 报告**：请使用 [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) 模板
- **功能建议**：请使用 [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) 模板
- 提交前请先搜索是否有相同的 Issue

## 提 PR

1. Fork 本仓库，创建特性分支：`git checkout -b feat/your-feature`
2. 修改后在本地测试脚本：
   ```bash
   # 创建临时目录测试
   mkdir /tmp/test-scaffold && cd /tmp/test-scaffold
   bash /path/to/init.sh test-project --dry-run   # 先预演
   bash /path/to/init.sh test-project             # 再实际运行
   ls -la                                          # 验证生成文件
   ```
3. Commit 信息格式：`feat/fix/docs/refactor(scope): 简短描述`
4. 提交 PR，填写模板中的说明

## 贡献方向

| 类型 | 示例 |
|------|------|
| 新 AI 工具适配 | 为 Cursor / Windsurf 添加专属配置文件 |
| 模板优化 | 改进 `copilot-instructions.md` 或 `CLAUDE.md` 的规则 |
| 多语言文档 | 翻译 README 为其他语言 |
| 测试 | 添加 bats 单元测试 |
| Bug 修复 | 修复边界情况（特殊字符项目名、权限问题等） |

## 风格规范

- Shell 脚本遵循 `shellcheck` 无警告
- 中文注释优先，英文关键术语保留原文
- 不引入外部依赖（脚本只依赖 `bash` 标准工具）

## 行为准则

请保持友善、尊重，遵守 [Contributor Covenant](https://www.contributor-covenant.org/)。
