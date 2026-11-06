# ai-playbook

一套经过实战检验的 AI 协作规矩。不是教程，是**能直接用的东西**：一份能粘贴的提示词、一份能安装的模板、一套能查的规则。

来源：一个真实项目 15 天、198 次提交、30 轮对话的复盘。用户全程只打了 2,488 个字。

---

## 三种用法，按你的环境选

| 环境 | 用哪层 | 怎么用 |
|---|---|---|
| 公司电脑，装不了东西 / 不能连网 | **种子提示词** | 复制 `core/种子提示词.txt` 全文，粘给任何 AI 助手，作为第一轮对话 |
| 有 git，想长期维护 | **装模板** | `git clone` 后 `sh install.sh <你的项目路径>` |
| 用 WorkBuddy | **skill** | `sh install.sh --with-skill <项目>` 会同时装到 `~/.workbuddy/skills/ai-collab-playbook`；也可以手动拷贝 `skill/` |

保底层是纯文本，不依赖任何工具——这是刻意设计的：公司环境的第一约束不是工具选型，是能不能装、能不能连网。

---

## 目录

```
core/
  种子提示词.txt       400 字，粘贴即用（三条铁律 + 动手前 + 交付时 + 踩坑后）
  规则-30条.md         按六场景速查：验证/数据/UI/外部服务/协作/环境（附录 A 为并行编排元规则 PA1–PA4）
  提问模板.md          Spec 门禁的操作化版本，含有效提问与无效提问对照
templates/
  CLAUDE.md.template  常驻层骨架（含"什么才配进常驻层"三条判据）
  DECISIONS.md.example 决策账本示例（拍板即冻结，每条带作废条件）
  spec.md.template     五段式 + 有效提问反例
  MISTAKE-LOG.md.template 错因格式 + 收录标准（流程摩擦也要收）
  DoD-验收清单.md       五层验证 + 假红三查 + 交付四件套
  每日三问.md           2 分钟日检
  new-project.sh       worktree 起手脚本（带 --dry-run）
project-specific/
  interview-duck.md    通用规则在一个真实项目里的落地形态（示例，别照搬）
skill/
  SKILL.md             WorkBuddy 技能入口（含 references/ 与 assets/templates/）
install.sh             铺模板到目标项目，不覆盖已存在文件；--with-skill 额外装 skill
```

---

## 安装

```sh
git clone <本仓库> ~/ai-playbook
cd ~/ai-playbook
sh install.sh --dry-run ~/your-project   # 先看会写哪些文件
sh install.sh ~/your-project             # 真装
```

安装后第一件事不是写代码，是把 `CLAUDE.md` 里的命令真跑一遍，跑不绿的那条当天修。

---

## 三条最该记住的（其余可以查）

1. **验证会骗人。** 43% 的错误不是代码写错，是"我以为验证过了"。任何断言先证明它坏的时候会红。
2. **拍板即入账。** 定稿的决策不写进 `DECISIONS.md`，跨会话一定丢——真实案例：语音方案定稿 4 天后还在静默用旧方案。
3. **交给用户执行的脚本，风险和 AI 自己跑的一样高。** 真实案例：一个含中文注释的 `.cmd` 让用户机器"输入什么都会闪退"。

---

## 维护

- 规则会过期：连续两个项目零命中就删；单文件超 150 行强制评审一次"删三条"。
- 新踩的坑写进项目的 `MISTAKE-LOG.md`，不要往这里加——这里是通用层，项目细节留在项目里。
- 通用规则如果被某个项目反复特殊化，说明它该参数化，不是该删。

判据：**没有这一条，AI 会犯哪个具体错误？** 说不出错误名字，就不要写进来。
