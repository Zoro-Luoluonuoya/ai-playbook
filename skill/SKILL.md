---
name: ai-collab-playbook
version: "1.0.0"
display_name: "AI 协作实战手册"
display_name_en: "AI Collaboration Playbook"
description_zh: "一套经过 15 天、198 次提交、30 轮对话实战检验的 AI 协作方法论与可复用资产：七阶段判决、30 条硬规则、六份可直接拷用的模板。当用户要开新项目、定开发协作规范、写验收脚本、做项目复盘、搭多窗口并行开发、或提到 CLAUDE.md / MISTAKE-LOG / spec 门禁 / 证据验收 / 并行 worktree 时使用。"
description_en: "A battle-tested AI collaboration playbook distilled from a 15-day, 198-commit, 30-round project: stage-by-stage verdicts on the spec-gate / layered-memory / worktree-parallel / evidence-based-acceptance workflow, 30 hard rules with failure symptoms and self-checks, and six copy-paste templates. Use when starting a new project, defining dev collaboration norms, writing acceptance scripts, retrospecting a project, or when the user mentions CLAUDE.md, MISTAKE-LOG, spec gate, evidence-based acceptance, or parallel worktrees."
category: workflow
tags:
  - collaboration
  - spec-driven
  - acceptance-testing
  - retrospective
  - parallel-development
  - worktree
agent_created: true
---

# AI 协作实战手册

这套东西不是理论，是一个真实项目（Electron 桌面应用，15 天，198 次提交，用户只打了 2495 个字）的实测结论。
**它最反直觉的一条**：那次协作里 43% 的错误不是代码写错，是"我以为验证过了"。

---

## 什么时候用它

- 开新项目，要定"AI 怎么干、我怎么审"
- 已经有项目，但反复返工、验收靠感觉、AI 老忘掉说好的决定
- 要写验收脚本 / 冒烟脚本，怕被假绿或假红骗
- 做项目复盘，要把经历变成可复用规则
- 要开多窗口 / 多 worktree 并行
- 要把这套规矩交接给别人、或用在装不了 WorkBuddy 的机器上（→ `references/种子提示词.txt`，纯文本粘贴即用）
- 用户提到：CLAUDE.md、MISTAKE-LOG、spec 门禁、证据验收、worktree

## 什么时候别用

- 一次性小脚本、单文件任务（这套的成本大于收益）
- 纯咨询问答，不涉及交付物
- 用户只想快速试个想法，不想立规矩

---

## 三条铁律（违反必返工）

### 铁律一：验证会骗人，先证明它坏的时候会红
任何"通过"的结论，都要先回答三个问题：正常值和故障值差多少？噪声多大？连跑两次还绿吗？
写不出这三个数，这条断言等于没写。测试依赖外部服务 → 必须有不可以用就跳过的分支，且 **SKIP ≠ PASS**。

### 铁律二：拍板必须入账，否则一定会被忘掉
`DECISIONS.md` 只收一种东西：**已经拍板、不许再议**的结论，每条带日期 + 适用范围 + 作废条件，每次会话开头读。
失败案例：语音方案定稿后 4 天，AI 每一句都在静默用旧方案，用户问「我们不是说好了吗」——因为定稿只写在 spec 里，而 spec 不是每次会话都读。

### 铁律三：交给用户执行的东西，风险和 AI 自己跑的一样高
给用户的脚本必须：内容零非 ASCII（注释也不行）、可一键撤销、优先"给命令让用户复制"而不是"给文件让用户双击"。
失败案例：一个含中文注释的 `.cmd`，cmd.exe 按 GBK 解析 UTF-8，用户机器"输入任何东西都闪退"。

---

## 按任务查（先看这一行，再进 references）

| 你正在做 | 查哪里 | 最先要做的动作 |
|---|---|---|
| 开新项目 | `assets/templates/` | 拷 6 个模板 → 改占位符 → **先建验证回路再写功能** |
| 写 spec | `spec.md.template` | 待决项必须来自真实分歧；「明确不做」至少 5 条 |
| 写验收 / 冒烟脚本 | `references/硬规则清单.md` §①V1–V8 | 断言区分力 → 连跑两次 → 外部依赖 SKIP → 窗口降级 |
| 改数据层 / 存储 | §②DT1–DT5 | 查询函数不许有副作用；删 data/ 前必备份 |
| 改 UI / 渲染 | §③U1–U4 | 重绘不得覆盖未保存输入；静默降级必须透传界面 |
| 接 LLM / 外部服务 | §④AI1–AI4 | 三层防御（重试 → 结构化输出 → 解析兜底） |
| 多窗口并行 | §⑤CO1–CO5 | 裁决变更必须广播全窗口，声明前序作废 |
| 环境 / 工具坑 | §⑥EN1–EN4 | 测试环境必须与运行环境**并存**，不能靠用户关应用 |
| 交付前 | `assets/templates/DoD-验收清单.md` | 四件套 + **点名哪层没跑** |
| 每日收工 | `assets/templates/每日三问.md` | 2 分钟三问 |

