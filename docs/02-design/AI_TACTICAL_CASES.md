# 揭棋 AI 战术特例手册

> 与 `AI_DESIGN.md` 配套 · 记录**真实已实现**与**应实现**的决策分支  
> 代码锚点：`TacticalAdvisor`、`AgentOrchestrator`、`OptimizedAlphaBeta`、`EndgameJudge`

---

## 1. 决策流水线（谁先谁后）

```
TacticalAgent (5)     → 一步将杀 / 应将唯一着 / 直接吃帅
ProbabilityAgent (10) → 只设 evalBias，不直接选着
EndgameAgent (20)     → 子力 ≤ 12 时独占搜索（≤30s）
SearchAgent (100)     → 主 Alpha-Beta 迭代加深
```

| 优先级 | Agent | 触发条件 | 输出 |
|--------|-------|----------|------|
| 5 | `TacticalAgent` | 战术特例命中 | 立即返回该着 |
| 10 | `ProbabilityAgent` | 己方仍有暗子 | `probabilityBias = 己方期望子力 - 对方` |
| 20 | `EndgameAgent` | `pieceCount ≤ 12` | 深搜结果 |
| 100 | `SearchAgent` | 始终 | 主搜索结果 |

**挑战档（HARD）** 在编排之上叠加信念采样精炼，见 `BeliefAlphaBetaBot`。

---

## 2. 必看局面与应走着法

### 2.1 一步绝杀（最高优先）

| 情况 | 识别方式 | 应走 |
|------|----------|------|
| 明帅在攻击范围内 | 合法走法目标格为对方已翻开将/帅 | **立即吃帅** |
| 走完将死对方 | `executeMove` 后 `isInCheck(对方)` 且 `generateLegalMoves(对方).isEmpty()` | **该将杀步** |

实现：`TacticalAdvisor.findInstantMove`、`OptimizedAlphaBeta` 根节点帅捕获检测。

### 2.2 己方被将军

| 情况 | 识别方式 | 应走 |
|------|----------|------|
| 唯一应将 | `isInCheck(己方)` 且 `generateLegalMoves` 仅 1 步 | **该步**（无搜索） |
| 多应将 | 同上但 >1 步 | 搜索选最优：解将 + 不丢大子 + 保留反击 |
| 送将 | 走法后 `isInCheck(己方)` | **禁止**（`generateLegalMoves` 已过滤） |

评估侧：`KING_SAFETY_CHECK_PENALTY = 150` 惩罚己方被将。

### 2.3 长将 / 长捉 / 重复局面

| 情况 | 规则阈值 | AI 行为 |
|------|----------|---------|
| 重复将军第 6 次 | `repetitionCount ≥ 6` 且仍将军 | 走子方判负 |
| 重复捉（非兵）第 6 次 | 同上 + `findChaseTarget` | 走子方判负 |
| 兵卒长捉第 6 次 | 兵移动 + 捉 | **和棋** |
| 接近判负（AI 规避） | 执行后 `repetition[key]+1 ≥ 5` 且仍将军 | 根步分数 `-100_000`（非绝杀步） |

`key = Board.positionKey(board, 待走方)`，暗子以 `?` 编码，与 `Game` 一致。

**应走**：第 4–5 次重复将军前主动变着；有绝杀时不惩罚。

### 2.4 吃子与交换

| 情况 | 识别 | 应走 |
|------|------|------|
| 明子吃大子 | MVV-LVA 根排序 | 优先考虑 |
| 亏换（车换兵等） | `SEE < 0` | 静态搜索**跳过** |
| 暗子吃子 | 走法排序 +800（低于吃子） | 可吃，但需看是否暴露己方大子 |
| 吃暗子 | 目标 `type=UNKNOWN`，按 `virtualType` 估值 | 按期望价值交换，避免用車吃「可能是兵」的暗子亏太多 |

### 2.5 暗子与翻开

| 情况 | 规则 | AI 视角 |
|------|------|---------|
| 移动暗子 | 走完自动翻开，真实 type 公开 | 己方暗子知真实身份 |
| 对手暗子 | 搜索用 `createAiPublicView` | `type=UNKNOWN`，仅 `virtualType` 走法 |
| 原地翻子 | **禁止** | 不生成该走法 |
| 翻开后身份 | 搜索树内 `resolveRevealType` | 只暴露 virtualType，不透视真实 |

**信念采样（HARD）**：`BoardSampler` 从剩余子力池随机分配对手暗子真实 type，对 Top 候选求期望分。

### 2.6 残局（子力 ≤ 12）

| 情况 | 识别 | 应走 |
|------|------|------|
| 进入残局 | `AgentContext.pieceCount() ≤ 12` | `EndgameAgent` 深搜 |
| 对方孤王 | `evaluateKingHunt`：`oppMaterialExclKing < 1500` | 车/炮/马/过河兵逼近 + 压缩九宫 |
| 已将军 | `isInCheck(对方)` | 评估 +80，继续追杀 |
| 无吃子和 | `noCaptureCount ≥ 80` | 和棋（AI 可主动求和守势） |

### 2.7 子力与位置启发

| 维度 | 常量/逻辑 | 意图 |
|------|-----------|------|
| 子力 | 帅 10000 / 车 900 / 炮 450 / 马 400 | 标准象棋权重 |
| 过河兵 | `CROSSED_PAWN_BONUS = 100` | 鼓励过河 |
| 过河士象 | `CROSSED_MINOR_BONUS = 30` | 揭棋特殊 |
| 暗子池 | `DARK_PIECE_BONUS = 5` × 个数 | 保留信息价值 |
| 挂子威胁 | `evaluateThreats` | 对方便宜子吃我方贵子 → 重罚 |
| 大子送吃 | `majorPieceThreatPenalty`（根排序） | 走后被对方明车炮马威胁 → 降序 |

