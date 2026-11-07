# AGENTS.md —— 在这个仓库里工作时

这是一个「AI 协作规则库」，不是应用代码。里面是模板、规则，和一次真实项目（15 天 / 198 次提交）的复盘结论。

## 你来这儿通常只有三种任务

| 任务 | 怎么开始 |
|---|---|
| 给某个项目装规则 | `sh install.sh --dry-run <项目路径>` 看清要写什么，再去掉 `--dry-run` |
| 改规则本身 | 改完必须同步副本（见下方清单），并在 `CHANGELOG.md` 记一笔为什么改 |
| 查某条规则凭什么存在 | `project-specific/interview-duck.md` 里有真实事故对照 |

## 三条铁律（对自己也适用）

1. **验证会骗人。** 改完要跑 `sh -n install.sh`、`git diff` 核过内容，不许凭感觉说"好了"。
2. **拍板即入账。** 改规则的决策写进 `CHANGELOG.md`，写清为什么改、影响谁。
3. **交给用户执行的脚本零风险。** 先问"谁解释它"：`.cmd`/`.bat` 零非 ASCII（含注释）；`.sh` 可留中文但须 UTF-8。共同：可撤销、优先给命令不给文件。

## 副本清单（改一处，要同步这些）

| 源文件 | 副本 |
|---|---|
| `templates/DoD-验收清单.md` | `skill/assets/templates/DoD-验收清单.md` |
| `templates/CLAUDE.md.template` | `skill/assets/templates/CLAUDE.md.template` |
| `templates/AGENTS.md.template` | `skill/assets/templates/AGENTS.md.template` |
| `core/规则-30条.md` | `skill/references/硬规则清单.md`（内容等价，格式不同） |

改完跑一遍 `diff` 确认，别只改一处。

## 两条禁止

- **不要把项目特定的东西写进 `core/`**：具体函数名、业务口径、某个项目的路径，都属于 `project-specific/`。
- **不要新增第 4 个规则文件**。现有已够用，新内容先想能不能并进已有的三份。