---

## 并行编排（默认不开，开则告知）

多开分身提升的是**吞吐，不是质量**。默认单人做；只有同时满足三条才拆：
①能切成互不相交的块 ②每块有独立验收标准 ③总量超单人 30 分钟。

不满足就别开：结论必须统一的、有严格先后的、需要主控私有上下文的。

开的时候守三条：**开之前告知**（几个/做什么/为什么）、**收工必校对**（编号、术语、口径、交叉引用）、**结论归主控**（不说"这是分身写的"）。

反例（真实发生）：两个并行写手各自造编号（`E1–E18` vs `V/CO/DT`），主控返工十几分钟。详见 `references/硬规则清单.md` 附录 A。

---

## 开新项目：30 分钟装机

1. **拷模板**（`assets/templates/`）：`CLAUDE.md.template` → 仓库根；`spec.md.template` → `docs/spec.md`；`MISTAKE-LOG.md.template` → `docs/`；`DoD-验收清单.md`、`每日三问.md` → `docs/`。
2. **建决策账本**：新建 `DECISIONS.md`，先写三条你今天已经拍板的事（技术选型、存储方案、界面口径）。没有就空着，但文件要在。
3. **建最小验证回路**：写第一个功能之前，先让"改一行 → 跑一条验证 → 看到绿"跑通，哪怕只覆盖一个页面。**这一步不能等到功能写完。**
4. **建门禁**（可选，秒级）：`pre-commit` 只做确定性检查（语法 + 改动文件 → 该跑哪层验证的记账）；`commit-msg` 必须给 merge/revert 留通道。
5. **要并行**再跑 `assets/templates/new-project.sh --dry-run <仓库> <窗口数>`，先看它要做什么。

---

## 七阶段的实战判决（省得重复踩）

| 阶段 | 判决 | 一句话 |
|---|---|---|
| Spec 门禁 | ✅ 有效 | 但踩刹车的是用户，AI 侧要主动"列假设 + 列真待决项" |
| 分层记忆 | ⚠️ 退化 | 容易变成同一规则写两遍；缺「已定稿决策」这一层 |
| 并行隔离 | ⚠️ 有代价 | 产出快是真的，口径漂移也是真的；并发度由"验证是否独占资源"决定 |
| Checkpoint | ✅ 有效 | 分支隔离已经是主用手段，快照只需覆盖"单分支批量操作" |
| 证据验收 | 🕳 有壳无核 | 只管"出证据"，没管"证据可不可信"——43% 错因在此 |
| Hook 门禁 | ❌ 形式化 | 只查语法和提交信息格式，与质量无关；漏跑一层没人知道 |
| 迭代飞轮 | ⚠️ 半闭环 | 记录做了，规则退役和定期回顾没做 |

**只改三件事**（性价比排序）：建 `DECISIONS.md` → 把"断言区分力"写进 DoD → 让门禁检查"该跑的层跑了吗"。

---

## 资产

```
references/硬规则清单.md     30 条（22 红线 / 8 强约束），六场景分组，每条带违规症状 + 自查
references/种子提示词.txt     400 字纯文本，粘给任何 AI 助手即生效（非 WorkBuddy 环境用这个）
assets/templates/
  CLAUDE.md.template        常驻层骨架，含"什么才配进常驻层"三条判据
  spec.md.template          五段式 + 有效提问的反例
  MISTAKE-LOG.md.template   错因单条格式 + 收录标准（流程摩擦也要收）
  DoD-验收清单.md            五层验证 + 假红自查 + 交付四件套
  每日三问.md                2 分钟日检
  new-project.sh            worktree 起手脚本（支持 --dry-run）
```

完整版（含复盘报告、逐条判决、证据索引）在项目内：`interview-duck/docs/复盘/`。
本 skill 内的副本若与之冲突，**以项目内版本为准**，并回头同步这里。

---

## 三条使用纪律

1. **规则会过期**。任何规则连续两个项目零命中就删；单个规则文件超 150 行强制评审一次"删三条"。
2. **不要一次全上**。六个模板里，第一周只用 `CLAUDE.md` + `DECISIONS.md` + `DoD`，其余等真需要时再加。
3. **别把这份东西当结论来源**。里面的每条都指向一次真实事故（M 编号 / 会话轮次）；引用时带上锚点，方便对方核。
