# ai-playbook · v1.0.0

一套经过实战检验的 AI 协作规矩。不是教程，是**能直接用的东西**：一份能粘贴的提示词、一份能安装的模板、一套能查的规则、一本反例。

来源：一个真实项目 15 天、198 次提交、30 轮对话、28 条错因。用户全程只输入 2,488 个字。

---

## 按你的工具选一层

| 工具 | 入口文件 | 怎么开始 |
|---|---|---|
| **Codex** | `AGENTS.md` | `sh install.sh <项目>` 会一并铺；子代理配置见 `codex/` |
| **Claude Code / WorkBuddy** | `CLAUDE.md` | 同上；WorkBuddy 可加 `--with-skill` |
| **Cursor** | `.cursor/rules/` | 把 `AGENTS.md` 内容拆成几条 mdc，或先只放一条"读 AGENTS.md" |
| **装不了东西 / 不能连网** | 无 | 复制 `core/种子提示词.txt` 全文，粘给任何 AI 助手 |

**核心设计：内容只有一份，载体有多个。** 换工具时只改入口文件名，不用重写方法。

---

## 两个入口文件的分工（别混）

| 文件 | 长度 | 放什么 | 谁读 |
|---|---|---|---|
| `AGENTS.md` | 约 30 行 | 三条铁律 + 开工前动作 + 交付要求 + **"更细的规则去哪找"的指针** | Codex 每次全文读 |
| `CLAUDE.md` | 80–200 行 | 命令、架构、硬约束、已知陷阱 | Claude Code / WorkBuddy 每次全文读 |

`AGENTS.md` 是引导页，`CLAUDE.md` 是正文。两个都放，**内容不重复**——重复就会出现"改了这处忘了那处"（这个坑我们踩过：一个数字散在 13 处，靠 grep 才收齐）。

---

## 目录

```
AGENTS.md            仓库自己的入口（告诉 Codex 在这里该干嘛）
CHANGELOG.md         版本与变更记录
core/
  种子提示词.txt       400 字，粘贴即用（保底层）
  规则-30条.md         六场景速查 + 附录A 并行编排 PA1–PA4
  提问模板.md          Spec 门禁的操作化版本
  反例库.md            12 个决策前的自问，每个配真实后果
templates/           新项目直接拷：CLAUDE.md / AGENTS.md / spec / DECISIONS / MISTAKE-LOG / DoD / 每日三问 / new-project.sh
skill/               WorkBuddy 技能（--with-skill 安装）
codex/               Codex 子代理配置示例（explorer / worker / reviewer）
project-specific/    通用规则在真实项目里的落地形态（示例，别照搬）
install.sh           铺模板到目标项目，不覆盖已存在文件
```

---

## 安装

```bash
git clone <本仓库> ~/ai-playbook
cd ~/ai-playbook

sh install.sh --dry-run ~/your-project          # 先看会写哪些文件
sh install.sh ~/your-project                    # 真装
sh install.sh --with-skill ~/your-project       # 同时装 WorkBuddy 技能

# Codex 用户：手动合并配置，别整文件覆盖
cp codex/config.toml.example ~/.codex/config.toml
cp codex/agents/*.toml ~/.codex/agents/
```

装完第一件事不是写代码，是把 `CLAUDE.md` 里的命令真跑一遍，**跑不绿的那条当天修**。

---

## 三条最该记住的（其余可以查）

1. **验证会骗人。** 36% 的错误不是代码写错，是"我以为验证过了"。任何断言先证明它坏的时候会红。
2. **拍板即入账。** 定稿的决策不写进 `DECISIONS.md`，跨会话一定丢——真实案例：语音方案定稿 4 天后还在静默用旧方案。
3. **交给用户执行的脚本，风险和 AI 自己跑的一样高。** 真实案例：一个含中文注释的 `.cmd` 让用户机器"输入什么都会闪退"。

---

## 维护

- **版本规则**见 `CHANGELOG.md` 开头：删规则升主版本，加规则升次版本，改措辞升修订号。
- **改一处要同步副本**：`AGENTS.md` 末尾有副本清单，改完跑 `diff` 确认。
- **规则会过期**：连续两个项目零命中就删；单个规则文件超 150 行强制评审一次"删三条"。
- **判据**：没有这一条，AI 会犯哪个具体错误？说不出错误名字，就不要写进来。
