## 改动内容

<!-- 简短描述这个 PR 做了什么 -->

## 类型

- [ ] Bug 修复
- [ ] 新功能
- [ ] 模板优化（copilot-instructions / CLAUDE.md 等）
- [ ] 文档更新
- [ ] 重构

## 测试步骤

```bash
# 如何验证这个 PR 的改动
mkdir /tmp/pr-test && cd /tmp/pr-test
bash /path/to/init.sh test-project --dry-run
bash /path/to/init.sh test-project
# 验证结果...
```

## 检查清单

- [ ] 脚本通过 `bash -n init.sh` 语法检查
- [ ] 通过 shellcheck（或说明豁免原因）
- [ ] 更新了 `CHANGELOG.md`
- [ ] README 若有行为变化已同步