### 2.8 困毙与无子可动

| 情况 | 判定 | 结果 |
|------|------|------|
| 困毙 | 未被将且无合法走法 | 走子方负 |
| 搜索叶节点 | `generateLegalMoves` 空 | 若被将 → `-INF+1000`，否则 `-INF+2000` |

---

## 3. 搜索层优化（同时间更深）

| 技术 | 条件 | 效果 |
|------|------|------|
| 快速将杀判定 | `isInCheck` + 应着列表空 | 替代完整 `isCheckmate` 热路径 |
| 时间预测放宽 | `remaining < lastDepth × 1.5`（原 2.0） | 同预算多 0–1 迭代层 |
| 根评估复用 | `executeMove` 就地评估，不复制棋盘 | 减少根节点分配 |
| 静态搜索 | 叶节点仅扩展吃子，SEE 排序 | 避免和平着干扰 |
| LMR | 非吃非将、第 5+ 兄弟、depth≥3 | 减 1 层试探后可能重搜 |
| 渴望窗口 | depth≥2，`bestScore±80` | 减少全窗口重搜 |

> 将军延伸 / 唯一应将延伸：象棋引擎常用，但揭棋分支因子大，未加预算时易导致栈溢出；后续可用「每路径延伸预算」安全实现（参考 ElephantEye）。

---

## 4. 三档难度行为对照

| 场景 | 入门 EASY | 标准 MEDIUM | 挑战 HARD |
|------|-----------|-------------|-----------|
| 将杀一步 | 可能错过（30% 纯随机） | 战术 Agent + 搜索 | 同左 + 信念精炼 |
| 中局暗子多 | 启发式 Top-K 随机 | 期望子力 bias + 深搜 | 72% 深搜 + 28% 采样对比 |
| 残局 | 随机 | EndgameAgent 30s 上限 | 同标准 + 信念 |
| 长将 | 不规避 | repetition 惩罚 | 同左 |

---

## 5. 开源算法与文献参考

揭棋属于**不完全信息博弈**，与标准象棋引擎问题不同；可借鉴方向如下。

### 5.1 不完全信息 / 信念状态

| 项目 | 链接 | 可借鉴点 |
|------|------|----------|
| **StrangeFish2** | [ginoperrotta/reconchess-strangefish2](https://github.com/ginoperrotta/reconchess-strangefish2) | 维护对手可能局面集合；走前对多盘面评分取 mean/min/max |
| **Loopyfish** | [LukeRenton/Loopyfish](https://github.com/LukeRenton/Loopyfish) | 信念集 + Stockfish 战术；暗信息降不确定性 |
| **Penumbra / DSMCP** | [论文 OpenReview](https://openreview.net/pdf?id=Joy2imuk604) | 粒子滤波信念 + 信息状态摘要 + MCTS；2020 RBC 冠军 |
| **reconblindchess** | [ceremonious/reconblindchess](https://github.com/ceremonious/reconblindchess) | 每格 13 类概率分布神经网络 |

与本项目关系：我们的 `BoardSampler` + 期望搜索 = 轻量版粒子滤波；未实现神经网络信念。

### 5.2 中国象棋（明棋，可移植搜索技巧）

| 项目 | 链接 | 可借鉴点 |
|------|------|----------|
| **Pikafish** | [official-pikafish/Pikafish](https://github.com/official-pikafish/Pikafish) | Stockfish 系：NNUE、LMR、奇异剪枝、多线程 |
| **ElephantEye** | [xqbase/eleeye](https://github.com/xqbase/eleeye) | 将军延伸、唯一应将、空着裁剪、开局库 |
| **Orange-Xiangqi** | [danieltan1517/orange-xiangqi](https://github.com/danieltan1517/orange-xiangqi) | NNUE + 重复局面规则 |
| **JieqiAI** | [arthuryangcs/JieqiAI](https://github.com/arthuryangcs/JieqiAI) | 揭棋专用早期实现 |
| **CppXiangqi** | [homorunner/CppXiangqi](https://github.com/BloodmageThalnos/CppXiangqi) | **揭棋** Alpha-Beta；作者注明暗子导致剪枝失效，深度仅 3–4 层 |

与本项目关系：已用 ElephantEye 风格延伸/静态搜索；**未**用 NNUE（工作量过大）；Pikafish 的奇异剪枝、多线程可作后续方向。

### 5.3 不建议直接照搬

- **空着裁剪（NMP）**：象棋/揭棋存在大量 zugzwang 局面，误用会送分。
- **完整 Stockfish 移植**：揭棋分支因子与暗子期望不同，需改评估与合法着生成。
- **纯 MCTS**：无强策略网络时，5s 预算深度不如 Alpha-Beta。

---

## 6. 已知未覆盖（待强化）

| 缺口 | 影响 | 建议 |
|------|------|------|
| 无开局库 | 前 10 手略弱 | 从 Pikafish/ElephantEye 库改编脱敏版 |
| 无多线程 | 单核深度上限 | 根节点并行信念采样 |
| 评估未自对弈调参 | 中局形势判断 | 遗传算法 / SPSA 调 `EvaluationConstants` |
| 长捉规避弱于长将 | 可能被判长捉负 | 扩展 `repetitionRisk` 到 `findChaseTarget` |
| ProbabilityAgent 只设 bias | 暗子局改进有限 | 暗子进攻/防守专用模式表 |

---

*文档版本：v1.0 · 分支 `feat/ai-hard-strength` · 与代码同步审查*
