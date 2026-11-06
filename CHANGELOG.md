# CHANGELOG

版本规则：
- **主版本 +1**：删规则、改结构、改分层（会让人按旧习惯做错事）
- **次版本 +1**：加规则、加模板、加角色
- **修订 +1**：改措辞、修数字、补例子（不影响"该怎么做"）

---

## v1.0.0 — 2026-11-06

首次发布。内容来自一个真实项目：15 天、198 次提交、30 轮对话、28 条错因。
用户全程只输入 2,488 个字，产出 5.6 万行代码变更与一套可复用资产。

### core/（方法与规则）
- `种子提示词.txt` — 400 字纯文本，粘给任何 AI 助手即生效，是保底层
- `规则-30条.md` — 按六场景速查（验证 / 数据 / UI / 外部服务 / 协作 / 环境）+ 附录 A 并行编排 PA1–PA4
- `提问模板.md` — Spec 门禁的操作化版本，含"有效提问 vs 无效提问"对照
- `反例库.md` — 12 个决策前的自问，每个配一次真实后果

### templates/（新项目直接拷）
- `CLAUDE.md.template` — 常驻层正文（WorkBuddy / Claude Code）
- `AGENTS.md.template` — 入口引导页（Codex 及任何工具）
- `spec.md.template`、`DECISIONS.md.example`、`MISTAKE-LOG.md.template`
- `DoD-验收清单.md`、`每日三问.md`、`new-project.sh`

### skill/（WorkBuddy 技能）
- 可在 WorkBuddy 里一句话唤起；`install.sh --with-skill` 安装

### codex/（Codex 子代理配置示例）
- `config.toml.example` + `agents/{explorer,worker,reviewer}.toml`
- 把「临场决定开几个分身」变成「配置文件说死」
- 字段名以官方文档为准，`instructions` 的内容不受版本影响

### install.sh
- 铺模板到目标项目，不覆盖已存在文件；`--dry-run` 预览；`--with-skill` 附带装技能

### 为什么是 v1.0.0 而不是 v0.x
因为这版已经"能独立用"：clone 下来 → `install.sh` → 能按同一套规矩干活。
不成熟的部分（并发上限、答案质量抽检、门禁收益）在项目源仓库里标了「待证」，不吹成结论。
