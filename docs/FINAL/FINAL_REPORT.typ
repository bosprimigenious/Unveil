// 揭棋对弈 — 最终报告（初版）（整合全部子文档 + 接口协议 + 图表 + 24 张图片）
// 编译: typst compile FINAL_REPORT.typ FINAL_REPORT.pdf --root ..

#set document(
  title: "揭棋对弈 — 最终报告（初版）",
  author: ("张恒基", "秦博宇", "陈艺博", "陈雨飞"),
  date: datetime(year: 2026, month: 6, day: 18),
)

// ── 页脚页码 ──
#let page-footer = context [
  #place(bottom + center, dy: -14pt)[
    #text(size: 10.5pt, fill: rgb(148, 163, 184))[#counter(page).display("1")]
  ]
]

#set page(
  margin: (left: 2.5cm, right: 2.5cm, top: 2.2cm, bottom: 2.2cm),
  numbering: "1",
  footer: page-footer,
)

// ── 字体与排版 ──
#let main-font = ("SimSun", "SimHei", "Microsoft YaHei")
#set text(font: main-font, size: 12pt)
#set par(leading: 0.85em, first-line-indent: 0pt, spacing: 0.65em)
#set heading(numbering: "1.")

#let h1-size = 20pt
#let h2-size = 15pt
#let h3-size = 13pt
#let code-size = 9.5pt
#let seq-size = 9.2pt
#let payload-size = 8.5pt
#let caption-size = 11pt
#let hint-size = 11pt

// ── 防断行工具 ──
#let nb(body) = box(body)
#let small(body) = text(size: 10pt)[#body]
#let codecell(body) = text(font: mono-font, size: 9pt)[#body]

// ── 状态标签 ──
#let ok = text(fill: rgb("#15803d"))[已实现]
#let warn = text(fill: rgb("#c2410c"))[部分实现]
#let no = text(fill: rgb("#b91c1c"))[未实现]

// ── 标题样式 ──
#show heading: set text(font: main-font)

#show heading.where(level: 1): it => {
  block(breakable: false, above: 2em, below: 1em)[
    #block(
      width: 100%,
      inset: (left: 10pt, top: 10pt, bottom: 10pt),
      fill: rgb("#eff6ff"),
      radius: 4pt,
      stroke: (left: 4pt + rgb("#1e40af")),
    )[
      #text(size: h1-size, weight: "bold", fill: rgb("#1e3a8a"))[#it]
    ]
  ]
}
#show heading.where(level: 2): it => {
  block(above: 1.4em, below: 0.7em)[
    #text(size: h2-size, weight: "bold", fill: rgb("#1e40af"))[#it]
    #v(0.15em)
    #line(length: 100%, stroke: 0.5pt + rgb("#bfdbfe"))
  ]
}
#show heading.where(level: 3): it => {
  block(above: 1.1em, below: 0.55em)[
    #text(size: h3-size, weight: "bold", fill: rgb("#334155"))[#it]
  ]
}

#show figure.caption: set text(size: caption-size)
#set table(inset: (x: 10pt, y: 8pt))

// ── 图片路径（与 FINAL_REPORT.typ 同目录）──
#let img(name, width: 100%, caption: none) = figure(
  image(name, width: width),
  caption: caption,
)

// ── 等宽字体 ──
#let mono-font = ("Consolas", "Courier New", "DejaVu Sans Mono")
#show raw.where(block: false): set text(font: mono-font, size: code-size)

// ── 时序图 ──
#let seq-diagram(content, caption, roles: none, size: 9pt) = figure(
  block(
    width: 100%,
    fill: rgb("#f8fafc"),
    inset: 14pt,
    radius: 4pt,
    stroke: 0.5pt + rgb("#e2e8f0"),
    breakable: true,
  )[
    #if roles != none [
      #align(center)[#text(size: hint-size, fill: rgb("#334155"))[#roles]]
      #v(8pt)
    ]
    #set text(font: mono-font, size: size)
    #set par(leading: 0.72em, spacing: 0pt)
    #raw(block: true, lang: "text", content.trim())
  ],
  caption: caption,
)

// ── 等宽多行块 ──
#let mono-lines(content, title: none) = block(
  width: 100%,
  fill: rgb("#f8fafc"),
  inset: 12pt,
  radius: 4pt,
  stroke: 0.5pt + rgb("#e2e8f0"),
  breakable: true,
)[
  #if title != none [
    #text(weight: "bold", size: hint-size, fill: rgb("#334155"))[#title]
    #v(6pt)
  ]
  #set text(font: mono-font, size: payload-size)
  #set par(leading: 0.62em, spacing: 0pt, justify: false)
  #for line in content.trim().split("\n") {
    let row = line.trim()
    if row.len() > 0 [
      #row
      #linebreak()
    ] else [
      #v(0.3em)
    ]
  }
]

// ── JSON 代码块 ──
#let json-snippet(title, content) = {
  v(0.35em)
  mono-lines(content, title: title)
}

#show raw.where(block: true): it => block(
  width: 100%,
  breakable: true,
  fill: rgb("#f8fafc"),
  inset: 10pt,
  radius: 3pt,
  stroke: 0.5pt + rgb("#e2e8f0"),
)[
  #set text(font: mono-font, size: code-size)
  #set par(leading: 0.65em)
  #it
]

// ── 架构图（ASCII） ──
#let arch-diagram(content, caption: none, size: 9pt) = figure(
  block(
    width: 100%,
    fill: rgb("#f8fafc"),
    inset: 14pt,
    radius: 4pt,
    stroke: 0.5pt + rgb("#e2e8f0"),
    breakable: true,
  )[
    #set text(font: mono-font, size: size)
    #set par(leading: 0.72em, spacing: 0pt, justify: false)
    #raw(block: true, lang: "text", content.trim())
  ],
  caption: caption,
)

// ═══════════════════════════════════════════════════════════
// 封面
// ═══════════════════════════════════════════════════════════

#page(margin: (top: 2.2cm, bottom: 2.2cm, x: 2.8cm), numbering: none, footer: none)[
  #set text(font: main-font)
  #align(center + horizon)[
    #block(
      width: 15cm,
      inset: (y: 1.1cm),
      stroke: (top: 2.5pt + rgb("#1a365d"), bottom: 0.75pt + rgb("#cbd5e1")),
    )[
      #align(center)[
        #text(size: 10.5pt, tracking: 0.35em, fill: rgb("#475569"))[大 作 业]
        #v(0.55cm)
        #text(size: 26pt, weight: "bold", fill: rgb("#0f172a"))[揭棋对弈程序设计]
        #v(0.65cm)
        #text(size: 19pt, weight: "medium", fill: rgb("#1e40af"))[最终报告（初版）]
      ]
    ]

    #v(1.5cm)

    #box(
      width: 15cm,
      inset: (x: 1.2cm, y: 0.95cm),
      fill: rgb("#f8fafc"),
      radius: 6pt,
      stroke: 0.75pt + rgb("#e2e8f0"),
    )[
      #align(center)[
        #text(size: 11pt, weight: "bold", fill: rgb("#334155"))[小组成员]
        #v(0.55cm)
        #table(
          columns: (1.6fr, 2fr),
          stroke: none,
          align: center + horizon,
          [#nb[#text(size: 13pt, weight: "bold")[张恒基（组长）]]], [#nb[#text(size: 11pt, fill: rgb("#64748b"))[2024211301 / 2024210926]]],
          [#nb[#text(size: 13pt, weight: "bold")[秦博宇]]], [#nb[#text(size: 11pt, fill: rgb("#64748b"))[2024211302 / 2024210940]]],
          [#nb[#text(size: 13pt, weight: "bold")[陈艺博]]], [#nb[#text(size: 11pt, fill: rgb("#64748b"))[2024211302 / 2024210931]]],
          [#nb[#text(size: 13pt, weight: "bold")[陈雨飞]]], [#nb[#text(size: 11pt, fill: rgb("#64748b"))[2024211005]]],
        )
      ]
    ]

    #v(1.4cm)

    #align(center)[
      #text(size: 11pt, fill: rgb("#64748b"))[项目代号：Unveil]
      #v(0.25cm)
      #text(size: 11pt, fill: rgb("#64748b"))[2026 年 6 月 18 日]
      #v(0.25cm)
      #text(size: 11pt, fill: rgb("#64748b"))[北京邮电大学 · 计算机学院]
    ]
  ]

  #v(1fr)
  #align(center)[
    #text(size: caption-size, fill: rgb(148, 163, 184))[
      本文整合 34 份子文档全部关键内容，含完整 WebSocket JSON 协议规范
    ]
  ]
]

#pagebreak()
#set page(numbering: none, footer: none)
#outline(title: "目录", indent: 2em)

#v(0.5cm)
#block(
  width: 100%,
  inset: (x: 10pt, y: 8pt),
  fill: rgb("#fffbeb"),
  radius: 4pt,
  stroke: 0.5pt + rgb("#fcd34d"),
)[
  #text(size: hint-size, fill: rgb("#78350f"))[
    *整合说明*：第 3 章 = 完整 WebSocket JSON 协议规范（原 INTERFACE.typ v3.1）；第 4–11 章 = 设计/测试/部署/产品/答辩内容；附录 = TCP 扩展 + 术语表 + 命令速查。
  ]
]

#pagebreak()
#set page(numbering: "1", footer: page-footer)
#counter(page).update(1)

// ═══════════════════════════════════════════════════════════
// 第一章：项目总览
// ═══════════════════════════════════════════════════════════
= 项目总览

== 项目背景

揭棋是中国象棋变体：开局仅将/帅明置，其余 15 子暗置并按*所在位置的原始角色*走子；首次移动或吃子后随机翻开，明子按真实身份行棋。规则涉及暗子/明子差异、强化士象（明士可出九宫、明象可过河）、禁送将、将帅照面、长将长捉等复杂约束。

本项目是北京邮电大学「揭棋对弈程序设计」课程大作业，代号 *Unveil*，由第一组（张恒基组长）完成。

== 六大目标

#table(
  columns: (auto, 1fr, auto),
  [*No.*], [*目标*], [*状态*],
  [1], [揭棋规则引擎 — 服务端权威校验，覆盖七种棋子走法、暗子约束、终局判定全链路], [#ok],
  [2], [WebSocket + JSON 网络对弈 — 课程公共接口（端口 8887），匹配/房间/超时/聊天/提和/认输], [#ok],
  [3], [三档 AI 博弈 — Easy 启发式 / Medium Alpha-Beta / Hard Belief Sampling 非完全信息搜索], [#ok],
  [4], [棋谱与复盘 — 文字棋谱落盘 + 内存复盘时间线 + replay.json 持久化 + replayRequest/replayFrame 协议], [#ok],
  [5], [工程化交付 — Maven 5 模块 + Fat JAR + verify.ps1 自检 + demo.ps1 演示], [#ok],
  [6], [文档体系 — 34 份 Typst → 33 份 PDF，覆盖需求→设计→协议→部署→测试→产品→答辩全生命周期], [#ok],
)

== 项目规模

#table(
  columns: (1.4fr, 1fr, 3.6fr),
  [*指标*], [*数值*], [*说明*],
  [Maven 模块], [*5*], [#small[`jieqi-core` / `jieqi-server` / `jieqi-client` / `jieqi-ai` / `jieqi-app`]],
  [Java 主代码], [*63 文件*], [约 8,500 行（含测试约 10,500）],
  [自动化测试], [*142/142 通过*], [core 89 + ai 16 + server 37，0 失败 0 跳过],
  [Typst 文档], [*34 份*], [编译 33 份 PDF，覆盖 8 个类别],
  [Web 前端], [Vue 3 + Vite + Pinia], [对局界面 + 终局查看 + 复盘控件],
)

== 技术栈

Java 21 · Maven 3.9+ · Java-WebSocket · Gson · JUnit 5 · Typst 0.14.2（协议 PDF）· Docker Compose · Vue 3 + Vite + Pinia（Web 前端）

== 项目结构

#arch-diagram(
  "
  Unveil/
  ├── pom.xml                    # Maven 父 POM（Java 21 多模块）
  ├── jieqi-core/                # 规则核心：Board, ChessPiece, RuleValidator, Game,
  │                              #   Protocol.java, json/, GameRecord, MoveNotation
  ├── jieqi-server/              # WS(8887)/TCP(8888) 服务：WsGameServer, GameServer,
  │                              #   Room, Matchmaking, GameRecordStore
  ├── jieqi-client/              # 控制台客户端：GameClient, WsGameClient, ConsoleUI
  ├── jieqi-ai/                  # 搜索与评估：AiConfig, EasyRuleBot, AlphaBetaBot,
  │                              #   BeliefAlphaBetaBot, AgentOrchestrator,
  │                              #   AlphaBetaSearch, TranspositionTable, BoardSampler
  ├── jieqi-app/                 # 启动入口：UnveilApp（1-10 菜单）, Fat JAR 打包
  ├── jieqi-web/                 # Vue 3 前端：LoginView, LobbyView, GameView,
  │                              #   ChessBoard.vue, game.ts(Pinia), ws.ts, chessRules.ts
  ├── scripts/                   # verify.ps1, demo.ps1, run-app.ps1, dev-server.ps1,
  │                              #   compile-docs.ps1, count-loc.ps1
  └── docs/                      # Typst 文档体系：template.typ, INTERFACE.typ v3.1,
                                 #   00-overview/ ~ 07-presentation/ (8 类 34 份)
  ",
  caption: [项目目录结构（完整包路径见 §2 模块职责表）],
  size: 7.5pt,
)

== 验收主线

本项目围绕五条课程验收主线展开。

#table(
  columns: (auto, 1fr),
  table.header([*验收主线*], [*实现方式*]),
  [规则正确性], [所有正式对局走子由服务端 `Game.processMove` 统一进入 `RuleValidator` 与 `EndgameJudge`；客户端仅承担交互提示，不作为权威规则源],
  [网络互操作], [以 WebSocket + JSON 为主协议（端口 8887），覆盖登录、匹配、房间、准备、先手协商、走子、聊天、提和、认输、超时、终局、复盘和重赛；控制台客户端与 Web 前端共用同一协议],
  [AI 可解释性], [三档 AI 分别对应 Easy（启发式排序 + 随机选择）、Medium（Agent 编排 + Alpha-Beta 搜索）、Hard（Belief Sampling 非完全信息搜索）],
  [棋局可追溯], [同时保存文字棋谱（`records/*.jieqi`）和 `ReplayFrame` 快照时间线；文字棋谱用于人工阅读与导出，快照用于逐步还原每一步后的棋盘状态，避免暗子随机导致单纯走法重放不稳定],
  [工程可复现], [Maven 多模块 + Fat JAR + verify.ps1 自检 + demo.ps1 演示 + Docker Compose 实验性部署 + Typst 文档体系，课程验收环境可快速构建、运行、测试和展示],
)

// ═══════════════════════════════════════════════════════════
// 第二章：总体架构
// ═══════════════════════════════════════════════════════════
= 总体架构

== 模块依赖

#img("diag_module_dependencies.svg", width: 95%, caption: [模块依赖关系（单向：core ← server/client/ai ← app；web 经 WS 对接 server）])

== 模块职责

#table(
  columns: (auto, 1.5fr, 1fr),
  table.header([*模块*], [*职责*], [*不做什么*]),
  [jieqi-core], [棋盘、棋子、规则校验、终局判定、棋谱记法、协议模型], [不含网络、AI、UI],
  [jieqi-server], [WS/TCP 服务、房间管理、匹配队列、用户注册、持久化、AI 调度], [不含规则判断],
  [jieqi-client], [控制台交互、棋盘渲染（10×9）、命令解析、复盘 n/p/g 命令], [不含规则判断],
  [jieqi-ai], [AB 搜索、局面评估、Belief Sampling、三档 Bot、Agent 编排], [不含领域逻辑],
  [jieqi-app], [统一启动菜单（1–9 模式）、CLI 参数、Fat JAR 入口], [无新业务逻辑],
  [jieqi-web], [Vue 3 对局界面、ChessBoard Canvas、聊天、终局查看、复盘控件], [不含权威规则判定（仅含前端提示用预校验）],
)


#figure(
  table(
    columns: (1.2fr, 3fr),
    table.header([*架构层*], [*职责与模式*]),
    [通信层], [
      - *WsGameServer*：WebSocket 连接管理、JSON 消息序列化/反序列化、心跳检测、断线重连检测
      - *GameServer*：TCP 文本帧服务器（`\n` 分隔）、粘包/半包帧解码（FrameDecoder）
      - 模式：外观（WsGameServer 封装底层 WebSocket API）、单例（全局服务实例）
    ],
    [消息处理层], [
      - *消息路由*：按 `messageType` 分发至对应 Handler（handleLogin / handleMove / handleChat 等）
      - *校验链*：登录校验 → 房间校验 → 回合校验 → 规则校验 → 终局校验
      - 模式：策略（消息类型到处理策略的映射）、命令（chat / draw / resign / rematch 等指令对象）
    ],
    [业务逻辑层], [
      - *jieqi-core* 领域模型：Board 聚合根 + ChessPiece 实体 + RuleValidator 领域服务 + EndgameJudge 领域服务
      - *jieqi-ai* 博弈引擎：三档 Bot（EasyRuleBot / AlphaBetaBot / BeliefAlphaBetaBot）
      - 模式：工厂（AiConfig.forLevel 创建 AI 实例）、模板方法（AiBot 接口 → 三档实现）
    ],
    [数据持久层], [
      - *GameRecordStore*：棋谱文件 `records/{gameId}.jieqi` 落盘与读取
      - *ReplayRecordStore*：ReplayFrame JSON 持久化 `records/{gameId}.replay.json`
      - *UserRegistry*：内存用户注册表（昵称、会话管理）
      - 模式：仓库（GameRecordStore 封装文件 IO）、序列化器（JsonMapper、MoveNotation）
    ],
  ),
  caption: [四层架构设计模式总览],
)


== 对局主流程

#arch-diagram(
  "
  moveRequest 到达服务器
    │
    ├─[1] 对局状态?          ──否→ 拒绝
    ├─[2] 轮到你?            ──否→ 拒绝
    ├─[3] 超时 65s?          ──是→ TIMEOUT
    ├─[4] 原地翻子?          ──是→ 拒绝
    ├─[5] 走法几何合法?      ──否→ invalid
    ├─[6] 是否送将?          ──是→ 拒绝
    │
    ├─[7] Board.executeMove
    ├─[8] GameRecord.append
    ├─[9] ReplayTimeline.recordAfterMove
    │
    └─[10] EndgameJudge.checkAfterMove
          ├─ 终局 → gameOver + 落盘
          └─ 继续 → moveResult + 换方
  ",
  caption: [服务器走子校验与执行全链路（10 步）],
  size: 8.5pt,
)


#figure(
  table(
    columns: (1fr, 2.5fr, 3fr),
    table.header([*设计模式*], [*应用场景*], [*具体实现*]),
    [外观 (Facade)], [WsGameServer 对外暴露单一入口],
      [客户端只需连接 WebSocket URL，内部消息路由、校验、广播全部封装在 WsGameServer 内部。],
    [单例 (Singleton)], [全局唯一服务实例],
      [GameServer / WsGameServer 各维护一个实例；UserRegistry 全局用户注册表。],
    [工厂 (Factory)], [AiConfig.forLevel() 创建 AI],
      [根据 AiLevel（EASY/MEDIUM/HARD）返回不同的 AiConfig 参数配置，创建对应的 Bot 实例。],
    [策略 (Strategy)], [消息类型 → 处理策略],
      [`messageType` 字符串映射至对应 Handler 方法：`"chat"` → `handleChat()`, `"move"` → `handleMove()`, `"drawOffer"` → `handleDrawOffer()`。],
    [命令 (Command)], [对局操作抽象],
      [chat、drawOffer/resign/rematchRequest/addTime/pauseGame 等对局内操作以消息对象传递，服务端解析后执行对应命令逻辑。],
    [模板方法 (Template)], [AiBot 接口 → 三档 Bot],
      [AiBot 接口定义 `selectMove()` 契约，EasyRuleBot / AlphaBetaBot / BeliefAlphaBetaBot 各自实现搜索策略。],
    [观察者 (Observer)], [broadcastRoom() 广播],
      [走子后向房间内双方 + 观战者广播 moveResult/gameOver，客户端被动接收更新 UI。],
  ),
  caption: [通信层设计模式 — 外观 / 单例 / 工厂 / 策略 / 命令 / 模板方法 / 观察者],
)

#figure(
  table(
    columns: (1fr, 1.5fr, 3fr),
    table.header([*状态*], [*触发条件*], [*行为*]),
    [Created], [任一玩家发送 `createRoom` 或匹配队列新建房间],
      [创建 Room 对象，分配 roomId，返回 joinCode 供另一方加入。],
    [Waiting], [至少 1 名玩家已加入，等待对手],
      [匹配队列轮询、邀请码加入、AI 对手加入；双方就绪后自动进入 Playing。],
    [Playing], [双方均已 Ready 且 gameStart 已广播],
      [接受 move/chat/drawOffer/resign/replayRequest/rematchRequest 等消息；步时 65s 倒计时；终局条件触发后进入 GameOver。],
    [GameOver], [EndgameJudge 判定终局（吃将/将死/困毙/超时/认输/和棋/长将/长捉）],
      [广播 gameOver 含终局原因与 capturedReveal；落盘棋谱与 replay.json；房间保留在内存供 Web 复盘；rematchRequest 可触发 new gameStart 回到 Playing。],
    [Disconnected], [玩家 WebSocket 断线超过容忍阈值],
      [对方收到 gameOver（ABANDONED），房间进入 GameOver 后清理。],
  ),
  caption: [房间状态机 — Created → Waiting → Playing → GameOver],
)


== 核心类图

#table(
  columns: (1.2fr, 4fr),
  [*Board*], [10×9 棋盘，棋子查询、make/undo 走子、AI 脱敏视角、局面哈希],
  [*ChessPiece*], [color、type（真实）、virtualType（原位角色）、revealed、row、col],
  [*Move*], [source、destination、isFlipOnly],
  [*Game*], [对局状态机：board、currentTurn、status、gameRecord、replayTimeline],
  [*RuleValidator*], [isValidMove / isMoveLegal / generateStrictLegalMoves],
  [*EndgameJudge*], [checkAfterMove：吃将→将死→困毙→40步和→长将/长捉/超时/认输],
  [*GameRecord*], [文字棋谱 → `*.jieqi`；标准记法含回合号、红黑标识、翻子标记],
  [*ReplayTimeline*], [List⟨ReplayFrame⟩ 快照时间线；每帧含 stepIndex/move/board/captured/status],
  [*AiBot*], [接口 ← EasyRuleBot / AlphaBetaBot (JieqiAgent) / BeliefAlphaBetaBot],
  [*OptimizedAlphaBeta*], [搜索内核：AB 剪枝 + 迭代加深 + TT + 杀手/历史 + 静态搜索 + LMR],
)

== 坐标系统

棋盘为 10 行 × 9 列，坐标为"字母列 + 数字行"。

#table(
  columns: (auto, auto, auto),
  table.header([*维度*], [*范围*], [*方向*]),
  [行], [`0`–`9`（共 10 行）], [从上到下：9 → 0],
  [列], [`a`–`i`（共 9 列）], [从左到右：a → i],
)

#v(0.3cm)
#figure(
  table(
    columns: (1.2cm,) + 9 * (1.2cm,),
    stroke: 0.3pt + rgb(203, 213, 225),
    align: center + horizon,
    table.cell(stroke: (bottom: 1pt + black))[], table.cell(stroke: (bottom: 1pt + black))[a], table.cell(stroke: (bottom: 1pt + black))[b], table.cell(stroke: (bottom: 1pt + black))[c], table.cell(stroke: (bottom: 1pt + black))[d], table.cell(stroke: (bottom: 1pt + black))[e], table.cell(stroke: (bottom: 1pt + black))[f], table.cell(stroke: (bottom: 1pt + black))[g], table.cell(stroke: (bottom: 1pt + black))[h], table.cell(stroke: (bottom: 1pt + black))[i],
    table.cell(fill: rgb(241, 245, 249))[9], [車], [馬], [象], [士], [將], [士], [象], [馬], [車],
    [8], [·], [·], [·], [·], [·], [·], [·], [·], [·],
    table.cell(fill: rgb(241, 245, 249))[7], [·], [炮], [·], [·], [·], [·], [·], [炮], [·],
    table.cell(fill: rgb(241, 245, 249))[6], [卒], [·], [卒], [·], [卒], [·], [卒], [·], [卒],
    table.cell(stroke: (bottom: 1pt + black))[5], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·], table.cell(stroke: (bottom: 1pt + black))[·],
    [4], [·], [·], [·], [·], [·], [·], [·], [·], [·],
    table.cell(fill: rgb(241, 245, 249))[3], [兵], [·], [兵], [·], [兵], [·], [兵], [·], [兵],
    table.cell(fill: rgb(241, 245, 249))[2], [·], [炮], [·], [·], [·], [·], [·], [炮], [·],
    [1], [·], [·], [·], [·], [·], [·], [·], [·], [·],
    table.cell(fill: rgb(241, 245, 249))[0], [車], [馬], [相], [士], [帥], [士], [相], [馬], [車],
  ),
  caption: [棋盘初始布局（行 0 = 红方底线，行 9 = 黑方底线）],
)

*重要约定*：先手（红方）始终在下方（行 0–4），后手（黑方）在上方（行 5–9）。坐标字符串中行号直接使用显示行号（如红帅 = `"e0"`，黑将 = `"e9"`）。内部数组转换：`row = 9 - displayRow`，`col = coord.charAt(0) - 'a'`。

== 虚拟类型机制

暗子未翻开时，其*移动规则*由所在位置的"虚拟类型"决定（该位置按中国象棋初始布局本应放置的棋子类型）。

#v(0.3cm)
#figure(
  table(
    columns: (1.2cm,) + 9 * (1.2cm,),
    stroke: 0.3pt + rgb(203, 213, 225),
    align: center + horizon,
    table.cell(stroke: (bottom: 1pt + black))[], table.cell(stroke: (bottom: 1pt + black))[a], table.cell(stroke: (bottom: 1pt + black))[b], table.cell(stroke: (bottom: 1pt + black))[c], table.cell(stroke: (bottom: 1pt + black))[d], table.cell(stroke: (bottom: 1pt + black))[e], table.cell(stroke: (bottom: 1pt + black))[f], table.cell(stroke: (bottom: 1pt + black))[g], table.cell(stroke: (bottom: 1pt + black))[h], table.cell(stroke: (bottom: 1pt + black))[i],
    table.cell(fill: rgb(248, 250, 252))[9], [車], [馬], [象], [士], table.cell(fill: rgb(254, 242, 242))[將], [士], [象], [馬], [車],
    [8], [―], [―], [―], [―], [―], [―], [―], [―], [―],
    table.cell(fill: rgb(248, 250, 252))[7], [―], [炮], [―], [―], [―], [―], [―], [炮], [―],
    table.cell(fill: rgb(248, 250, 252))[6], [卒], [―], [卒], [―], [卒], [―], [卒], [―], [卒],
    table.cell(stroke: (bottom: 1pt + black))[5], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―], table.cell(stroke: (bottom: 1pt + black))[―],
    [4], [―], [―], [―], [―], [―], [―], [―], [―], [―],
    table.cell(fill: rgb(248, 250, 252))[3], [兵], [―], [兵], [―], [兵], [―], [兵], [―], [兵],
    table.cell(fill: rgb(248, 250, 252))[2], [―], [炮], [―], [―], [―], [―], [―], [炮], [―],
    [1], [―], [―], [―], [―], [―], [―], [―], [―], [―],
    table.cell(fill: rgb(248, 250, 252))[0], [車], [馬], [相], [士], table.cell(fill: rgb(254, 242, 242))[帥], [士], [相], [馬], [車],
  ),
  caption: [棋盘各位置对应的虚拟类型（红底格为开局即明的将/帅）],
)

== 明子强化规则

暗子翻开为明子后，士和象获得强化：

#table(
  columns: (auto, auto, auto),
  table.header([*棋子*], [*暗子状态*], [*明子状态（强化）*]),
  [士 / 仕], [斜走一格，限于九宫内], [斜走一格，*可离宫、可过河*],
  [象 / 相], [田字走法，不可过河，塞象眼有效], [田字走法，*可过河*，塞象眼不变],
)

其他棋子走法规则与中国象棋完全一致。

== 一次走子的完整调用链

以下跟踪一次走子请求从客户端到服务端再广播回所有客户端的完整路径。

```text
Web 前端 / 控制台客户端
  → 发送 move JSON (fromX, fromY, toX, toY, isFlip)
  → WsGameServer.handleMove (WebSocket onMessage 分发)
  → JsonMessages.parseMove (JSON → Move 对象)
  → RandomRevealService.sanitizeClientMove (清除客户端伪造 type)
  → Game.processMove (对局状态机入口)
  → RuleValidator.isValidMove (几何走法合法?)
  → RuleValidator.isMoveLegal (不送将?)
  → Board.executeMove (走子 + 翻子 + 吃子 + 切换回合)
  → EndgameJudge.checkAfterMove (优先级判定：吃将→将死→困毙→无吃子和→重复→继续)
  → JsonMessages.moveResult / gameOver (构建响应)
  → WebSocket 广播 (moveResult / gameOver 推送给双方)
```

各步骤代码位置：`WsGameServer.java` L722–808（handleMove 分发）· `Game.java` processMove（对局状态机）· `RuleValidator.java`（双层校验）· `EndgameJudge.java`（终局判定）。

// ═══════════════════════════════════════════════════════════
// 第三章：WebSocket + JSON 通信协议规范
// ═══════════════════════════════════════════════════════════
= WebSocket + JSON 通信协议规范

== 基础约定

=== 术语定义

#table(
  columns: (auto, 1fr),
  [*术语*], [*含义*],
  [暗子], [背面朝上、尚未翻开的棋子，按所在位置对应的中国象棋棋子规则移动],
  [明子], [正面朝上、已翻开的棋子，按实际类型规则移动],
  [翻子], [暗子完成合法移动或吃子后变为明子的揭示过程；标准规则不允许原地翻子],
  [先手], [红方，行棋优先权，棋盘下方],
  [后手], [黑方，棋盘上方],
  [回合], [一方完成一次合法走子],
  [半步], [一方的一次走子（40 回合 = 双方共 80 个半步）],
)

=== 技术约定

#table(
  columns: (auto, auto, auto),
  table.header([*项目*], [*约定*], [*备注*]),
  [传输协议], [*WebSocket* + *JSON*], [课程公共接口；默认端口 *8887*],
  [TCP 扩展], [文本帧 `msgType|len|payload\n`], [本组保留；默认端口 *8888*；见附录 A],
  [字符编码], [*UTF-8*], [JSON 与 TCP payload 均为 UTF-8],
  [WS 消息识别], [`messageType` 字符串], [每条 JSON 对象必含此字段],
  [心跳], [`ping` / `pong`，建议 10s], [未实现心跳的客户端应被兼容],
  [超时阈值], [65 秒（60 秒思考 + 5 秒网络裕量）], [服务器可配置],
  [时间戳单位], [毫秒], [`System.currentTimeMillis()` 风格],
  [时间戳权威方], [*服务器*], [客户端时间戳仅供参考],
)

== 棋子类型编码

#table(
  columns: (auto, auto, auto, auto),
  table.header([*编码*], [*类型*], [*红方名*], [*黑方名*]),
  [0], [KING], [帅], [将],
  [1], [ROOK], [车], [车],
  [2], [KNIGHT], [马], [马],
  [3], [CANNON], [炮], [炮],
  [4], [PAWN], [兵], [卒],
  [5], [ADVISOR], [仕], [士],
  [6], [BISHOP], [相], [象],
  [-1], [UNKNOWN], [暗], [暗],
)

=== 老师 JSON piece 枚举映射

#table(
  columns: (auto, auto),
  table.header([*JSON 值*], [*本组内部类型*]),
  [king], [KING（将/帅）],
  [advisor / guard], [ADVISOR（士/仕）],
  [bishop], [BISHOP（象/相）],
  [rook], [ROOK（车）],
  [knight], [KNIGHT（马）],
  [cannon], [CANNON（炮）],
  [pawn], [PAWN（兵/卒）],
  [unknown], [UNKNOWN（暗子未翻开）],
)

=== 颜色编码

#table(
  columns: (auto, auto, auto),
  table.header([*JSON 值*], [*内部枚举*], [*说明*]),
  [red], [RED], [先手/红方],
  [black], [BLACK], [后手/黑方],
)

== Move 对象规范

=== 字段规则

#table(
  columns: (auto, auto),
  table.header([*字段*], [*规则*]),
  [fromX, fromY], [源坐标；`fromX`=`a`–`i`，`fromY`=`0`–`9`],
  [toX, toY], [目标坐标；范围同上],
  [isFlip], [布尔值；`true` 表示本步会翻开棋子（暗子首动）；`source == destination` 为原地翻子（服务器拒绝）],
)

=== 翻子随机性机制

- 暗子真实 `piece` 类型在 `Board.initBoard()` 阶段已通过 `Collections.shuffle` 随机分配并写入棋盘；`RandomRevealService` 仅负责清除客户端伪造 `type`，走子后写回服务端真实类型，不在此步重新随机
- 客户端不可预测或控制翻子结果，`move` 请求中不指定预期类型
- `moveResult.flipResult` 包含 `{ x, y, piece }`，客户端据此更新本地棋盘

=== JSON move 对象格式

#json-snippet("move（C→S，含翻子）", "
{
  \"fromX\": \"b\",
  \"fromY\": 7,
  \"toX\": \"b\",
  \"toY\": 4,
  \"isFlip\": true
}
")

#json-snippet("moveResult（S→C，valid=true；captured 按红/黑视角差异化）", "
{
  \"messageType\": \"moveResult\",
  \"roomId\": \"abc123\",
  \"valid\": true,
  \"move\": { \"fromX\": \"b\", \"fromY\": 7, \"toX\": \"b\", \"toY\": 4, \"isFlip\": true },
  \"flipResult\": { \"x\": \"b\", \"y\": 4, \"piece\": \"cannon\" },
  \"captured\": { \"color\": \"red\", \"piece\": \"pawn\", \"wasDark\": false },
  \"currentTurn\": \"black\",
  \"moveTime\": 3421
}
")

== 完整消息类型规范

=== 客户端 → 服务器消息

#table(
  columns: (auto, auto, auto),
  table.header([*messageType*], [*说明*], [*本组实现*]),
  [Login], [登录认证，含 userId/password/nickname/avatar], [#ok],
  [register], [注册新用户], [#ok],
  [startMatch], [发起随机匹配], [#ok],
  [cancelMatch], [取消匹配], [#ok],
  [startAiGame], [发起人机对弈，含 aiLevel（easy/medium/hard）], [#ok],
  [startAiBattle], [AI 自动对弈观战，含 aiLevel1/aiLevel2], [#ok],
  [createRoom], [创建房间], [#ok],
  [joinRoom], [加入房间，含 roomId], [#ok],
  [requestFirstHand], [争先手（true = 要先手 / false = 要后手）], [#ok],
  [Ready], [准备就绪], [#ok],
  [move], [走子请求，含 fromX/fromY/toX/toY/isFlip], [#ok],
  [chat], [聊天（≤ 120 字符）], [#ok],
  [Resign], [认输], [#ok],
  [drawOffer], [提和], [#ok],
  [drawAccept], [同意提和], [#ok],
  [drawDecline], [拒绝提和], [#ok],
  [rematchRequest], [请求重赛], [#ok],
  [rematchDecline], [拒绝重赛], [#ok],
  [replayRequest], [请求复盘帧，可选 stepIndex（默认最后一帧）], [#ok],
  [addTime], [手动加时（每步最多 2 次，每次 +60s）], [#ok],
  [pauseGame], [暂停对局（仅 AI 模式）], [#ok],
  [resumeGame], [恢复对局], [#ok],
  [watch], [观战请求，含 roomId], [#ok],
  [ping], [心跳保活，含 timestamp], [#ok],
)

#json-snippet("Login", "
{
  \"messageType\": \"Login\",
  \"userId\": \"player1\",
  \"password\": \"123456\",
  \"nickname\": \"隐形小炮兵\",
  \"avatar\": \"avatar_01\"
}
")

#json-snippet("startAiGame", "
{
  \"messageType\": \"startAiGame\",
  \"aiLevel\": \"medium\"
}
")

#json-snippet("move（含翻子）", "
{
  \"messageType\": \"move\",
  \"fromX\": \"b\",
  \"fromY\": 7,
  \"toX\": \"b\",
  \"toY\": 4,
  \"isFlip\": true
}
")

=== 服务器 → 客户端消息

#table(
  columns: (auto, auto, auto),
  table.header([*messageType*], [*说明*], [*本组实现*]),
  [loginResult], [登录结果，含 success/userId/nickname/avatar], [#ok],
  [matchSuccess], [匹配成功，含 roomId/opponentId/opponentNickname/opponentAvatar], [#ok],
  [roomInfo], [房间状态广播，含 opponentReady], [#ok],
  [gameStart], [对局开始，含 redPlayerId/blackPlayerId/yourColor/firstHand/initialBoard], [#ok],
  [moveResult], [走子结果，含 valid/move/flipResult/captured/currentTurn], [#ok],
  [flipResult], [翻子结果（单独消息兼容）], [#ok],
  [gameOver], [终局，含 winner/reason/winnerId/capturedReveal], [#ok],
  [timeout], [超时通知，含 loserId], [#ok],
  [chatMessage], [聊天广播，含 fromUserId/content/timestamp], [#ok],
  [drawOffered], [提和通知], [#ok],
  [drawDeclined], [拒和通知], [#ok],
  [rematchOffer], [重赛邀请], [#ok],
  [rematchDeclined], [重赛拒绝], [#ok],
  [replayFrame], [复盘帧，含 stepIndex/totalSteps/board/move/captured/currentTurn/status], [#ok],
  [timeBonus], [加时结果，含 turnStartTime/forColor], [#ok],
  [gamePaused], [暂停通知], [#ok],
  [gameResumed], [恢复通知], [#ok],
  [pong], [心跳响应], [#ok],
  [error], [错误通知，含 errorCode/message], [#ok],
)

#json-snippet("loginResult", "
{
  \"messageType\": \"loginResult\",
  \"success\": true,
  \"userId\": \"player1\",
  \"nickname\": \"隐形小炮兵\",
  \"avatar\": \"avatar_01\"
}
")

#json-snippet("matchSuccess", "
{
  \"messageType\": \"matchSuccess\",
  \"roomId\": \"1ca389\",
  \"opponentId\": \"ai-bot-medium\",
  \"opponentNickname\": \"标准 AI\",
  \"opponentAvatar\": \"bot\"
}
")

#json-snippet("gameStart", "
{
  \"messageType\": \"gameStart\",
  \"roomId\": \"1ca389\",
  \"redPlayerId\": \"player1\",
  \"blackPlayerId\": \"ai-bot-medium\",
  \"yourColor\": \"red\",
  \"firstHand\": true,
  \"initialBoard\": [
    { \"x\": \"a\", \"y\": 0, \"color\": \"red\", \"piece\": \"rook\", \"visible\": false },
    { \"x\": \"e\", \"y\": 0, \"color\": \"red\", \"piece\": \"king\", \"visible\": true },
    ...   // 共 32 个棋子
  ]
}
")

#json-snippet("moveResult（valid=true，含 captured 信息差）", "
{
  \"messageType\": \"moveResult\",
  \"roomId\": \"1ca389\",
  \"valid\": true,
  \"move\": { \"fromX\": \"b\", \"fromY\": 7, \"toX\": \"b\", \"toY\": 4, \"isFlip\": true },
  \"flipResult\": { \"x\": \"b\", \"y\": 4, \"piece\": \"cannon\" },
  \"captured\": { \"color\": \"red\", \"piece\": \"pawn\", \"wasDark\": false },
  \"currentTurn\": \"black\"
}
")

#json-snippet("moveResult（valid=false，非法走法）", "
{
  \"messageType\": \"moveResult\",
  \"roomId\": \"1ca389\",
  \"valid\": false,
  \"message\": \"非法走法\"
}
")

#json-snippet("gameOver（capturedReveal 揭晓全部暗子身份）", "
{
  \"messageType\": \"gameOver\",
  \"roomId\": \"1ca389\",
  \"winner\": \"black\",
  \"reason\": \"checkmate\",
  \"winnerId\": \"ai-bot-medium\",
  \"capturedReveal\": [
    { \"color\": \"red\", \"piece\": \"rook\", \"wasDark\": true },
    { \"color\": \"black\", \"piece\": \"cannon\", \"wasDark\": true },
    ...
  ]
}
")

#json-snippet("error", "
{
  \"messageType\": \"error\",
  \"errorCode\": 2001,
  \"message\": \"非法走法\"
}
")

=== 公共数据结构

*initialBoard* 数组：每元素 `{ x: "a"-"i", y: 0-9, color: "red"|"black", piece: "rook"|..., visible: true|false }`。visible = 是否明子。

=== 游戏结果原因（gameOver.reason）

#table(
  columns: (auto, auto),
  table.header([*reason*], [*说明*]),
  [checkmate], [将死 — 被将军且无合法走法],
  [stalemate], [困毙 — 无合法走法且未被将军],
  [timeout], [超时 — 单步超过 65 秒],
  [resign], [认输 — 玩家主动认输],
  [disconnect], [断线 — WebSocket 意外关闭],
  [ruleViolation], [规则违例 — 长将判负等],
  [abandoned], [放弃 — 离开房间],
  [draw], [和棋 — 40 步无吃子 / 双方同意],
)

=== 错误码

#table(
  columns: (auto, auto),
  table.header([*错误码*], [*含义*]),
  [1001], [登录失败 — 用户不存在或密码错误],
  [2001], [非法走法 — 棋子规则不允许],
  [2002], [送将 — 走子后己方被将军],
  [3001], [匹配失败 — 已在匹配/房间中],
  [3002], [房间不存在或已满],
  [4001], [超时局终],
  [5001], [消息格式解析失败 / 未知消息类型],
)

== 典型通信时序

=== 匹配与先手协商

#seq-diagram(
  "
      Client A                    Server                    Client B
            |                         |                         |
            |------ Login ----------->|                         |
            |<----- loginResult ------|                         |
            |                         |<------ Login -----------|
            |                         |------ loginResult ----->|
            |------ startMatch ------>|                         |
            |                         |<------ startMatch -------|
            |<---- matchSuccess ------|---- matchSuccess ------>|
            |------ Ready ----------->|------ Ready ----------->|
            |<-- requestFirstHand --->|<-- requestFirstHand ---->|
            |                         |   (10s 窗口协商先手)     |
            |<---- gameStart ---------|<---- gameStart --------->|
  ",
  [登录 → 匹配 → Ready → 先手协商 → 开局],
  roles: [#grid(columns: (1fr, 1fr, 1fr), align: center, [客户端 A], [服务器], [客户端 B])],
)

#img("diag_seq_full_match_flow.png", width: 90%, caption: [完整对弈流程时序 — 登录 → 匹配 → Ready → 先手协商 → 走子 → 终局])

=== 正常走子与翻子

#seq-diagram(
  "
      Client A (Red)              Server              Client B (Black)
            |                         |                         |
            |------ move ------------>|                         |
            |   b7→b4 (isFlip:true)  |                         |
            |<---- moveResult --------|---- moveResult -------->|
            |   flipResult: cannon    |                         |
            |                         |<------ move ------------|
            |                         |   h6→h4 (isFlip:true)  |
            |<---- moveResult --------|---- moveResult -------->|
            |                         |   flipResult: knight    |
            |       ... loop until gameOver ...                 |
  ",
  [走子与翻子：move → 服务器执行 + RevealService → moveResult 广播双方],
  roles: [#grid(columns: (1fr, 1fr, 1fr), align: center, [红方], [服务器], [黑方])],
)

=== 非法着法

#seq-diagram(
  "
      Client A                    Server
            |                         |
            |------ move ------------>|
            |   illegal move          |
            |<-- error(2001) 非法走法 --|
            |<-- moveResult valid=false
  ",
  [非法着法：仅发送方收到 error + valid=false 的 moveResult],
  roles: [#grid(columns: (1fr, 1fr), align: center, [客户端 A], [服务器])],
)

=== 超时判负

#seq-diagram(
  "
      Client A (Red)              Server
            |                         |
            |   (no move within 65s)  |
            |<-- timeout -------------|
            |<-- gameOver ------------|
  ",
  [超时：服务器广播 timeout + gameOver（reason=timeout）],
  roles: [#grid(columns: (1fr, 1fr), align: center, [红方], [服务器])],
)

#img("diag_seq_timeout_65s.png", width: 90%, caption: [65 秒步时超时机制 — 定时器、超时检测、gameOver 广播全链路])

=== 认输

#seq-diagram(
  "
      Client A                    Server                    Client B
            |                         |                         |
            |-------- Resign -------->|                         |
            |<------ gameOver -------|------ gameOver -------->|
            |  reason=resign          |                         |
  ",
  [认输：广播 gameOver（reason=resign）],
  roles: [#grid(columns: (1fr, 1fr, 1fr), align: center, [客户端 A], [服务器], [客户端 B])],
)

=== 提和流程

#seq-diagram(
  "
      Client A                    Server                    Client B
            |                         |                         |
            |----- drawOffer -------->|                         |
            |<---- drawOffered -------|---- drawOffered ------->|
            |                         |<----- drawAccept --------|
            |<----- gameOver ---------|----- gameOver --------->|
            |  reason=draw            |                         |
  ",
  [提和：A 提和 → B 同意 → gameOver（reason=draw）],
  roles: [#grid(columns: (1fr, 1fr, 1fr), align: center, [客户端 A], [服务器], [客户端 B])],
)

#img("diag_seq_draw_resign_flow.png", width: 90%, caption: [提和与认输流程 — drawOffer / drawAccept / drawDecline / resign 时序])

=== 复盘请求

#seq-diagram(
  "
      Client                     Server
            |                         |
            |--- replayRequest ------>|
            |   stepIndex: 5          |
            |<-- replayFrame ---------|
            |   step:5 totalSteps:42  |
            |   board + move + status |
            |                         |
            |--- replayRequest ------>|
            |   (no stepIndex)        |
            |<-- replayFrame ---------|
            |   step:41 (last frame)  |
  ",
  [复盘：replayRequest → server 查 timeline → replayFrame（每帧带完整 board 快照）],
  roles: [#grid(columns: (1fr, 1fr), align: center, [客户端], [服务器])],
)

=== 断线判负

#seq-diagram(
  "
      Client A                    Server                    Client B
            |                         |                         |
            |   (connection close)    |                         |
            |                         |------ gameOver -------->|
            |                         |  reason=disconnect      |
  ",
  [一方 WebSocket 关闭：对方收到 gameOver（reason=disconnect）],
  roles: [#grid(columns: (1fr, 1fr, 1fr), align: center, [客户端 A], [服务器], [客户端 B])],
)

== 本组扩展消息总览

除课程公共消息外，本组额外扩展以下消息类型：

#table(
  columns: (auto, auto, auto),
  table.header([*messageType*], [*方向*], [*说明*]),
  [startAiGame], [C→S], [人机对弈，含 aiLevel（easy/medium/hard）],
  [startAiBattle], [C→S], [AI 自动对弈观战],
  [replayRequest], [C→S], [请求复盘帧，可选 stepIndex],
  [replayFrame], [S→C], [复盘帧：stepIndex/totalSteps/board/move/captured],
  [rematchRequest], [C→S], [请求重赛],
  [rematchOffer / rematchDeclined], [S→C], [重赛邀请/拒绝],
  [addTime], [C→S], [手动加时 +60s（每步最多 2 次）],
  [timeBonus], [S→C], [加时结果通知],
  [watch], [C→S], [观战请求],
  [pauseGame / resumeGame], [C→S], [暂停/恢复（AI 模式）],
  [gamePaused / gameResumed], [S→C], [暂停/恢复通知],
)

== 协议实现状态

以下对照课程公共协议 v3.1 列出每条消息的代码实现状态。`公共协议` 表示 INTERFACE.typ 规定的标准消息；`本组扩展` 表示为支持复盘、重赛等功能新增的消息类型。

#table(
  columns: (0.9fr, 0.6fr, 0.5fr, 0.5fr, 0.45fr, 1.3fr),
  table.header([*消息类型*], [*协议来源*], [*服务端*], [*控制台*], [*Web*], [*说明*]),
  [`login`], [公共协议], [#ok], [#ok], [#ok], [Web 额外支持昵称与预设头像],
  [`startMatch`], [公共协议], [#ok], [#ok], [#ok], [真人对战匹配],
  [`startAiGame`], [公共协议], [#ok], [#ok], [#ok], [人机三档难度选择],
  [`move`], [公共协议], [#ok], [#ok], [#ok], [服务端权威校验，客户端仅交互预检],
  [`moveResult`], [公共协议], [#ok], [#ok], [#ok], [含 flipResult + captured],
  [`gameOver`], [公共协议], [#ok], [#ok], [#ok], [含 capturedReveal 终局揭晓],
  [`chat` / `chatMessage`], [公共协议], [#ok], [#ok], [#ok], [≤ 120 字符校验，仅真人可用],
  [`drawOffer` / `drawAccept`], [公共协议], [#ok], [#ok], [#ok], [双方确认和棋],
  [`resign`], [公共协议], [#ok], [#ok], [#ok], [主动认输],
  [`timeout`], [公共协议], [#ok], [#ok], [#ok], [服务端 65s 步时计时器],
  [`replayRequest` / `replayFrame`], [本组扩展], [#ok], [#ok], [#ok], [仅终局后开放；Web 复盘依赖房间在内存中],
  [`rematchRequest` / `rematchOffer`], [本组扩展], [#ok], [#ok], [#ok], [双方同意后新 gameStart],
  [`addTime`], [本组扩展], [#ok], [#ok], [#ok], [手动加时 +30s，每局限 2 次],
  [`pauseGame` / `resumeGame`], [本组扩展], [#ok], [#ok], [#ok], [AI 模式专用],
  [`watch`], [本组扩展], [#no], [#ok], [#warn], [控制台观战已实现；Web 待实现],
)

// ═══════════════════════════════════════════════════════════
// 第四章：规则引擎设计
// ═══════════════════════════════════════════════════════════
= 规则引擎设计

规则引擎位于 `jieqi-core` 模块，核心类包括 `Board`、`ChessPiece`、`Move`、`RuleValidator` 和 `Game`。`Board` 负责维护棋盘、棋子列表、走法执行、吃子和回滚；`ChessPiece` 负责保存棋子的真实类型、虚拟类型、颜色和翻开状态；`RuleValidator` 负责判断单步走法是否合法；`Game` 负责对局状态、回合切换、超时、棋谱、复盘和终局判定。

揭棋与标准象棋最大的区别在于：除将帅外，大部分棋子开局为暗子。暗子具有两个类型字段：`type` 表示真实类型，`virtualType` 表示当前位置对应的虚拟走子类型。未翻开的暗子按照 `virtualType` 生成走法，移动后翻开并显示真实 `type`。因此，揭棋同时具有"标准象棋走法约束"和"暗子信息不完全"的特点。

== 七种棋子走法速查

`RuleValidator` 的走法判断流程为：先根据坐标找到源棋子和目标格，确认源棋子存在、颜色属于当前行棋方、目标格不是己方棋子；然后拒绝原地翻子；最后通过 `piece.getMoveType()` 取得当前应使用的走法类型——对于暗子返回 `virtualType`，对于明子返回真实 `type`。因此，暗子在未翻开前不会暴露真实身份。

#table(
  columns: (auto, 1fr, auto),
  table.header([*棋子*], [*走法规则*], [*暗/明差异*]),
  [车 / 俥], [同行或同列直线移动，路径中间不能有棋子；吃子时目标格必须为对方棋子], [无差异],
  [马 / 傌], [走日字 `(±2,±1)` 或 `(±1,±2)`；前进方向相邻格有子则蹩马腿，禁止跳跃], [无差异],
  [炮 / 砲], [平移时路径中不能有棋子；吃子时路径中必须恰好有一个炮架；无炮架不能吃子], [无差异],
  [兵 / 卒], [未过河只能向前走 1 格；过河后可向前或左右平移 1 格；不能后退], [无差异],
  [将 / 帅], [在九宫内上下左右移动 1 格；不能造成将帅照面], [开局即为明子],
  [士 / 仕], [斜走 1 格], [暗士限九宫；明士可全场斜走，不再受九宫限制],
  [象 / 相], [走田字，即斜向移动 2 格；中点有子则塞象眼，禁止移动], [暗象不过河；明象可过河，但仍受塞象眼限制],
)

== 暗子特殊规则

#table(
  columns: (auto, 1fr),
  table.header([*规则*], [*说明*]),
  [走法按 `virtualType`], [暗子不暴露真实身份，走法按照当前位置对应的虚拟类型生成。例如底线车位暗子即使真实身份不是车，未翻开前仍按车的走法移动],
  [真实类型开局已随机分配], [棋盘初始化时，`Board.initBoard()` 对双方 15 个暗子池做 `Collections.shuffle` 洗牌，真实 `type` 已写入棋盘的 `ChessPiece.type` 字段],
  [客户端不能指定翻子结果], [客户端上传的 `type` 会被 `RandomRevealService` 清除；最终翻开什么由服务端棋盘中的真实 `type` 决定；`RandomRevealService` 不在此步重新随机分配],
  [首次移动后翻开], [暗子一旦完成合法移动，`revealed = true`，显示其真实 `type`],
  [暗士限九宫], [未翻开的士按照标准象棋士的规则移动，只能在本方九宫内斜走 1 格],
  [明士可出九宫], [士翻开后获得强化效果，可在全棋盘范围内斜走 1 格],
  [暗象不过河], [未翻开的象按照标准象棋象的规则移动，走田字、受塞象眼限制，并且不能过河],
  [明象可过河], [象翻开后获得强化效果，可以过河，但仍然必须走田字，且仍然受塞象眼限制],
  [禁止原地翻子], [`source == destination` 或 `isFlipOnly` 时服务器拒绝；正式对局入口 `Game.processMove` 阻止原地翻子（`Board.executeMove` 中仅保留兼容早期测试的 `flipOnly` 分支）],
  [无吃子移动], [普通移动若未吃子则递增 `noCaptureCount`（每次移动 +1）；发生吃子则 `noCaptureCount = 0`（`noCaptureCount ≥ 80` 时判和，即 80 个半步无吃子、双方合计 40 回合）],
)

== 暗子真实类型与虚拟类型

每个暗子同时包含两个类型，外加翻开状态：

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*字段*], [*含义*], [*作用*]),
  [`type`], [真实类型], [暗子翻开后的实际棋子身份；开局已随机分配],
  [`virtualType`], [虚拟类型], [暗子未翻开时用于生成走法；由开局位置决定],
  [`revealed`], [是否翻开], [决定当前走法使用 `type` 还是 `virtualType`],
)

未翻开时 `moveType = virtualType`，翻开后 `moveType = type`。

例如，一个位于车位的暗子，`virtualType` 是 `ROOK`，因此未翻开前按车走；但它的真实 `type` 可能是 `CANNON`，移动后翻开就会变成炮。这个机制是揭棋的核心不确定性来源，也是 AI 不能直接透视对手暗子的原因，以及复盘必须保存棋盘快照而非仅走法文本的根本原因。

== 服务端权威校验

对局中，客户端只负责发送走法，最终是否合法由服务器判断。服务端收到 `move` 消息后，会先解析源坐标和目标坐标，然后清除客户端可能伪造的棋子类型，再交给 `Game.processMove` 处理：

#arch-diagram(
  "
  Game.processMove
    │
    ├─[1] 对局状态 == PLAYING?   ──否→ 拒绝
    ├─[2] 轮到当前玩家?          ──否→ 拒绝
    ├─[3] 已超时? (65s)          ──是→ 终局: TIMEOUT
    ├─[4] 原地翻子?               ──是→ 拒绝
    ├─[5] RuleValidator.isValidMove     ──否→ 拒绝: 非法走法 (2001)
    ├─[6] RuleValidator.isMoveLegal     ──否→ 拒绝: 不能送将 (2002)
    │
    ├─[7] Board.executeMove     ← 执行走子 / 翻子 / 吃子
    ├─[8] GameRecord.append     ← 文字棋谱追加
    ├─[9] ReplayTimeline.record ← 复盘快照
    │
    └─[10] EndgameJudge.checkAfterMove
          ├─ 有终局 → gameOver 广播 + 棋谱/replay 落盘
          └─ 无终局 → moveResult 广播 + 轮次切换
  ",
  caption: [服务端走子校验全链路 — 客户端不能通过伪造 `type`、伪造翻子结果或发送非法坐标改变服务器权威棋局],
)

这种设计保证了客户端无法通过伪造 `type`、伪造翻子结果或发送非法坐标来改变服务器权威棋局。

== 将军、送将与将帅照面

普通几何走法合法并不代表最终合法。系统还会通过试走方式判断走完后己方是否被将军。如果某一步虽然满足棋子走法，但会导致己方将帅被攻击，系统会拒绝该走法并返回"不能送将"。

将帅照面也在规则引擎中处理：如果双方将帅位于同一列，且中间没有任何棋子阻挡，则认为当前局面存在将帅照面风险。相关判断被纳入 `isInCheck`，从而影响合法走法生成、将军判断和终局判定。

== 校验流程

两层校验职责分离——这是标准象棋引擎的 `generate-and-test` 范式，搜索树与服务器校验共用同一套逻辑：

#table(
  columns: (1.2fr, 1.8fr, 2fr),
  table.header([*方法*], [*检查内容*], [*不检查*]),
  [`isValidMove`], [几何走法合法性、阵营归属、棋子类型规则], [是否送将],
  [`isMoveLegal`], [试走一子后己方是否被将军（make/unmake 模拟）], [—],
  [`generateStrictLegalMoves`], [枚举全部几何走法 → `makeMove` → `isInCheck` → `undoMove`，过滤送将步], [—],
)

局面哈希：`Board.positionKey(board, sideToMove)` 采用*字符串键*（10×9 格子 + `|` + sideToMove，暗子用 `?` 占位），用于长将/长捉重复局面计数。发生吃子时清空所有 `repetitionCount`。AI 置换表（TT）则使用独立的 64-bit Zobrist XOR 哈希（`ZobristHash.computeHash`，仅 `jieqi-ai`），两者并行存在、尚未统一。

== 规则引擎设计特点

1. *走法与对局状态分离*：`RuleValidator` 只负责判断单步规则，`Game` 负责回合、超时、棋谱、终局和复盘
2. *暗子走法统一抽象*：外部规则判断不需要关心棋子是否翻开，只需调用 `getMoveType()`，由 `ChessPiece` 内部决定返回 `virtualType` 还是 `type`
3. *服务端权威翻子*：客户端不能决定暗子翻开后的真实身份，服务器清除客户端上传的类型并以棋盘真实状态为准
4. *强化规则局部化*：士和象的强化逻辑集中在 `RuleValidator` 的对应方法中，暗子走标准规则、明子走强化规则，便于测试和维护
5. *支持 AI 搜索与回滚*：`Board` 提供 `makeMove` / `unmakeMove` 快照机制，供合法走法生成和 AI 搜索使用，避免搜索过程污染真实棋局

== 终局判定

入口：`EndgameJudge.checkAfterMove`，在 `Board.executeMove` 与棋谱记录之后调用。按固定优先级依次判定，返回 `null` 表示对局继续。

#arch-diagram(
  "
  吃子发生 → 清空 repetitionCount
     │
     ├─ 吃掉明将？              → 走子方胜 (KING_CAPTURED)
     ├─ 对方被将死？            → 走子方胜 (CHECKMATE)
     ├─ 对方困毙？              → 走子方胜 (STALEMATE)
     ├─ noCaptureCount >= 80？ → 和棋 (NO_CAPTURE_DRAW)
     │
     ├─ 更新 repetitionCount[boardHash]
     ├─ 重复 >= 6 次？
     │    ├─ 将军中 → 长将判负
     │    ├─ 兵卒长捉 → 和棋
     │    └─ 长捉 → 判负
     │
     └─ 继续对弈
  ",
  caption: [终局判定优先级流程],
)

*重复计数维护*：每步 `count = repetitionCount[key] + 1`；发生吃子 → 清空全部重复计数（局面本质变化）。

*长捉检测（`findChaseTarget`）*：走子后，若 destination 上的棋子可对某一对方子生成合法吃子走法 → 视为"捉"。当前实现用 `isValidMove` 近似"捉"，尚未区分将/杀/捉、隔子捉/连环捉等裁判细节。

*将军检测（`isInCheck`）*：枚举对方所有子的几何攻击 + 将帅照面（同列无遮挡）。

== 测试覆盖

#table(
  columns: (1.2fr, 1.8fr, 0.6fr, 1.4fr),
  table.header([*领域*], [*测试类*], [*状态*], [*说明*]),
  [七种走法], [`BoardMakeMoveTest`、`DarkPieceRuleTest`], [#ok], [含暗士暗象 + 明士明象强化],
  [送将 / 照面 / 解将], [`RuleEdgeCaseTest` (11 项矩阵)], [#ok], [—],
  [将死 / 困毙 / 吃将], [`EndgameJudgeTest`、`RuleEdgeCaseTest`], [#ok], [—],
  [40 步无吃子], [`RuleEdgeCaseTest`], [#ok], [—],
  [undo / 搜索一致性], [`BoardUndoTest`、`aiSearchMakeUnmakePreservesBoardHash`], [#ok], [make/unmake 后 hash 不变],
  [纯重复无将军无捉], [`EndgameJudgeTest.aiSearchMakeUnmake- PreservesBoardHash`], [#ok], [6 次重复不终局],
  [长将], [`RuleEdgeCaseTest`], [#warn], [主路径已实现；缺真实对局集成测],
  [长捉], [`RuleEdgeCaseTest`], [#warn], [3 个局面通过；将/杀/捉未细分],
  [错误原因码], [—], [#no], [`RuleValidator` 返回 `boolean`，未细化],
)

P0 规则主路径（走子、送将、照面、将死/困毙、40 步和）可标 #ok 已实现。长将/长捉标 #warn 是准确的——不是没做，而是裁判粒度不够细（见 §13 已知限制与路线图）。

// ═══════════════════════════════════════════════════════════
// 第五章：AI 算法设计
// ═══════════════════════════════════════════════════════════
= AI 算法设计

== 问题形式化

揭棋在算法上是一个有限步、双人对弈、*不完全信息的零和博弈*：

#table(
  columns: (auto, 1fr),
  table.header([*信息类型*], [*内容*]),
  [完全信息], [明子真实身份、将帅位置、已翻开历史],
  [不完全信息], [对手 15 枚暗子的真实 `type`（仅知 `virtualType`，即开局原位角色）],
)

状态空间定义：

#table(
  columns: (auto, 1fr),
  [*状态*], [10×9 棋盘 + `(color, type, virtualType, revealed)` 每子 + 轮次方 + `noCaptureCount` + `repetitionCount`],
  [*目标*], [在步时约束（约 60s + 5s 裕量）内输出严格合法走法；Hard 档还需在不透视对手暗子前提下近似最优],
)

== 规则引擎算法（RuleValidator + Board）

=== 两层合法性校验

采用*几何合法与战术合法分离*的标准象棋引擎 `generate-and-test` 范式，搜索树与服务器校验共用同一套逻辑：

#table(
  columns: (auto, auto, 1fr),
  table.header([*层次*], [*方法*], [*检查内容*]),
  [L1], [`isValidMove`], [阵营归属、目标格可达性、七种棋子几何走法],
  [L2], [`isMoveLegal`], [试走一子后己方是否被将军（禁送将）——make/unmake 模拟],
  [—], [`generateStrictLegalMoves`], [对所有几何走法逐一 `makeMove` → `isInCheck` → `undoMove`，过滤送将步],
)

=== 暗子走法依据：getMoveType()

#table(
  columns: (auto, 1fr),
  [`revealed == false`], [按 `virtualType`（原位角色）生成走法],
  [`revealed == true`], [按真实 `type` 生成走法],
)

=== 揭棋特有规则（算法分支）

*暗士 / 暗象（标准象棋约束）：*
- 暗士：斜走 1 格，限九宫内
- 暗象：田字走，不可过河，塞象眼有效

*明士 / 明象（强化规则）：*
- 明士：斜走 1 格，可出九宫（全场移动）
- 明象：田字走，可过河，塞象眼不变

*翻子机制（Board.executeMove）：*
- 暗子首次移动或吃子 → `revealed = true`
- 真实 `type` 在开局初始化时已随机分配：`Collections.shuffle` 对 15 子池洗牌后按格填入，走子时不重新随机
- `RandomRevealService` 仅做服务器权威校验：清除客户端伪造 `type`，走子后写回真实 `type`

*局面哈希（Board.positionKey）：*
- 编码：10×9 格子 + 待走方
- 暗子以 `?` 占位，不泄露真实身份
- 用于长将/长捉重复局面判定与 AI 长将规避

== 终局判定算法（EndgameJudge）

走子后按*固定优先级*依次判定，返回 `null` 表示对局继续：

#table(
  columns: (auto, auto, 1fr),
  table.header([*优先级*], [*结果*], [*判定条件*]),
  [1. 吃将], [`KING_CAPTURED` → 走子方胜], [对方将/帅被吃],
  [2. 将死], [`CHECKMATE` → 走子方胜], [`isInCheck` ∧ 无合法解将步],
  [3. 困毙], [`STALEMATE` → 走子方胜], [`¬isInCheck` ∧ 无任何合法步],
  [4. 无吃子和], [和棋], [`noCaptureCount ≥ 80`（80 个半步无吃子，即双方合计 40 回合无吃子判和）],
  [5. 重复局面], [见下文], [同一 `positionKey` 累计次数 ≥ 6],
)

*重复局面子判定（`positionKey` 计数 ≥ 6 时）：*
- 仍在将军 → 将军方判负（长将）
- 未将军但合法捉子 → 走子方判负（长捉）；*兵卒长捉 → 和棋*

*重复计数维护：*
- 每步 `count = repetitionCount[key] + 1`
- 发生吃子 → 清空全部重复计数（局面本质变化）

*长捉检测（findChaseTarget）：* 走子后，若 destination 上的棋子可对某一对方子生成合法吃子走法 → 视为「捉」。

*将军检测（isInCheck）：* 枚举对方所有子的几何攻击 + 将帅照面（同列无遮挡）。

== AI 三档架构

#table(
  columns: (auto, auto, auto, auto),
  table.header([*档位*], [*实现类*], [*核心算法*], [*时间预算*]),
  [Easy], [`EasyRuleBot`], [启发式排序 + Top-K 随机], [≤ 500ms],
  [Medium], [`AlphaBetaBot` → `JieqiAgent`], [公开视角 Alpha-Beta + Agent 编排], [可配置，默认 ~5s],
  [Hard], [`BeliefAlphaBetaBot`], [Belief Sampling + 多次 Alpha-Beta 期望], [~5s（默认 4 采样 × 6 候选）],
)

=== Easy：启发式 + 随机

1. `createAiPublicView(color)` 脱敏
2. `generateLegalMoves` → `MoveOrderer.sortByHeuristic`（MVV-LVA 排序）
3. 30% 全随机；70% 从 Top-8 中随机

无搜索树，保证毫秒级响应与合法输出。

=== Medium：Agent 编排 + Alpha-Beta

`AgentOrchestrator` 按优先级串行调度三个子 Agent：

#table(
  columns: (auto, auto, 1fr),
  table.header([*优先级*], [*Agent*], [*职责*]),
  [10], [`ProbabilityAgent`], [设置 `evalBias` 注入评估偏置，不直接选着],
  [20], [`EndgameAgent`], [子力 ≤ 12 时接管搜索，加深时间上限至 30s],
  [100], [`SearchAgent`], [默认主搜索（Alpha-Beta + 迭代加深）],
)

*信息约束：* 所有搜索在 `createAiPublicView` 脱敏棋盘上进行——己方暗子保留真实 `type`，对手暗子 `type = UNKNOWN`。

== Alpha-Beta 搜索引擎（OptimizedAlphaBeta）

=== 框架：Negamax + 迭代加深（ID）

#mono-lines(
  "
  for depth = 1 .. MAX_DEPTH(20):
      aspiration search(depth, window = bestScore ± 80)
      if fail-low / fail-high → 全窗口重搜
      if 剩余时间 < 2 × 上一层耗时 → 停止加深
  return 已完成层的最优走法
  ",
  title: [迭代加深主循环],
)

*Anytime 特性：* 任一层超时即返回上一层结果，避免空步响应。

=== 剪枝与加速技术

#table(
  columns: (auto, 1fr),
  table.header([*技术*], [*实现要点*]),
  [Alpha-Beta 剪枝], [标准 negamax，α/β 窗口传递],
  [Aspiration Window], [±80 缩窗；失败时扩至 [-INF, +INF]],
  [PVS], [首变全窗口；后续 null-window 试探 + 推高后重搜],
  [LMR 晚着减少], [quiet move + searched ≥ 4 + depth ≥ 3 + 非 PV → depth − 1],
  [置换表 TT], [Zobrist 64-bit 哈希，2²⁰ 槽位替换；存 `(depth, score, flag, bestMove)`；flag: EXACT / ALPHA / BETA],
  [Killer Heuristic], [每层记录 2 个 β-cutoff 走法，兄弟节点优先尝试],
  [History Heuristic], [推高 α 的走法累积历史分值；每 4 层 aging 衰减],
  [Move Ordering], [TT best → MVV-LVA → 翻子/暗子 → killer → history → 中心偏好],
  [静态搜索 Quiescence], [叶子 `depth = 0` 后仅扩展吃子，最多 3 层],
  [SEE 过滤], [静态搜索中 `SEE < 0` 的亏交换直接跳过],
  [长将规避], [`repetition[key] + 1 ≥ 5` 且仍在将军 → 该步 `score − 100000`],
)

=== 静态交换评估 SEE（StaticExchangeEvaluator）

对给定吃子着法，在目标格模拟双方依次用最便宜攻击子互吃的序列，反向 minimax 求当前方净收益：

#table(
  columns: (auto, 1fr),
  [`SEE > 0`], [赚的交换，优先搜索],
  [`SEE = 0`], [等值交换],
  [`SEE < 0`], [亏的交换（如车换卒），quiescence 中跳过],
)

不精确处理炮的 X-ray 遮挡，但对明显亏交换足够有效。

=== Zobrist 哈希（ZobristHash）

`hash = hash XOR table[row][col][color][state]`，其中 `state = revealed ? type + 1 : 0`。用于 TT 索引，与 `positionKey` 字符串哈希并行存在，服务不同场景。

== 局面评估函数（EnhancedEvaluator）

采用*线性加权多特征模型*，从当前方视角返回 `score`（正值 = 有利）：

=== 七维特征

#table(
  columns: (auto, 1fr),
  table.header([*维度*], [*算法*]),
  [子力 Material], [明子固定值：将 10000、车 900、马 400、炮 450、兵 50、士象 200；过河兵/过河士象额外加成],
  [暗子期望], [每个未翻子按 `virtualType` 基准值取平均 × 数量 + 暗子奖励 +5/子],
  [位置 PST], [车/马/炮/兵 10×9 位置分表，中心与过河加权],
  [机动性 Mobility], [合法走法数 × 3],
  [将帅安全 King Safety], [士象护卫 +30/邻格；己方将越靠后 +10/行；被将军 −150],
  [威胁 Threats], [对方最便宜攻击子 vs 我方子价值 → MVV-LVA 式挂子惩罚],
  [兵形 Pawn Structure], [相邻兵 +10],
  [残局猎杀 King Hunt], [对方非王子力 < 1500 时激活：攻击子逼近对方将 + 压缩将活动空间 + 已将军 +80],
)

=== 暗子子力处理（Expectimax 思想的静态近似）

评估阶段不对暗子做蒙特卡洛，而用 `virtualType` *期望值*：

```
darkValueSum += getBaseValue(virtualType)
material += (darkValueSum / darkCount) * darkCount
```

这是不完全信息下的一阶矩估计，计算代价 O(暗子数)，适合搜索内高频调用。

=== 概率偏置（ProbabilityAgent）

搜索前计算：

```
evalBias = getExpectedValue(己方) - getExpectedValue(对手)
```

注入 quiescence 的 `standPat` 与叶子评估，使搜索在暗子较多时偏向「暗子池期望值更高」的一方，不直接选着。

== Hard 档：Belief Sampling（BeliefAlphaBetaBot）

这是处理对手暗子不确定性的核心算法，属于 *Expectimax / 信念状态采样*的工程实现。

=== 算法流程

#mono-lines(
  "
  输入: authoritativeBoard, color, timeBudget

  1. publicView = createAiPublicView(color)
  2. candidates = Top-K 启发式排序后的合法走法（K ≤ 6）
  3. 对每个候选走法 m:
       expectedScore = 0
       for s = 1 .. N (默认 N = 4):
           sampleBoard = BoardSampler.fromPublicView(publicView, color, rng)
           // 对对手每个暗子，从剩余子力池无放回随机分配 type
           makeMove(m) on sampleBoard
           score_s = AlphaBeta(sampleBoard, opp, perSampleBudget)
           expectedScore += -score_s   // negamax 对手视角取反
       E[m] = expectedScore / usedSamples
  4. return argmax_m E[m]
  ",
  title: [Belief Sampling 主循环],
)

=== 剩余子力池约束（BoardSampler）

初始池 = {2 车, 2 马, 2 炮, 5 兵, 2 士, 2 象}（不含将/帅）。减去对手已翻开明子的 `type` 计数，对 hidden 暗子 `shuffle` 后逐一分配。保证采样与已公开信息一致——不会出现"场上已有 2 车再采样第 3 车"的逻辑错误。

=== 时间分配

```
perSample = max(30ms, remaining / remainingSlots)
budget < 3s → 降级为 2 采样 × 4 候选
```

每次采样独立 `new OptimizedAlphaBeta()`，避免 TT 跨采样污染。

=== 理论定位

- *不是*精确博弈树求解（那需要 POMDP / 信息集搜索，指数级复杂度）
- *是*对对手 `type` 的蒙特卡洛*确定化* + 完全信息 Alpha-Beta 的*期望最大化*
- 与 Medium 的本质区别：Medium 把对手暗子当 `UNKNOWN` 固定评估；Hard 对 `type` 分布多次采样取期望

== 算法整体数据流

*客户端 moveRequest 路径：*

#arch-diagram(
  "
  客户端 moveRequest
      ↓
  Game.processMove
      ├─ RuleValidator.isValidMove      (几何合法性)
      ├─ RuleValidator.isMoveLegal      (不送将校验)
      ├─ Board.executeMove              (翻子/吃子/计数维护)
      ├─ EndgameJudge.checkAfterMove    (终局判定)
      └─ ReplayTimeline.record          (快照记录)
  ",
  caption: [走子处理数据流 — 规则引擎 + 终局 + 复盘记录],
)

*AI 选着路径（Hard 档为例）：*

#arch-diagram(
  "
  createAiPublicView (对手暗子脱敏)
      ↓
  MoveOrderer → Top-K 候选走法
      ↓
  for each candidate:
      BoardSampler × N 次采样
          ↓
      OptimizedAlphaBeta (ID + AB + TT + QS + SEE)
          ↓
      EnhancedEvaluator + evalBias (概率偏置)
      ↓
  argmax E[score] (期望最大化选择)
      ↓
  RuleValidator.isMoveLegal(authoritativeBoard)  // 最终合法性兜底
  ",
  caption: [AI 选着全链路 — Belief Sampling → Alpha-Beta → 期望最大化 → 合法性兜底],
)

== AI 测试

#table(
  columns: (auto, auto, auto),
  table.header([*用例*], [*验证内容*], [*结果*]),
  [AiFairnessTest], [AI 不透视对手暗子；三档输出均为合法走法], [#ok],
  [BoardUndoTest], [搜索中 `makeMove` / `undoMove` 棋盘一致性], [#ok],
  [TranspositionTableTest], [TT 命中率与正确性（64-bit Zobrist 哈希碰撞验证）], [#ok],
)

== 已知算法局限

#table(
  columns: (auto, 1fr),
  table.header([*局限*], [*如实说明*]),
  [Belief 采样数有限], [默认 4×6 采样；对方 type 后验未建模（均匀剩余池采样，未考虑走法意图）],
  [暗子评估用均值], [`virtualType` 一阶矩估计，未做二阶不确定性惩罚（方差未建模）],
  [Hard 独立 TT], [每采样独立 `new OptimizedAlphaBeta()`，正确但重复计算多；默认 4 个 belief 采样 × 最多 6 个候选着法，实际搜索深度由局面分支数与时间预算决定，非固定 4–6 层],
  [长捉判定简化], [极端连环捉/隔子捉需人工复核],
  [无残局库], [残局依赖搜索到底 + EndgameAgent 加深（子力 ≤ 12 时 30s 预算）],
  [AI 视角翻子], [搜索中对手暗子翻开时用 `virtualType` 而非真实 `type`（防透视，但搜索树内翻子语义与真实对局略有偏差）],
)

== 三档 AI 代码对应表

#table(
  columns: (0.5fr, 0.9fr, 1.1fr, 0.6fr, 0.5fr, 1.5fr),
  table.header([*难度*], [*实现类*], [*核心策略*], [*时间*], [*随机性*], [*关键参数（AiConfig）*]),
  [Easy], [`EasyRuleBot`], [启发式排序 + Top-K 随机选择], [≤ 500ms], [高], [`topKRandom=8`, `timeLimitMs=min(500,humanBudget)`],
  [Medium], [`AlphaBetaBot`], [Agent 编排 + Alpha-Beta 搜索], [≈ 5s], [低], [`topKRandom=1`, `beliefSamples=0`，迭代加深 + TT + Aspiration ±80 + PVS + LMR],
  [Hard], [`BeliefAlphaBetaBot`], [Belief Sampling + Alpha-Beta 期望搜索], [≈ 5s], [低], [`beliefSamples=4`, `maxCandidatesForBelief=6`, `topKRandom=1`],
)

== Hard AI 选着流程

#arch-diagram(
  "
  createAiPublicView (对手暗子脱敏)
      ↓
  generateStrictLegalMoves (候选走法列表)
      ↓
  取前 maxCandidatesForBelief(=6) 个候选着法
      ↓
  对每个候选进行 beliefSamples(=4) 次采样
      ├─ BoardSampler 从剩余子力池随机确定化
      ├─ 每采样独立 new OptimizedAlphaBeta()
      └─ 执行 Alpha-Beta 迭代加深搜索
      ↓
  对每候选的 4 次采样分数求平均 (期望值)
      ↓
  选择期望分最高的走法
  ",
  caption: [Hard AI Belief Sampling 选着流程 — 采样次数与候选数由 AiConfig 参数控制],
)

源配置：`AiConfig.forLevel(HARD, humanBudgetMs)` → beliefSamples=4, maxCandidatesForBelief=6, topKRandom=1。实际搜索深度不由参数固定，而由迭代加深在时间预算内自动决定。

// ═══════════════════════════════════════════════════════════
// 第六章：客户端设计
// ═══════════════════════════════════════════════════════════
= 客户端设计

Unveil 采用*双端客户端*策略：控制台客户端（`jieqi-client`）面向课程验收与协议联调，Web 前端（`jieqi-web`）面向产品化演示与完整用户旅程。二者共用同一套 WebSocket JSON 协议（端口 8887），服务端 `WsGameServer` 为唯一规则权威。

== 控制台客户端（jieqi-client）

面向开发者、教师验收与组间互操作测试，强调*命令可脚本化*与*协议字段可读*。

#table(
  columns: (auto, 1fr),
  table.header([*功能*], [*说明*]),
  [WsGameClient], [WebSocket 客户端：`match` / `move` / `chat` / `replay` / `rematch` / `ai` / `watch` 等命令，每条命令映射一条 JSON messageType],
  [ConsoleUI], [10×9 ASCII 棋盘渲染；`?` 表示暗子；红方大写 / 黑方小写；行棋方高亮提示],
  [Main 菜单], [9 种模式：WS/TCP 服务器、WS/TCP 客户端、本地人机、AI 自动对弈、自检等统一入口],
  [复盘命令], [`replay` 进入复盘模式 → `n`（下一步）/ `p`（上一步）/ `0`（开局帧）/ `end`（终局帧）/ `g <n>`（跳转第 n 帧）/ `q`（退出）],
)

*典型验收路径*：启动菜单 → 选 WS 客户端 → `login` → `match` → 双方 `ready` → `first true/false` 协商先手 → `move e6 e5` 走子 → 终局后 `replay` 逐步回看。

== Web 前端（jieqi-web）

技术栈：Vue 3 + TypeScript + Vite + Pinia，开发端口 5173。状态集中在 `stores/game.ts`，WebSocket 收发与协议解析与服务端字段一一对应。

#set table(inset: (x: 8pt, y: 6pt))
#table(
  columns: (1fr, 2.2fr, 2.2fr),
  table.header([*页面/组件*], [*说明*], [*对应协议*]),
  [LoginView], [随机昵称（如「隐形小炮兵」）+ emoji 头像；`userId` 与昵称解耦], [`Login → loginResult`],
  [LobbyView], [真人对战 / 人机三档 / AI 观战 / 房间对战四入口；二次确认防误触], [#small[`startMatch` / `startAiGame` / `createRoom`]],
  [GameView + ChessBoard], [Canvas 10×9 棋盘；暗子 `?` 显示；选中高亮 + 可走格提示；步时倒计时 65s], [#small[`move → moveResult` / `gameStart.initialBoard`]],
  [CapturedTray], [被吃棋子信息差展示：我方吃子可见真实身份，被吃暗子隐藏身份], [#small[`moveResult.captured + visible`]],
  [操作面板], [认输 / 手动加时 +30s / 提和；AI 模式额外提供暂停、结束], [#small[`resign` / `addTime` / `drawOffer` / `pauseGame`]],
  [局内聊天], [快捷消息模板 + 15 种 emoji；≤ 120 字符文本], [#small[`chat → chatMessage`]],
  [终局弹窗], [胜负 + 原因 + 暗子揭晓（上帝视角）；「查看棋局」「再来一局」「返回大厅」], [#small[`gameOver.capturedReveal`]],
  [复盘控件], [开局 / 上一步 / 滑块 / 下一步 / 终局；3s 超时兜底], [#small[`replayRequest → replayFrame`]],
)
#set table(inset: (x: 10pt, y: 8pt))

=== 前端状态流

Web 前端状态流覆盖从登录到终局复盘的全链路。前端代码位于 `jieqi-web/src/stores/game.ts`，其中 `getValidMoves`、`isInCheck`、`isCheckmate`、`isStalemate` 用于前端交互提示（可走点高亮、将军/终局提示），不作为权威规则判定依据——最终合法性以服务端 `moveResult.valid` 和 `gameOver` 为准。

```text
Login → loginResult → 跳转 /lobby
  ↓
startMatch / startAiGame / createRoom → matchSuccess → 进入 /game
  ↓
gameStart → parseInitialBoard → displayBoard 渲染 (Canvas 10×9)
  ↓
用户点击棋子 → getValidMoves 生成可走点提示 → 点击目标格 → sendMove
  ↓
moveResult → applyMove (更新 displayBoard + flipResult 翻子动画)
  ├─ valid=true  → 棋盘同步 + 切换回合
  └─ valid=false → toast 提示 + 棋盘不变
  ↓
gameOver → capturedReveal 弹窗 (被吃暗子身份揭晓)
  ├─ 「查看棋局」→ enterReplayMode → replayBoard 切换
  │     ├─ sendReplayRequest(stepIndex) → replayFrame → replayBoard 渲染
  │     └─ prev/next/跳至 → 同流程
  ├─ 「再来一局」→ rematchRequest → 新 gameStart
  └─ 「返回大厅」→ /lobby
```

=== Web 界面展示

以下按*用户实际路径*组织截图说明：每一屏标注「用户看到什么 → 点了什么 → 服务端返回什么」，便于答辩时对照演示。

==== 登录与大厅

*场景 S1–S2：进入系统并选择对战模式*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_login_page.jpg", width: 100%),
    image("web_lobby_main_menu.jpg", width: 100%),
  ),
  caption: [登录页（左）与大厅主菜单（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*界面区域*], [*用户操作*], [*系统响应*]),
  [登录页 · 头像区], [点击头像循环切换预设表情（共 16 种）], [本地 `nextAvatar()`，无需请求],
  [登录页 · 昵称], [输入昵称或点击"随机生成"按钮（如「佛系象棋魂」「隐形小炮兵」）], [本地 `randomNickname()`；`userId` 独立生成 `u_xxx` 避免重名],
  [登录页 · 服务器地址], [填写 `ws://host:8887`（默认课程公共端口）], [建立 WebSocket 长连接；底部显示「已连接 / 未连接」],
  [登录页 · 登录按钮], [点击「登录」], [发送 `Login` JSON → 收到 `loginResult`（success + userId + nickname + avatar）→ 跳转 `/lobby`],
  [大厅 · 三模式入口], [「真人对战」→ 匹配子面板；「AI 自动对弈」→ 观战确认；「人机对战」→ 难度选择], [分别触发 `startMatch` / `startAiBattle` / `startAiGame`],
  [大厅 · 用户信息卡], [左上角显示当前 emoji 头像 + 昵称], [来自 `loginResult`，全程 Pinia 持久化],
)

*场景 S3–S4：匹配与房间*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_lobby_matching.jpg", width: 100%),
    image("web_lobby_room_create_join.jpg", width: 100%),
  ),
  caption: [随机匹配中（左）与创建/加入房间（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*界面状态*], [*用户操作*], [*服务端行为*]),
  [匹配中], [点击「随机匹配」后按钮变为「匹配中…」不可重复点击], [`RoomManager` 入队；匹配成功广播 `matchSuccess`（roomId + opponentId + nickname）],
  [房间对战 · 创建], [点击「创建房间」], [`createRoom` → 返回 6 位房间号；状态栏提示「把房间号告诉对方」],
  [房间对战 · 加入], [输入 6 位房间号 →「加入房间」], [`joinRoom` → `roomInfo` 广播双方对手信息],
  [返回], [「返回」回到主菜单], [取消匹配 / 离开房间（若已在房间）],
)

*场景 S5：双方准备就绪*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_lobby_room_created_waiting.jpg", width: 100%),
    image("web_lobby_room_ready_dual.jpg", width: 100%),
  ),
  caption: [房间创建等待（左）与双方准备就绪双端对比（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*界面要素*], [*说明*], [*协议节点*]),
  [房间信息条], [显示「房间: 167302  对手: xxx」], [`roomInfo` 推送 opponentId / nickname],
  [等待加入], [房主侧：创建后输入框置灰，提示等待对方], [对手 `joinRoom` 后信息条更新],
  [我已准备], [双方均点击后高亮为不可重复态], [双方 `Ready` → 服务器 `requestFirstHand` 协商 → `gameStart`],
  [双端对比], [左：红方视角；右：黑方视角；对手昵称互为镜像], [同一 roomId，yourColor 不同],
)

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_lobby_pvp_ready_dual.jpg", width: 100%),
    [],
  ),
  caption: [真人对战双端准备界面 — 双方均已点击「我已准备」，等待服务器下发 gameStart],
)

==== AI 对弈模式

*场景 S6–S7：人机对战与 AI 自动对弈观战*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_pve_difficulty_dialog.jpg", width: 100%),
    image("web_ai_battle_confirm_dialog.jpg", width: 100%),
  ),
  caption: [人机难度选择（左）与 AI 自动对弈确认弹窗（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*模式*], [*界面说明*], [*后端调度*]),
  [人机对战 · 入门], [Easy：启发式 + 30% 随机，响应 < 500ms], [`startAiGame` + `aiLevel: easy` → `EasyRuleBot`],
  [人机对战 · 标准], [Medium：Alpha-Beta + Agent 编排，~5s 搜索], [`aiLevel: medium` → `AlphaBetaBot` / `JieqiAgent`],
  [人机对战 · 挑战], [Hard：Belief Sampling 期望最大化，~5s 多采样], [`aiLevel: hard` → `BeliefAlphaBetaBot`],
  [AI 自动对弈], [确认弹窗：「观战两位 AI 自动对弈，全程可暂停/结束」], [`startAiBattle` → 服务端双 Bot 循环走子，客户端仅接收广播],
  [二次确认], [所有 AI 模式均有「确认 / 取消」防误触], [取消则不发送 start 消息，留在 lobby],
)

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_pve_standard_ai_game.jpg", width: 100%),
    image("web_ai_auto_battle_in_progress.jpg", width: 100%),
  ),
  caption: [人机对弈进行中（左：标准 AI）与 AI 自动对弈观战（右：双 AI 互博）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*界面区域*], [*人机对战*], [*AI 自动对弈观战*]),
  [左侧信息卡], [显示 AI 难度名称 + 步时倒计时], [显示「AI 自动对弈」+ 双方 AI 昵称],
  [中央棋盘], [用户执红（默认），点击选子 → 点击目标格走子], [只读棋盘，自动播放双方 moveResult],
  [右侧操作], [认输 / 加时 / 提和（真人对战同款）], [「暂停对局」「结束对局」— 对应 pauseGame / 强制终局],
  [被吃子区], [CapturedTray 信息差渲染], [同左，终局后揭晓],
  [状态栏], [房间号 + 「已连接 / 已结束」], [房间号 + 观战模式标识],
)

==== 真人对战界面

*场景 S8：开局与行棋*

#figure(
  image("web_pvp_game_start_dual.jpg", width: 95%),
  caption: [真人对战开局双端对比 — 红方「轮到你走」/ 黑方「等待对手」],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*界面要素*], [*红方视角（左）*], [*黑方视角（右）*]),
  [棋盘], [10×9 Canvas；楚河汉界含 BUPT 标识；坐标 a–i / 0–9], [镜像布局，己方始终在下方],
  [步时倒计时], [「01:01  轮到你走」— 65s 步时], [「01:01  等待对手」— 同步服务器 turnStartTime],
  [操作面板], [认输 / 加时+30s（2/2）/ 提和], [同左；提和需对方 drawAccept 才终局],
  [聊天区], [「还没有消息」→ 可发快捷语 / emoji / 自定义文本], [双方 chatMessage 广播同步],
  [走子交互], [选中棋子 → 高亮可走格 → 点击目标 → 发送 move], [收到 moveResult 后棋盘同步 + flipResult 翻子动画],
  [非法走子], [moveResult.valid=false，棋盘不变，toast 提示], [服务端 RuleValidator 权威拒绝],
)

==== 局内操作与聊天

*场景 S9：辅助功能与社交互动*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_game_operations_panel.jpg", width: 100%),
    image("web_resign_confirm_dialog.jpg", width: 100%),
  ),
  caption: [操作面板（左）与认输确认弹窗（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*功能*], [*交互设计*], [*服务端处理*]),
  [认输], [二次确认：「认输后对局会立即结束，对方获胜」], [`resign` → gameOver（reason=resign，winner=对方）],
  [加时 +30s], [每步最多 2 次；按钮显示剩余次数 (2/2)], [`addTime` → timeBonus（turnStartTime 延后 60s）],
  [提和], [发送提和请求，等待对方响应], [`drawOffer` → 对方 `drawAccept` 则和棋 / `drawDecline` 则继续],
  [暂停（AI 模式）], [暂停后 AI 停止走子，显示「继续对局」], [`pauseGame` / `resumeGame` → gamePaused / gameResumed],
)

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_in_game_chat.jpg", width: 100%),
    image("web_emoji_picker.jpg", width: 100%),
  ),
  caption: [局内聊天（左）与表情选择器（右）],
)

#table(
  columns: (auto, 1fr),
  table.header([*聊天能力*], [*说明*]),
  [快捷消息], [预设模板一键发送（如「要不要我帮你走这步？」「稳住，我们能输！」）],
  [表情面板], [3×5 共 15 种预设表情；点击即发送],
  [自定义输入], [底部输入框 +「发送」；单条 ≤ 120 字符（与服务端校验一致）],
  [消息归属], [显示「黑方 你」/「红方 你」+ 时间戳；仅本局参与者可见],
  [提示音], [新消息可选提示音（`chatSoundOn` 开关，默认开启）],
)

==== 聊天室协议与实现

*协议定义*：

#table(
  columns: (auto, auto, 2fr),
  table.header([*协议层*], [*消息类型*], [*说明*]),
  [WebSocket/JSON（主）], [`chat` (C→S) / `chatMessage` (S→C)], [客户端发送 `chat`，服务器广播 `chatMessage`],
  [TCP 文本帧（附录 B）], [`MSG_CHAT = 10`], [格式：`playerColor|playerName|message`],
)

关键文件：`JsonMessageTypes.java`（`CHAT` / `CHAT_MESSAGE` 常量）、`JsonMessages.java`（构建带服务器时间戳的 `chatMessage` JSON）、`Protocol.java`（TCP `MSG_CHAT=10` + `buildChatMsg()`）。

*服务端实现*（`WsGameServer.handleChat()`，行 493-518）：
- 校验链：用户已登录 → 已加入房间 → 游戏已开始且处于 PLAYING 状态
- *AI 对局拦截*：若 `room.hasAiOpponent()` 或 `room.isAiBattle()`，返回错误"仅真人对局支持聊天"
- 内容净化（`sanitizeChatContent()`）：替换换行符为空格，去除首尾空白，截断至 *120 字符*
- 使用服务器时间戳（不信任客户端时间）
- 通过 `broadcastRoom()` 向双方及观战者广播

*TCP 路径*（`ClientHandler.sanitizeChatPayload()`，行 146-157）：
- *频率限制*：两次发言间隔 ≥ 10 秒（`CHAT_MIN_INTERVAL_MS = 10_000L`），超频返回提示
- 长度限制：*200 字符*
- 广播至对局双方

*两协议差异*：

#table(
  columns: (auto, auto, auto),
  table.header([*特性*], [*WebSocket (8887)*], [*TCP (8888)*]),
  [字符限制], [120], [200],
  [频率限制], [无], [10 秒/条],
)

*前端消息流*：

#arch-diagram(
  "
  客户端 A → sendChat() → WS JSON: {messageType: \"chat\", content: \"...\"}
    → WsGameServer.handleChat() 校验净化 → broadcastRoom()
    → 客户端 A + B 收到 {messageType: \"chatMessage\", fromUserId,
      fromColor, content, timestamp}
    → GameView.vue 渲染聊天气泡（mine = fromUserId === this.userId）
  ",
  caption: [聊天消息全链路],
  size: 8pt,
)

*设计要点*：仅真人可用（服务端 + 前端双重校验）；服务器时间戳（遵循"客户端时间戳不被信任"原则）；无持久化（消息仅内存传输，广播后即丢弃，客户端上限 60 条）；内容净化（服务端替换换行、截断超长内容）；课程扩展功能（INTERFACE.typ 标记为"可选扩展" MSG 10，非核心协议要求）。

==== 终局结果

*场景 S10–S11：终局弹窗与后续操作*

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 8pt,
    row-gutter: 8pt,
    image("web_gameover_win_checkmate.jpg", width: 100%),
    image("web_gameover_lose_timeout.jpg", width: 100%),
  ),
  caption: [终局弹窗 — 将死获胜（左）与超时失败（右）],
)

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*终局类型*], [*界面展示*], [*后续路径*]),
  [将死获胜], [「你赢了」+ 原因：将死；被吃暗子以真实身份展示在棋盘外], [「再来一局」→ rematchRequest；「查看棋局」→ 复盘；「返回大厅」→ /lobby],
  [超时失败], [「你输了」+ 原因：超时；loserId 由服务器判定], [同上三条路径],
  [和棋 / 认输], [reason 字段对应 draw_agreement / resign 等], [capturedReveal 上帝视角揭晓全部被吃暗子身份],
  [状态同步], [右侧状态栏变为「已结束」；步时归零 00:00], [gameOver 广播后棋谱落盘 + replay.json 持久化],
)

*场景 S12：复盘（详见 §7 棋谱与复盘）*

终局后点击「查看棋局」→ 进入 replayMode → 底部出现步进控件 → 每步发送 `replayRequest(stepIndex)` → 渲染 `replayFrame.board` 快照。对局中暗子复盘按玩家视角脱敏；终局后按快照上帝视角展示。

*已知边界*：Web 端逐步复盘依赖终局后房间仍保留在服务端内存中（`WsGameServer` 未重启、未超时清理）；历史 `replay.json` 文件浏览尚未实现（文件已落盘于 `records/`，但无 HTTP 接口或前端页面加载历史对局）。

=== 复盘模式架构

#arch-diagram(
  "
  点击「查看棋局」
    │
    ├─ replayMode = true (控件即刻显示)
    ├─ sendReplayRequest()  →  WS: {\"messageType\":\"replayRequest\"}
    │
    ├─ 后端返回 replayFrame { stepIndex, totalSteps, board[], move, status }
    │       │
    │       ├─ parseInitialBoard(board) → Piece[]
    │       ├─ displayBoard = replayBoard (棋盘切换)
    │       └─ replayLoading = false (控件解锁)
    │
    ├─ 点击 prev/next → sendReplayRequest(stepIndex ± 1)
    │
    └─ 超时保护: 3s 无响应 → 显示 \"复盘请求超时\" + 恢复按钮
  ",
  caption: [Web 前端复盘数据流（后端是数据源，前端是播放器）],
)

== Web 端当前进展与已知限制

=== 已完成（可演示）

#table(
  columns: (auto, auto),
  table.header([*模块*], [*状态与证据*]),
  [三页面路由], [#ok 完成：LoginView / LobbyView / GameView],
  [棋盘渲染], [#ok 完成：ChessBoard.vue Canvas + 暗子 `?` 标记 + 选中高亮],
  [信息差展示], [#ok 完成：CapturedTray 被吃区脱敏渲染],
  [四种对战模式], [#ok 完成：真人匹配 / 房间对战 / 人机三档 / AI 自动观战],
  [局内交互], [#ok 完成：聊天、emoji、提和、认输、手动加时、AI 暂停],
  [终局闭环], [#ok 完成：胜负弹窗 + `capturedReveal` 上帝视角 + rematch 三态 UI],
  [复盘播放器], [#ok 完成：`replayRequest`/`replayFrame` + 步进控件 + 3s 超时兜底],
  [截图素材], [#ok 完成：18 张语义化命名并嵌入本报告 §6.2.1],
  [控制台双轨], [#ok 完成：`jieqi-client` 命令行同协议链路验收],
)

=== 待强化 / 已知限制

#table(
  columns: (auto, auto, 1fr),
  table.header([*项*], [*状态*], [*说明*]),

  [复盘生产部署], [#warn 依赖后端版本], [UI 就绪；需确保 `WsGameServer.handleReplayRequest` 随最新 Fat JAR 部署；Web 端复盘依赖终局后房间仍在服务端内存中，历史 `replay.json` 文件浏览尚未实现],
  [走子错误码细化], [#warn P2], [前端 toast 多为通用文案，未细分到具体规则分支],
  [Docker 一键 Web], [#warn 实验性], [后端 Docker 已就绪；前端需 `npm run dev` 单独起，未整合],
  [商业化 polish], [#no 非目标], [无 3D 棋盘、无移动端适配、无排行榜（与产品定位一致）],
)

Web 前端在产品矩阵中的定位：控制台「完整」+ Web「完整（复盘依赖服务端部署）」——已从 P2「规划中 GUI」升级为答辩主展示入口。

// ═══════════════════════════════════════════════════════════
// 第七章：棋谱与复盘
// ═══════════════════════════════════════════════════════════
= 棋谱与复盘

== 三类产物

#table(
  columns: (auto, auto, 1fr),
  table.header([*产物*], [*路径*], [*说明*]),
  [文字棋谱], [`records/<id>.jieqi`], [走法文本，含回合号 + 红黑标识 + 翻子标记，供阅读导出],
  [复盘 JSON], [`records/<id>.replay.json`], [逐步 Board 快照（含暗子真实类型），防御性拷贝 + 终局落盘],
  [内存时间线], [Game.replayTimeline], [List⟨ReplayFrame⟩，对局进行中实时支持 replayRequest 查询],
)

== 帧编号模型

#arch-diagram(
  "
  stepIndex=0    开局帧（无 move，仅初始棋盘快照）
  stepIndex=1    第 1 手后的完整棋盘
  stepIndex=2    第 2 手后的完整棋盘
  ...
  stepIndex=N    终局后最后一帧（含 gameOver 状态）
  ",
  caption: [复盘帧编号（0-indexed）],
)

每帧含：`stepIndex`、`move`（可 null）、`boardSnapshot`（防御性拷贝）、`currentTurn`、`status`、`timestamp`、`captured`。

== 产生时机

#arch-diagram(
  "
  gameStart  → Game.recordReplayInitialIfNeeded()      # stepIndex=0
    │
    │  (每步 loop)
  processMove → replayTimeline.recordAfterMove()       # stepIndex=1,2,...
    │
  gameOver   → persistReplay(game)                     # JSON 落盘
  ",
  caption: [复盘数据产生全流程],
)

== 复盘协议

#table(
  columns: (auto, auto, 1fr),
  table.header([*messageType*], [*方向*], [*关键字段*]),
  [replayRequest], [C→S], [stepIndex（可选，缺省返回最后一帧）],
  [replayFrame], [S→C], [roomId, stepIndex, totalSteps, currentTurn, status, board[], move?, captured?],
)

board 数组每元素：`{ x: "a"-"i", y: 0-9, color: "red"|"black", piece: "rook"|..., visible: true|false }`。

== 权限与视角

#table(
  columns: (auto, 1fr),
  table.header([*场景*], [*显示*]),
  [对局中复盘], [按玩家视角：对手暗子不暴露真实 type],
  [终局后复盘], [上帝视角：快照含完整 Board（capturedReveal 揭晓所有暗子身份）],
  [非房间成员], [拒绝：仅本局参与者可 replayRequest],
)

== 前端复盘引擎

复盘为*纯客户端交互式对局回放系统*，完整实现在 `jieqi-web/src/stores/game.ts`（Pinia Store）。无独立服务端 API 端点，无 AI 参与复盘分析。

=== 核心数据模型

前端以 *BoardState 树* 组织快照，支持主链回放与分支探索：

#table(
  columns: (1fr, 3fr),
  table.header([*字段*], [*含义*]),
  [`id: string`], [唯一快照标识（`S1`, `S2`, ...）],
  [`board: Piece[]`], [完整深拷贝棋盘快照],
  [`parent: string | null`], [父状态 ID（`null` = 根节点）],
  [`mainNext: string | null`], [主链下一状态 ID],
  [`branches: string[]`], [分支状态 ID 列表（假想变化）],
  [`moveRecord?: MoveRecord`], [产生此状态的走法（`before` / `after` / `player` / `timestamp`）],
)

形成*树形结构*：一条线性「主链」（`mainNext`）代表实际对局过程，分支（`branches[]`）代表假想变化。

=== 完整流程

*阶段一：对局中录制* — 每步 `applyMove()` 后调用 `recordBoardSnapshot()`：深拷贝当前棋盘 → 创建 BoardState 节点 → `mainNext` 链接父节点 → 更新 `currentStateId`。开局初始棋盘在 `gameStart` 时快照。

*阶段二：进入复盘* — 对局结束显示结算弹窗 → 「查看棋局」→ 「进入复盘」→ `enterReplay()`：设置 `isReplayMode = true`，导航到最新主链状态。

*阶段三：导航操作* — `goNext()`（沿 `mainNext` 前进）/ `goPrev()`（沿 `parent` 后退）/ `goToStart()` / `goToEnd()`，每次交换回合。

*阶段四：自由分支* — 复盘模式下点击棋子触发 `handleReplayCellClick()`：校验回合归属 → 选择目标 → `executeReplayMove()` 创建分支 BoardState。翻子时通过 `findRealTypeInMainChain()` 沿主链查找真实类型（非凭空生成）。将帅被吃后设置 `branchKingCaptured = true`，锁定分支。

*阶段五：退出* — `exitReplay()` 恢复最新主链状态，清除分支状态，返回结算视图。

=== 服务端支持

复盘功能*无独立 API 端点*。相关服务端消息仅 `gameStart`（提供 `initialBoard` 种子）、`moveResult`（触发快照录制）、`gameOver`（标记对局结束并启用复盘 UI）。服务端通过 `GameRecordStore.save()` 将棋谱持久化至 `records/{gameId}.jieqi`，前端复盘不读取这些文件，完全依赖内存 `boardStates[]`。

=== 架构总结

#arch-diagram(
  "
  [Server]                              [Frontend Browser]
    Game.java                              game.ts (Pinia)
      +- Board.moveHistory[]               +- boardStates[] (树)
      +- GameRecord (text)                 +- isReplayMode
      +- GameRecordStore.save()            +- enterReplay()/exitReplay()
           `- records/*.jieqi              +- goPrev()/goNext()
                                           +- executeReplayMove() (分支)
  WsGameServer:                            +- findRealTypeInMainChain()
    `- broadcastGameOver()                 +- recordBoardSnapshot()
         `- persistRecord(game)
  ",
  caption: [复盘系统架构 — 服务端持久化与前端快照树解耦],
  size: 8pt,
)

=== 设计要点

1. *纯客户端实现*：复盘所有交互逻辑在前端完成，无需服务端复盘 API
2. *树形快照结构*：BoardState 树支持主链回放 + 任意分支探索
3. *主链暗子查询*：分支翻子沿主链向前查找真实类型，而非凭空生成
4. *将帅保护*：分支中将帅被吃后自动锁定，防止无意义走法
5. *无 AI 参与*：jieqi-ai 模块专用于对局走子选择，不参与复盘分析、走法点评或自动复盘
6. *棋谱文件独立*：服务端持久化 `.jieqi` 文件用于存档，与前端复盘系统解耦

// ═══════════════════════════════════════════════════════════
// 第八章：测试与质量
// ═══════════════════════════════════════════════════════════
= 测试与质量

测试策略遵循"接口先行、测试驱动"原则：核心领域逻辑（jieqi-core）以单元测试覆盖全部规则分支，协议集成（jieqi-server）以端到端测试验证完整消息链路，AI 模块（jieqi-ai）以正确性断言确保搜索合法性与公平性。所有测试仅使用 JUnit Jupiter 5.11.4 内置断言，未引入 Mockito、AssertJ 等第三方测试框架。测试执行通过 Maven Surefire 插件，CI 配置于 `.github/workflows/ci.yml`（push/PR 自动触发）。

#img("diag_ch8_test_quality.svg", width: 96%, caption: [测试与质量体系总览 — 142 项分布 · CI 流水线 · 三层测试策略])

== 测试汇总

#table(
  columns: (auto, auto),
  table.header([*指标*], [*数值*]),
  [自动化用例总数], [*142*],
  [通过 / 失败 / 跳过], [*142 / 0 / 0*],
  [自检脚本], [`verify.ps1` → OK: verify passed],
  [代码规模], [63 主代码文件 (~8 500 行) + 51 测试文件 → 合计 114 文件 (~10 500 行)],
)

所有 142 个用例覆盖 jieqi-core（89）、jieqi-ai（16）、jieqi-server（37）三个模块，0 失败 0 跳过。`verify.ps1` 脚本镜像 CI 流水线步骤，用于 push 前本地一键自检。

== 分模块结果

#table(
  columns: (auto, auto, auto, auto),
  table.header([*模块*], [*测试类*], [*用例*], [*覆盖重点*]),
  [jieqi-core], [28], [89], [七种走法、暗子规则、送将/照面、将死/困毙、40 步和、长将长捉、棋谱、复盘时间线],
  [jieqi-ai], [9], [16], [AB 搜索、三档 Bot 合法性与公平性、置换表、Agent 编排],
  [jieqi-server], [12], [37], [TCP 集成 7 + WS 集成 21 + 复盘落盘 2 + 记录存储 7],
  [jieqi-client], [0], [—], [由 WS 集成测试间接覆盖],
  [jieqi-app], [0], [—], [Fat JAR 启动器，无单测],
  [*合计*], [*49*], [*142*], [*全通过*],
)

== 关键测试场景（摘录）

以下 9 个场景摘录自 142 项测试中最具代表性的用例，覆盖规则边界（R 系列）、AI 正确性（A 系列）、网络协议（N 系列）与复盘/观战（P 系列）四条主线。每个场景均由对应测试类直接验证，构建于 `verify.ps1` 自动化流程中。

#table(
  columns: (auto, auto, auto, auto),
  table.header([*编号*], [*场景*], [*测试方法*], [*结果*]),
  [R11–R13], [送将 / 照面 / 解将], [RuleEdgeCaseTest 11 项], [#ok],
  [E01–E03], [将死 / 困毙 / 40 步和], [EndgameJudgeTest], [#ok],
  [A03], [AI 不透视对手暗子], [AiFairnessTest], [#ok],
  [A06], [搜索 undo 棋盘一致性], [BoardUndoTest], [#ok],
  [N01], [WS 匹配 → Ready → gameStart], [WsGameServerIntegrationTest], [#ok],
  [N04], [非法走法拒绝], [illegalMoveRejected], [#ok],
  [N05], [步时超时判负], [turnTimeoutEndsGame], [#ok],
  [P04], [复盘帧 replayRequest], [replayRequestReturnsFramesAfterResign], [#ok],
  [P05], [观战 watch], [watchJoinsActiveGameAsObserver], [#ok],
)

== AI 性能观测

AI 模块的性能验证通过 `PerformanceTest.main()` 独立基准（非 JUnit 测试）在不同时间限制（1s/2s/5s/10s）下测量搜索深度与节点吞吐。三档 AI 的实际表现如下：

#table(
  columns: (auto, auto, auto),
  table.header([*等级*], [*典型步时*], [*超时*]),
  [Easy], [< 500ms], [0],
  [Medium], [1–3 秒（深度 8–12）], [0],
  [Hard], [2–5 秒（Belief 多采样）], [0（复杂中局可能 fallback）],
)

Easy 档通过时间上限截断（`timeLimitMs=min(500, humanBudget)`）保证毫秒级响应；Medium 与 Hard 共享 ~5s 时间预算，但 Hard 因需要为每候选执行 4 次完整 AB 搜索，实际搜索深度低于 Medium，棋力通过采样期望值的统计稳定性补偿。

== 需求与测试映射矩阵

#table(
  columns: (1.4fr, 1.4fr, 2.5fr),
  table.header([*验收点*], [*主要风险*], [*测试方式*]),
  [七种棋子走法], [走法边界错误（蹩腿/炮架/过河）], [`BoardMakeMoveTest` · `RuleValidatorTest`],
  [暗子机制], [type/virtualType 混淆；暗子走法越界], [`DarkPieceRuleTest` · `BoardAiPublicViewTest`],
  [强化士象], [暗士出九宫、明士禁足；暗象过河、明象限边], [`DarkPieceRuleTest` 强化规则子项],
  [送将与照面], [非法局面未被拦截（将帅对面）], [`RuleEdgeCaseTest` 11 项],
  [终局判定], [将死/困毙/超时判定错误；无吃子和计数遗漏], [`EndgameJudgeTest` · `RuleEdgeCaseTest`],
  [走子回滚], [makeMove/unmakeMove 状态未完全恢复], [`BoardUndoTest`],
  [AI 公平性], [AI 透视对手暗子 identity], [`AiFairnessTest` · `BoardAiPublicViewTest`],
  [AI 搜索一致性], [搜索前后棋盘不一致（TT 污染/undo 不完整）], [`OptimizedAlphaBetaRepetitionTest`],
  [复盘帧完整性], [帧编号错误；快照不独立（引用污染）；竞态落盘空帧], [`ReplayTimelineTest` + 服务端集成 2 项],
  [WebSocket 状态同步], [房间状态不同步；消息丢失], [WsGameServer 集成测 37 项],
  [非法走法拒绝], [服务端未拦截非法走子], [非法走法拒绝测],
  [重复局面判定], [长将/长捉误判；计数清零时机错误], [EndgameJudge 长将/长捉子项],
)

== 详细测试清单

以下按模块列出关键测试类及其覆盖范围，补充分模块汇总表（§8.2）中未展开的细节。

=== jieqi-core 测试清单（15 类）

领域规则、协议序列化、棋谱记录三大方向覆盖 jieqi-core 的全部核心逻辑。

*领域规则测试（8 类）*：

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*覆盖内容*]),
  [`CoordinateTest`], [坐标格式 `"a0"`..`"i9"` 校验与行列转换],
  [`ChessPieceCoordTest`], [棋子坐标映射（a0=红方左下，i9=黑方右上）],
  [`DarkPieceRuleTest`], [暗子规则：士不能出宫、翻子后可过河、翻子动作不可吃子、生成动作不含送将],
  [`KingCapturedRuleTest`], [翻子吃将立即获胜、禁止翻自己的将],
  [`BoardExpectedValueTest`], [开局暗子期望值正数且对称],
  [`BoardSyncTest`], [BOARD_STATE 序列化/反序列化完整性],
  [`EndgameJudgeTest`], [将死、困毙、吃将终局、长将判负（6次）、兵长捉和棋（6次）、无捉无将不判负],
  [`GameEndgameTest`], [超时判负],
)

协议层测试覆盖 TCP 帧解码健壮性、完整消息往返、JSON 序列化一致性：

*协议与序列化测试（5 类）*：

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*覆盖内容*]),
  [`FrameDecoderTest`], [单帧解码、粘包解码、半包处理、非法长度拒绝、超大负载拒绝、缓冲区溢出拒绝],
  [`ProtocolFrameIntegrationTest`], [登录帧往返、棋盘状态帧完整性],
  [`ProtocolMoveSerializationTest`], [走法序列化/反序列化（含翻子标记）、仅翻子往返],
  [`BoardJsonMapperTest`], [初始棋盘含将和暗子、棋子名称往返、过河棋子颜色正确],
  [`PieceJsonMapperTest`], [JSON 名称匹配教学规范、解析所有类型值、全部类型往返、颜色映射],
)

*棋谱测试（3 类）*：

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*覆盖内容*]),
  [`GameRecordTest`], [标准记法导出、走法格式匹配接口规范],
  [`GameRecordImportTest`], [解析编号行并跳过注释、导出/导入往返],
  [`MoveNotationParseTest`], [翻子记法解析、普通走法记法解析],
)

== jieqi-server 测试清单（12 类）

服务端测试以集成测试为主，覆盖 TCP 与 WebSocket 双协议栈的完整消息链路。`AbstractGameServerIntegrationTest` 为 TCP 测试提供 `loginAndDrain()`、`connectTwoPlayers()`、`awaitBoardState()`、`awaitMoveBroadcast()` 等阻塞断言基元，管理 `GameServer` 生命周期（随机端口避免冲突）。

*TCP 集成测试（8 类，均继承基类）*：

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*测试场景*]),
  [`GameServerLoginIntegrationTest`], [双人登录后收到 GAME_START],
  [`GameServerMoveIntegrationTest`], [红方走子后黑方收到 MOVE 广播],
  [`GameServerIllegalMoveIntegrationTest`], [错手走子返回 ERROR 101],
  [`GameServerDrawIntegrationTest`], [求和/同意求和广播 GAME_OVER（AGREED_DRAW）],
  [`GameServerResignIntegrationTest`], [认输广播 GAME_OVER 并持久化棋谱文件],
  [`GameServerTurnChangeIntegrationTest`], [走子后 TURN_CHANGE 广播双方],
  [`GameServerUnknownMsgIntegrationTest`], [未知 msgType 被忽略，后续走法正常处理],
  [`GameServerChatIntegrationTest`], [聊天广播与频率限制验证],
)

*WebSocket 集成测试（1 类，21 方法）*：

`WsGameServerIntegrationTest` 是项目中最全面的测试文件，使用内建 `TestWsClient` 实现端到端测试：登录、匹配、准备、游戏开始、完整对局流程、非法走子返回错误 2001、非己方回合返回错误 2002、聊天广播、认输、同意求和、拒绝求和、创建房间+加入码、AI 对局、AI 对局聊天拒绝、AI 对战观战、超时、断线终局、先手请求交换、未知消息类型返回错误 4001、未登录匹配返回错误 1001、取消匹配。

*其他服务测试*：

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*测试内容*]),
  [`MatchmakingServiceTest`], [单人自动匹配、房间不存在返回 NOT_FOUND、满房返回 ALREADY_STARTED],
  [`GameRecordStoreTest`], [棋谱文件保存/加载往返（使用 `@TempDir`）],
)

== jieqi-ai 测试清单（5 类）

#table(
  columns: (auto, 1fr),
  table.header([*测试类*], [*测试内容*]),
  [`JieqiAgentTest`], [AI 在 3 秒内选择合法走法],
  [`EnhancedEvaluatorTest`], [评估函数在红黑视角间反对称],
  [`OptimizedAlphaBetaTacticalTest`], [搜索优先解决大子威胁（战术意识）],
  [`AgentOrchestratorTest`], [编排器使用第一个返回走法的子 Agent],
  [`ProbabilityAgentTest`], [暗子存在时概率 Agent 设置期望值偏置],
  [`EndgameAgentTest`], [盘面棋子多时终局 Agent 不激活],
)

== AI 性能基准

`PerformanceTest.main()`（main 源码，非 JUnit 测试）在不同时间限制（1s/2s/5s/10s）下基准测试搜索性能，输出深度/节点数/评分。

== 测试框架与 CI

测试框架选型以*简洁可复现*为原则：仅依赖 JUnit Jupiter 5.11.4 内置断言，不引入额外测试库，降低答辩机环境依赖。Maven Surefire 插件在 `mvn test` 阶段自动发现并执行所有 `*Test.java` 文件，无需额外配置。

#table(
  columns: (1fr, 3fr),
  table.header([*组件*], [*配置*]),
  [JUnit Jupiter], [5.11.4 — 所有 Java 测试模块统一框架],
  [maven-surefire-plugin], [3.5.2 — 父 POM 测试执行引擎],
  [GitHub Actions CI], [`.github/workflows/ci.yml`：push/PR 到 main 触发，JDK 21 (Temurin)，Maven 缓存，步骤 `mvn test -pl jieqi-core,jieqi-server,jieqi-ai` → `mvn compile` → `mvn package -pl jieqi-app -am -DskipTests`],
  [本地验证], [`scripts/verify.ps1` 镜像 CI 步骤，push 前本地验证],
)

未使用 Mockito、Spring Test、JaCoCo（代码覆盖率）、AssertJ、Hamcrest。所有测试仅使用 JUnit Jupiter 内置断言。这一策略的代价是 AI 子 Agent 测试使用匿名类桩代码、缺少覆盖率量化、无法区分单元/集成测试分组，但对课程验收而言，142 项全通过的确定性远高于工具链的完备性。

== 测试质量评估

综合审视当前测试体系，其优势与不足如下：

*优势*：
- 协议驱动集成测试：`WsGameServerIntegrationTest`（21 方法）覆盖完整 JSON 消息协议端到端流程
- 游戏规则覆盖充分：`EndgameJudgeTest`（6 项）覆盖将死、困毙、吃将、长将、长捉等终局条件；`DarkPieceRuleTest`（6 项）覆盖暗子移动约束
- 协议序列化健壮：`FrameDecoderTest`（6 项）覆盖粘包、半包、非法长度、缓冲区溢出等边界
- CI 已配置且正常运行

*不足*：
- `jieqi-client`、`jieqi-app`、`jieqi-web` 三模块零测试覆盖
- 无 Mock 框架（Mockito 未引入），AI 子 Agent 测试用匿名类桩代码，不可扩展
- 无代码覆盖率工具（JaCoCo 完全缺失）
- AI 测试薄弱：仅 5 个基础测试，无特定搜索深度、非平凡局面评估正确性或性能断言
- 无参数化测试（手动循环代替 `@ParameterizedTest`）
- 无测试标签/分组（所有测试一同运行，未区分单元测试与集成测试）

== 已知未修

#table(
  columns: (auto, 1fr, auto),
  table.header([*优先级*], [*项*], [*说明*]),
  [P2], [走子错误原因码], [RuleValidator 仅返回 boolean，不细分"哪个规则违反"],
  [P2], [长捉复杂分类], [极端连环捉、隔子捉需人工复核],
  [P3], [jieqi-client 单测], [依赖 WS 集成间接覆盖],
  [P3], [jieqi-web E2E], [Vue 前端无 Playwright 自动化],
)

// ═══════════════════════════════════════════════════════════
// 第九章：部署与运行
// ═══════════════════════════════════════════════════════════
= 部署与运行

本章说明 Unveil 在*本地开发机*、*答辩演示机*与*Docker 容器*三种场景下的构建、启动与验收方法。部署原则（秦博宇 · 服务端交付）：*WsGameServer 为唯一规则权威*；客户端/Web 连 `ws://host:8887`；扩展消息（replay / rematch / addTime）须用最新 Fat JAR，避免 `~/.m2` 过期 SNAPSHOT。

== 部署拓扑

Unveil 采用 *Fat JAR 单中枢* 部署模型：`jieqi-app` 模块通过 Maven Assembly 将所有依赖（core/server/ai）打包为单个 `unveil-jieqi.jar`，启动时只需 JDK 21 运行时，无需外置应用服务器或数据库。服务端以 WsGameServer（端口 8887）为统一入口，所有客户端（控制台/Web/双 AI 对弈）通过同一 WebSocket 地址互联。部署场景覆盖三种典型环境：

- *本地开发机*：JDK 21 + Maven + Node.js 全栈，适合编码调试
- *答辩演示机*：仅需 JDK 21（或 Docker），通过 `verify.ps1` → `dev-server.ps1` → `demo.ps1` 三条脚本完成全流程
- *Docker 容器*：无 JDK 宿主机一键启动 WS 服务，牺牲 TCP 8888 与 Web 前端集成换取零依赖

#img("diag_ch9_deployment_topology.svg", width: 96%, caption: [部署拓扑 — Fat JAR 中枢 · 四客户端 · records 落盘 · 三种运行场景])

各组件端口与职责如下：

#table(
  columns: (auto, auto, auto, auto),
  table.header([*组件*], [*默认端口*], [*协议*], [*用途*]),
  [WsGameServer], [8887], [WebSocket + JSON v3.0], [课程主通道 · 组间互操作 · Web/控制台],
  [GameServer (TCP)], [8888], [文本帧 附录 B], [legacy 调试；Docker 默认不映射],
  [jieqi-web (Vite)], [5173], [HTTP + WS 客户端], [浏览器 GUI；需 Node.js 18+],
  [records/], [—], [文件系统], [棋谱 `*.jieqi` + 复盘 `*.replay.json`],
)

== 环境要求

=== 必装组件

#table(
  columns: (auto, auto, auto, auto),
  table.header([*组件*], [*版本*], [*检查命令*], [*期望*]),
  [JDK], [21.x], [`java -version`], [major version = 21],
  [Maven], [3.9+], [`mvn -version`], [Java version: 21],
  [Git], [2.x+], [`git --version`], [—],
  [PowerShell], [5.1+ / 7+], [`$PSVersionTable.PSVersion`], [自检/演示脚本],
)

=== 可选组件

#table(
  columns: (auto, auto, auto, auto),
  table.header([*组件*], [*版本*], [*用途*], [*检查*]),
  [Node.js], [18+], [jieqi-web 前端], [`node -v`],
  [npm], [9+], [Vue 依赖安装], [`npm -v`],
  [Docker Engine], [24+], [无 JDK 一键起 WS], [`docker --version`],
  [Typst], [0.14+], [编译 INTERFACE / 文档 PDF], [`typst --version`],
)

=== JDK 环境核对清单（答辩机必做）

#table(
  columns: (auto, auto, 1fr),
  table.header([*检查项*], [*命令*], [*通过标准*]),
  [Java 运行时], [`java -version`], [输出含 21.x],
  [Maven JDK], [`mvn -version`], [Java version: 21，非 17/11],
  [JAVA_HOME], [`$env:JAVA_HOME`（PowerShell）], [指向 JDK 21 根目录],
  [父 POM], [根 `pom.xml`], [`maven.compiler.release=21`],
  [PATH], [`where java`], [第一条与 JAVA_HOME 一致],
)

*常见踩坑*：`release version 21 not supported` = Maven 与 `java` 指向不同 JDK 版本，或 JAVA_HOME 仍为 17。

== 自检

答辩与联调前*必须先跑自检*。

```powershell
powershell -File scripts/verify.ps1
```

=== verify.ps1 三步

#table(
  columns: (auto, 1fr, auto),
  table.header([*步骤*], [*等价命令*], [*覆盖*]),
  [1], [`mvn test -pl jieqi-core,jieqi-server,jieqi-ai`], [142 项自动化测试],
  [2], [`mvn compile`], [5 模块编译],
  [3], [`mvn package -pl jieqi-app -am -DskipTests`], [产出 `unveil-jieqi.jar`],
)

*预期*：最后一行 `OK: verify passed`。

*失败定位*：test 阶段查 `surefire-reports`；package 阶段执行 `mvn install -pl jieqi-app -am -DskipTests`（见 No.9）。

== 启动服务端

服务端是系统唯一权威节点，必须最先启动。以下六种启动方式覆盖从「最快启动」到「最易调试」的完整梯度，按推荐优先级排列。核心原则：*优先使用脚本而非裸命令*，脚本内部已处理 SNAPSHOT 过期、JDK 版本探测、Fat JAR 自动构建等常见踩坑点。

=== 方式对比（推荐顺序）

#table(
  columns: (0.4fr, 3.4fr, 0.8fr, 0.8fr),
  table.header([*方式*], [*命令*], [*场景*], [*备注*]),
  [A #ok], [`powershell -File scripts/dev-server.ps1 8887`], [开发/答辩推荐], [package + java -jar；避免旧 SNAPSHOT],
  [B], [`powershell -File scripts/run-app.ps1 server-ws 8887`], [同上], [自动探测 JDK 21],
  [C], [`java -jar jieqi-app/target/unveil-jieqi.jar server-ws 8887`], [verify 通过后最快], [须先 package],
  [D], [`mvn exec:java -f jieqi-app/pom.xml -am -Dexec.args="server-ws 8887"`], [快速调试], [#warn 可能加载过期 SNAPSHOT],
  [E], [`mvn exec:java -f jieqi-app/pom.xml -am` → 菜单 3], [探索 1–10 模式], [含 TCP / 本地 AI],
  [F], [`docker compose up --build`], [无 JDK 验收机], [仅 WS 8887],
)

=== 启动成功标志

#table(
  columns: (auto, 1fr),
  table.header([*日志/现象*], [*含义*]),
  [`8887` 监听 / WsGameServer 启动], [WS 服务就绪],
  [无 Address already in use], [端口空闲],
  [客户端 loginResult success=true], [UserRegistry 正常],
)

=== 交互菜单（jieqi-app Main 1–10）

#table(
  columns: (auto, auto, 1fr),
  table.header([*项*], [*功能*], [*说明*]),
  [3], [WS 服务器 8887], [答辩默认],
  [4], [WS 客户端], [match / move / replay],
  [9], [AI 经 WS 对弈], [双 Bot 连服务器],
  [10], [观战 watch], [输入 roomId],
  [1/2], [TCP 8888 服/客], [附录 B 调试],
  [5/6/7/8], [本地 AI / 性能 / 规则测试], [不经网络],
)

== 启动客户端

=== 控制台 WS 客户端

```powershell
mvn exec:java -f jieqi-app/pom.xml -am -Dexec.args="client-ws ws://127.0.0.1:8887 player1 123456"
```

*推荐*：服务端用 `run-app.ps1` 时，客户端同样用 `run-app.ps1 client-ws …` 保持 JAR 版本一致。

*常用命令*：`match` → `ready` → `first true` → `move b 0 b 3` → `chat` → `draw` / `resign` → `replay`（n/p/g）→ `rematch`。

=== Web 前端

```powershell
cd jieqi-web
npm install
npm run dev
# 浏览器 http://localhost:5173
# 登录页填 ws://127.0.0.1:8887
```

=== AI 经 WS（验收补充）

```powershell
mvn exec:java -f jieqi-app/pom.xml -am -Dexec.args="ai-ws ws://127.0.0.1:8887 ai_bot_1 pw123"
```

== 完整演示流程

*三终端手动*：

```text
终端 1: powershell -File scripts/dev-server.ps1 8887
终端 2: powershell -File scripts/run-app.ps1 client-ws ws://127.0.0.1:8887 player1 123456
终端 3: powershell -File scripts/run-app.ps1 client-ws ws://127.0.0.1:8887 player2 123456
流程: match → ready → first → move → 终局 → replay → rematch
```

*Web 双标签*：终端 1 起 server + 终端 2 `npm run dev` → 两浏览器各 login → 真人对战 → 终局 → 查看棋局。

== 一键演示

`demo.ps1` 将前述手动三步封装为一条命令，自动打开三个 PowerShell 窗口并依次启动服务端与两个客户端，适合答辩现场快速进入演示状态。脚本内部通过 `Start-Sleep` 控制启动时序，避免客户端在服务端就绪前连接失败。

```powershell
powershell -File scripts/demo.ps1
```

#table(
  columns: (auto, 1fr, auto),
  table.header([*窗口*], [*内容*], [*时机*]),
  [1], [`server-ws 8887`], [立即],
  [2], [`client-ws … player1`], [Sleep 3s 后],
  [3], [`client-ws … player2`], [紧接窗口 2],
)

== Docker（实验性）

Docker 部署为补充方案，目标场景是验收机未安装 JDK 21 或 Maven 的情况。当前状态为*实验性*：仅映射 WS 8887 端口，TCP 8888 与 Web 前端不在容器内，records 未挂载卷导致容器销毁后棋谱丢失。以下为当前可用范围与已知限制。

=== 前置与启动

#table(
  columns: (auto, auto),
  table.header([*要求*], [*检查*]),
  [Docker 24+ / Compose v2], [`docker compose version`],
  [8887 空闲], [`netstat -ano | findstr 8887`],
)

```bash
docker compose up --build       # 前台
docker compose up --build -d    # 后台
docker compose logs -f jieqi-server
docker compose down
```

=== Dockerfile 两阶段

#table(
  columns: (auto, auto, 1fr),
  table.header([*阶段*], [*镜像*], [*动作*]),
  [build], [maven:3.9.9-eclipse-temurin-21], [`mvn package -pl jieqi-app -am -DskipTests`],
  [run], [eclipse-temurin:21-jre], [`java -jar unveil-jieqi.jar server-ws 8887`],
)

=== 端口与限制

#table(
  columns: (auto, auto, auto, 1fr),
  table.header([*协议*], [*容器*], [*宿主机*], [*说明*]),
  [WS JSON], [8887], [8887 已映射], [客户端连 `ws://localhost:8887`],
  [TCP 8888], [—], [#no 未映射], [本地 `server 8888` 或改 compose],
  [jieqi-web], [—], [#no 不含], [宿主机 `npm run dev`],
  [records/], [—], [#no 未挂卷], [容器销毁后棋谱丢失；生产需 volume],
)

=== Docker vs 本地

#table(
  columns: (auto, auto, auto),
  table.header([*维度*], [*Docker*], [*本地 java/mvn*]),
  [依赖], [仅 Docker], [JDK 21 + Maven],
  [协议], [WS 8887], [WS + TCP + 全菜单],
  [客户端], [宿主机连 localhost:8887], [控制台 + Web],
  [适用], [无 Java 快速演示], [开发 / AI / 完整验收],
)

== 脚本工具箱

#table(
  columns: (auto, 1fr, auto),
  table.header([*脚本*], [*作用*], [*场景*]),
  [`verify.ps1`], [test → compile → package], [答辩前自检],
  [`demo.ps1`], [三窗口 服+双客], [8 分钟演示],
  [`dev-server.ps1`], [package + server-ws], [*开发推荐*],
  [`run-app.ps1`], [package + 任意 CLI 参数], [client-ws / server 8888],
  [`compile-docs.ps1`], [Typst → PDF], [文档交付],
  [`count-loc.ps1`], [LOC 统计], [报告数字],
)

== 常见问题速查

与 `TROUBLESHOOTING.typ` 15 项对齐。

#table(
  columns: (0.3fr, 1fr, 0.8fr, 1.5fr),
  table.header([*No.*], [*现象*], [*原因*], [*处理*]),
  [1], [Address already in use], [8887 被占用], [`netstat -ano | findstr 8887` → taskkill],
  [2], [Connection refused], [未启动 / URL 错], [`ws://127.0.0.1:8887`；先 server 后 client],
  [3], [release version 21 not supported], [JAVA_HOME 旧版], [JDK 21 + 统一 PATH],
  [4], [Unsupported class file major version], [低版本 Java 运行], [`java -version` = 21],
  [5], [verify.ps1 失败], [测试/编译失败], [`mvn test` + surefire-reports],
  [6], [AI 走子超时], [搜索超预算], [改 Easy；验收用 easy],
  [7], [棋盘不同步], [未应用 moveResult], [以服务器广播为准],
  [8], [非法走法未拒绝], [本地模式 8 非 WS], [WS 客户端验证 valid=false],
  [9], [exec:java 行为异常], [旧 SNAPSHOT], [`mvn install -pl jieqi-app -am -DskipTests` 或 dev-server.ps1],
  [10], [Docker 连不上], [端口/地址], [`docker compose ps`；localhost:8887],
  [11], [replay 无响应], [未终局 / 旧服务端], [gameOver 后；查 `.replay.json`；重编译 server],
  [12], [匹配后不开局], [未 ready / 未 first], [双方 ready + first],
  [13], [Maven 极慢], [网络], [settings.xml 国内镜像],
  [14], [demo.ps1 闪退], [Maven/路径], [根目录手动 mvn compile],
  [15], [组间消息不一致], [混协议 / 大小写], [INTERFACE v3.0；不混 WS+TCP],
)

=== 诊断命令

#table(
  columns: (0.6fr, 2fr),
  table.header([*目的*], [*命令*]),
  [全量测试], [`mvn test`],
  [单模块], [`mvn test -pl jieqi-core` / `-pl jieqi-ai` / `-pl jieqi-server`],
  [重装 JAR], [`mvn install -pl jieqi-app -am -DskipTests`],
  [查端口], [`netstat -ano | findstr 8887`],
  [Docker 日志], [`docker compose logs -f jieqi-server`],
)

详见 `TROUBLESHOOTING.pdf`。

== 启动成功标志

下表列出各启动方式的预期成功输出，供答辩验收时快速核对。

#table(
  columns: (0.8fr, 1.6fr, 1.2fr),
  table.header([*启动方式*], [*命令*], [*成功标志*]),
  [全量测试], [`mvn test`], [终端输出 `BUILD SUCCESS`；末行为 `142 tests completed`],
  [Fat JAR 打包], [`mvn package -pl jieqi-app -am -DskipTests`], [`BUILD SUCCESS` + `target/jieqi-app-*-jar-with-dependencies.jar` 存在],
  [WS 服务端], [`java -jar jieqi-app/target/unveil-jieqi.jar server-ws 8887`], [输出 `WsGameServer started on port 8887`],
  [Web 前端], [`cd jieqi-web && npm install && npm run dev`], [Vite 输出 `Local: http://localhost:5173`；浏览器大厅显示"已连接"（底部状态栏）],
  [自检], [`powershell -File scripts/verify.ps1`], [输出 `OK: verify passed` 或类似成功摘要],
  [演示], [`powershell -File scripts/demo.ps1`], [三窗口自动弹出（server + client1 + client2）；client1 输出 login/match/ready 等交互日志],
  [文档编译], [`powershell -File scripts/compile-docs.ps1`], [无 typst 报错；`docs/` 下 33 份 PDF 全部更新],
  [Docker], [`docker compose up --build`], [`jieqi-server` 容器输出 `WsGameServer started on port 8887`],
)

// ═══════════════════════════════════════════════════════════
// 第十章：产品与用户
// ═══════════════════════════════════════════════════════════
= 产品与用户

== 产品定位

Unveil 的产品定位不是传统意义上的商业棋牌游戏，而是面向课程验收与工程实践展示的揭棋对弈系统。系统以"规则可信、网络可联、AI 可战、棋局可追溯、工程可复现"为核心目标，在实现基本对弈功能的基础上，进一步补充了 WebSocket 联机、三档 AI、棋谱记录、逐步复盘、Docker 部署与 Typst 文档体系，使其从单一棋类程序扩展为一个完整的*课程级对弈产品*。

#table(
  columns: (auto, 1fr),
  table.header([*维度*], [*产品定位*]),
  [产品类型], [课程级揭棋对弈系统],
  [核心场景], [真人对战、人机对战、AI 自动对弈观战、复盘验收],
  [核心价值], [规则复杂度高、AI 有层次、网络协议清晰、工程交付完整],
  [目标用户], [课程验收教师、小组成员、测试玩家、AI/规则实现评审者],
  [非目标方向], [不追求商业化运营、排行榜生态、付费道具、社交平台化],
)

与成熟商业象棋平台相比，Unveil 并不追求用户规模、排行榜运营、付费体系或精美美术资源，而是突出揭棋规则实现、非完全信息 AI、协议联调、测试验证和工程交付。与普通课程棋类项目相比，Unveil 的复杂度主要体现在揭棋暗子机制、服务端权威规则校验、网络同步、三档 AI 和复盘快照时间线。

*产品决策优先级*：规则稳定 > AI 可解释 > 复盘可追溯 > 一键运行 > 演示流程清晰 > 商业级 GUI 炫技。架构通过分层设计表与流程图呈现，按 INTERFACE.typ v3.1 通过 8887 端口互联即可完成联调。

#img("diag_ch10_user_journey.svg", width: 96%, caption: [用户旅程 — 四模式入口 · 10 阶段主路径 · 三条典型路径差异])

== 用户角色与需求

系统面向六类典型用户，各有不同诉求：

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*用户角色*], [*主要诉求*], [*对应功能*]),
  [新手玩家], [快速进入对局，理解揭棋规则], [随机昵称、emoji 头像、暗子 `?` 标记、走子提示],
  [普通玩家], [能与真人或 AI 完成完整对局], [真人匹配、人机对弈、创建房间、认输、提和],
  [AI 体验者], [体验不同强度 AI 的棋力差异], [Easy / Medium / Hard 三档 AI、AI 自动对弈观战],
  [规则测试者], [验证复杂规则是否正确判罚], [禁止送将、长将长捉、40 步无吃子、终局原因展示],
  [课程验收者], [快速看懂项目完整度与工程水准], [功能矩阵、测试报告、接口文档、演示脚本],
  [开发维护者], [能定位问题、复现运行], [Maven 多模块、自检脚本、Docker、Typst 文档],
)

== 用户旅程

系统提供三条主要使用路径：真人对战、人机对战和 AI 自动对弈观战。以下从阶段视角展示 Web 端完整旅程。

#table(
  columns: (0.4fr, 1.5fr, 1.2fr, 1.8fr),
  table.header([*阶段*], [*用户操作*], [*用户目标*], [*系统响应*]),
  [1. 登录], [输入昵称或使用随机昵称，设置密码], [快速获得身份进入系统], [创建用户会话，分配 emoji 头像],
  [2. 选择模式], [选择真人匹配、人机对弈、AI 观战或创建房间], [进入符合需求的对局], [建立房间、启动匹配或绑定 AI],
  [3. 选择难度], [人机模式选择 Easy / Medium / Hard], [获得不同难度的 AI 体验], [绑定对应 AiBot 策略],
  [4. 对弈], [在 10×9 棋盘点击棋子与目标格走子], [完成合法走子], [服务端校验后广播 `moveResult`],
  [5. 信息同步], [接收对手走子、聊天、计时变化], [保持双方状态一致], [WebSocket 推送棋盘变化与消息],
  [6. 辅助操作], [快捷消息、提和、认输、暂停、手动加时], [完成对局中的辅助决策], [服务器广播操作结果],
  [7. 终局], [查看胜负、原因、被吃棋子揭晓], [明确对局结果], [弹窗显示胜负与终局原因],
  [8. 复盘], [点击「查看棋局」，逐步查看棋盘快照], [回看关键走法与局面变化], [请求 `replayFrame` 并渲染历史局面],
  [9. 重赛], [点击「再来一局」，双方确认], [快速开启下一局], [双方确认后重置房间和棋盘],
  [10. 离开], [返回大厅或退出], [结束当前会话], [清理状态或保留历史棋谱],
)

=== 三条典型路径差异

#table(
  columns: (auto, auto, auto, auto),
  table.header([*步骤*], [*真人对战*], [*人机对战*], [*AI 自动对弈*]),
  [匹配], [需第二名玩家 `startMatch` 或房间号], [单人 `startAiGame`，无需对手], [无需玩家，双 Bot 自动对战],
  [准备], [双方 `Ready` + 协商先手], [自动开局], [自动开局],
  [走子], [双方轮流，65s 步时限制], [用户走 → AI 思考后应招], [双 AI 自动循环，用户观战],
  [辅助功能], [聊天、提和、认输完整支持], [提和/认输可用；聊天可选], [可暂停/结束；无聊天需求],
  [复盘], [终局后 `replayFrame` 逐步回看], [同左], [同左（若走完终局）],
)

=== 控制台旅程（验收补充）

教师或开发者可用 `jieqi-client` 走同一协议链路：`login` → `match` → `ready` → `first` → `move e6 e5` → `replay` → `rematch`。ASCII 棋盘用 `?` 标记暗子，命令行输出 `moveResult.valid` 与 `flipResult`，便于对照 INTERFACE.pdf 字段逐项验收。

== 用户痛点与产品价值

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*痛点*], [*传统做法的问题*], [*Unveil 解决方案*]),
  [揭棋规则复杂], [暗子/翻子/强化士象/长将长捉，人工判断易错漏], [服务端 RuleValidator 权威校验 + 89 项 core 单测覆盖全部规则分支],
  [棋盘状态不同步], [自写 Socket 通信易出现状态漂移、双方看到不同局面], [WebSocket JSON 广播 `moveResult`，服务器为唯一真相源（Single Source of Truth）],
  [AI 透视作弊], [简单 AI 实现可能直接读取对手暗子真实 `type`，破坏信息差], [`createAiPublicView` 脱敏视角 + `AiFairnessTest` 不透视约束 + 剩余子力池合法采样],
  [复盘无法还原暗子], [走法文本重放无法复现随机翻子结果，复盘局面与实际对局不一致], [`ReplayTimeline` 逐步棋盘快照 + `.replay.json` 持久化，每帧含完整 `board[]`],
  [验收不可复现], [环境杂乱、依赖手工配置、无可重复的标准验收流程], [Maven 多模块 + `verify.ps1` 自检脚本 + `demo.ps1` 一键演示 + Docker 容器化],
  [组间无法互联], [各组协议字段命名与 `messageType` 不统一，互操作失败], [INTERFACE.typ v3.1 权威规范 + 8887 公共端口 + 全 `messageType` 表可查],
)

== 核心体验设计

=== 轻量身份设计

系统不采用复杂注册流程，而是提供昵称、密码与 emoji 头像的轻量身份机制。用户可以输入自定义昵称，也可以使用系统生成的趣味昵称，例如「隐形小炮兵」。这种设计既满足 WebSocket 对局中区分玩家身份的需要，又避免课程演示时在账号注册环节消耗过多时间。

=== 模式分层设计

系统将对局入口分为真人对战、人机对弈、AI 自动对弈观战与创建房间四类。真人对战用于展示网络同步能力与完整协议消息；人机对弈用于展示 AI 算法能力与难度分层；AI 自动对弈观战用于演示系统稳定运行与双 Bot 搜索决策差异；创建房间则满足指定双方联调与测试需要。

=== 对弈交互设计

棋盘采用 10×9 坐标布局，暗子以问号标记，明子显示真实棋子名称。用户通过点击棋子和目标格完成走子，前端进行基础交互提示，最终合法性由服务端规则引擎统一判断。该设计避免了客户端和服务端规则不一致的问题，保证网络对局中的*状态权威性*。

=== 终局与复盘设计

终局后系统通过弹窗展示胜负结果、终局原因以及被吃棋子揭晓信息（上帝视角），使玩家能够理解对局结束的直接原因。复盘功能不采用单纯走法文本重放，而是基于每一步后的棋盘快照进行回放，能够稳定处理揭棋中的暗子、翻子与随机身份问题，提升对局可追溯性。

== 竞品选择依据

为了评价 Unveil 的产品完整度，本文选取三类参照对象：

#table(
  columns: (auto, 1fr),
  table.header([*类别*], [*代表与说明*]),
  [商业在线象棋平台], [天天象棋、JJ 象棋等，代表成熟在线对战产品，偏大众娱乐与竞技],
  [通用中国象棋 App], [以「中国象棋」为名称或关键词的移动端棋类应用，代表轻量单机/联网象棋体验],
  [普通课程棋类项目], [Java 五子棋、黑白棋、标准象棋课设，代表同类课程作业的常见实现水平],
)

*需要说明的是*，Unveil 并不试图在用户规模、商业运营、赛事体系和视觉美术上与成熟商业产品竞争，而是在揭棋规则、非完全信息 AI、协议联调、复盘快照和工程交付方面突出课程项目的技术完整度。

== 竞品对比

#table(
  columns: (auto, auto, auto, auto, auto),
  table.header([*维度*], [*Unveil*], [*天天象棋 / JJ 象棋类商业平台*], [*通用中国象棋 App*], [*普通 Java 棋类课设*]),
  [棋种规则], [揭棋变体：暗子、翻子随机、明士明象强化、长将长捉], [以标准中国象棋为主，部分平台可能支持变体], [多以标准中国象棋为主], [多为五子棋、黑白棋或标准象棋],
  [信息结构], [非完全信息，对手暗子未知], [多为完全信息棋局], [多为完全信息棋局], [多为完全信息棋局],
  [AI 设计], [Easy/Medium/Hard 三档，Alpha-Beta + Belief Sampling 可公开说明], [偏产品化 AI 或残局训练，算法细节通常不公开], [通常提供人机难度，但算法不可见], [常见为随机、贪心或简单 Minimax],
  [网络对战], [WebSocket JSON 协议，服务端权威校验，课程公共接口互操作], [成熟联网匹配与好友对战体系], [部分支持联网，部分偏单机], [多数无网络或仅本地双人],
  [复盘方式], [ReplayFrame 逐步棋盘快照，稳定还原暗子翻子], [常见为棋谱/回放/分析功能], [常见为棋谱或简单悔棋], [多数无复盘或仅文本记录],
  [工程结构], [Maven 多模块：core/server/client/ai/app/web], [商业闭源工程，外部不可见], [多为闭源 App], [常见单模块或少量类],
  [文档交付], [Typst/PDF 全生命周期文档：接口、测试、部署、产品分析], [面向用户帮助页面，非代码级文档], [面向用户使用说明], [通常只有 README 或课程报告],
  [可测试性], [142 项自动化测试 + 自检脚本 + 功能矩阵], [外部不可验证内部测试], [外部不可验证内部测试], [测试覆盖通常较弱],
  [课程适配], [高：强调规则、协议、AI、文档、部署，全套可演示], [低：偏商业应用，不可作为课程参考], [中：偏用户体验], [中：偏基础编程能力],
)

*定位结论*：Unveil 的目标不是在 UI 上超越商业象棋产品，而是在*课程评分维度*（规则正确性、协议互操作、AI 算法深度、测试与文档完整性、工程交付可复现性）上提供完整、可审计、可 8 分钟演示的解决方案。商业平台的价值在用户规模与运营体系，课程项目的价值在技术完整度与可解释性——两者评估维度不同，不存在直接竞争关系。

== 差异化价值

Unveil 的差异化价值主要体现在五个方面：

#table(
  columns: (auto, 1fr),
  table.header([*价值点*], [*具体体现*]),
  [1. 揭棋规则复杂度高], [暗子、翻子随机、士象强化、长将长捉等规则比标准象棋更复杂；服务端 89 项单测覆盖全部规则分支],
  [2. 非完全信息 AI 更有区分度], [Hard AI 通过 Belief Sampling 处理对手暗子不确定性，不直接透视；Medium 使用 Agent 编排 Alpha-Beta；三档棋力可感知],
  [3. 服务端权威校验更适合网络对弈], [客户端只负责交互，规则由服务端统一判断；`createAiPublicView` 脱敏视角防止 AI 作弊],
  [4. 复盘采用棋盘快照时间线], [不是简单文本重放；每步后棋盘完整快照，能稳定还原暗子翻子后的局面，适配揭棋的随机信息特征],
  [5. 工程交付完整], [Maven 5 模块 + Fat JAR + verify.ps1 自检 + demo.ps1 演示 + Docker 部署 + Typst 文档体系，形成代码、测试、部署、接口、文档一体化闭环],
)

== 功能完成度总览

=== 总览统计

#table(
  columns: (auto, auto, 1fr),
  table.header([*状态*], [*数量*], [*含义*]),
  [#ok 已实现], [48 项], [功能已完成，可在主流程中流畅演示],
  [#warn 待强化], [12 项], [已有基础实现，但边界测试或体验仍需完善],
  [#ok 实验性], [1 项], [已提供工程入口（Docker），但不作为主验收承诺],
  [#no 规划中], [4 项], [已形成设计方案，预留扩展接口，后续版本实现],
  [*合计*], [*65 项*], [覆盖规则、网络、AI、复盘、工程和文档全部维度],
)

=== 按模块统计

#table(
  columns: (auto, auto, auto, auto, auto, 1fr),
  table.header([*模块*], [*已实现*], [*待强化*], [*实验性*], [*规划中*], [*说明*]),
  [规则引擎], [12], [3], [0], [0], [覆盖七种走法、暗子约束、终局判定、长将长捉],
  [网络对弈], [8], [2], [0], [1], [WebSocket 主协议、房间、匹配、广播、断线重连],
  [AI 算法], [7], [3], [0], [1], [三档 AI、搜索优化、Belief Sampling、残局加深],
  [棋谱复盘], [5], [2], [0], [1], [文字棋谱、复盘时间线、replay.json 持久化],
  [客户端体验], [6], [2], [0], [1], [棋盘渲染、终局弹窗、复盘控件、聊天表情],
  [工程部署], [5], [0], [1], [0], [Maven 多模块、Fat JAR、自检脚本、Docker],
  [文档交付], [5], [0], [0], [0], [Typst/PDF 文档体系，覆盖全生命周期],
  [*合计*], [*48*], [*12*], [*1*], [*4*], [*共 65 项*],
)

== 产品不足与后续规划

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*不足*], [*当前影响*], [*后续规划*]),
  [图形界面偏课程演示], [视觉效果和动画细节不如成熟商业平台], [增加主题皮肤、走法动画、音效反馈],
  [复盘以快照为主], [暂不支持 AI 自动讲解和关键步分析], [增加关键步标注、局势评分曲线与 AI 点评],
  [AI 未引入训练模型], [棋力弱于成熟商业引擎（依赖手工权重）], [引入开局库、残局库与自我对弈数据],
  [用户体系较轻量], [暂不支持长期战绩、等级分和排行榜], [增加用户战绩统计、ELO 等级分与对局历史],
  [移动端适配有限], [手机浏览器体验不足], [响应式布局优化，提升移动端可用性],
)

// ═══════════════════════════════════════════════════════════
// 第十一章：项目管理
// ═══════════════════════════════════════════════════════════
= 项目管理

#img("diag_ch11_project_management.svg", width: 96%, caption: [项目管理 — 四人分工 · 四大任务书 63 项 · 交付验收闭环])

== 团队分工

#let zhk-desc = [
  架构设计与 AI 算法：主导 Maven 5 模块划分与单向依赖设计；设计 WebSocket JSON 协议 v3.1（含全部 messageType 枚举与错误码体系）。
  编写三档 Bot，实现 Alpha-Beta 搜索七项优化（迭代加深 ID + TT 置换表 2^20 槽 Zobrist 索引 + Aspiration Window +/-80 + PVS + LMR + Killer/History 启发式 + Quiescence Search + SEE 过滤亏交换）。
  设计 Belief Sampling 非完全信息搜索：BoardSampler 均匀采样 + 每次 4 确定化 AB + 期望取优；多 Agent 编排（ProbabilityAgent/EndgameAgent/SearchAgent）；七维线性加权评估 EnhancedEvaluator；isRepeatedCheckRisk 长将规避（>=5 次扣分 -100000）。

  规则引擎与终局判定：设计 Board 聚合根 + ChessPiece 三字段状态模型（type/virtualType/revealed）+
  RuleValidator 双层校验（isValidMove 几何 + isMoveLegal 送将检查）+ generateStrictLegalMoves（generate-and-test 范式）+
  EndgameJudge 固定优先级判定链（吃将→将死→困毙→80 步和→长将/长捉/兵卒长捉）。positionKey 字符串哈希用于重复计数，ZobristHash 64-bit XOR 用于 AI 置换表索引。

  棋谱、复盘与协议：设计 ReplayTimeline 快照时间线（stepIndex=0 开局帧 + 每步 recordAfterMove 独立 Board 拷贝）+
  ReplayRecordStore JSON 落盘（records/{gameId}.replay.json）+ WS 协议扩展（replayRequest/Frame、rematchRequest/Offer/Accept、addTime、pauseGame/resumeGame、startAiBattle、watch）。
  编写 INTERFACE.typ v3.1 权威规范、JsonMessages 工厂 + JsonMessageTypes 枚举 + BoardJsonMapper 序列化。

  文档与项目管理：八类 34 份 Typst 文档架构设计 + template.typ 模板 + FINAL_REPORT.typ 整合撰写。
  compile-docs.ps1 编译链 + count-loc.ps1 统计。Git Conventional Commits 规范（feat/fix/docs/refactor/test），分支策略（feat 分支 -> main），63 项任务拆分。
  关键决策：Typst 优先于 LaTeX、WebSocket JSON 优先于 TCP 文本帧、generate-and-test 优先于预计算走法表。
]

#table(
  columns: (1.4fr, 1.6fr, 5fr),
  table.header([*成员*], [*学号*], [*主要负责*]),
  [#nb[张恒基（组长）]], [#nb[2024211301 / 2024210926]], zhk-desc,
  [#nb[秦博宇]], [#nb[2024211302 / 2024210940]], [
    系统架构可视化：绘制 UML 类图（Board、ChessPiece、RuleValidator、EndgameJudge、ReplayTimeline、AiBot 等关键类）、模块依赖关系图（core → server/client/ai → app）、对局主流程时序图（登录、匹配、准备、先手协商、走子、终局）、通信层设计模式图（外观/单例/工厂/策略/命令），为团队统一架构认知与答辩演示提供可视化基础；
    人机对战质量保障：主导 AI 模块与 Web 前端联调验证，逐项核对六大目标的实现情况，确保所有必选功能已落地且无遗漏；通过 AiFairnessTest 对三档 AI 分别构造随机局面，验证所有输出走法均通过 RuleValidator.isMoveLegal 且 Hard 档不透视对手暗子（createAiPublicView 脱敏）；利用 BoardUndoTest 在搜索迭代中校验 makeMove/undoMove 的棋盘一致性；在 Web 前端手工模拟难度选择、AI 思考、走子同步、超时处理、提和认输、吃子显示及终局揭晓的完整用户路径；运行 startAiBattle 双 AI 自动对弈并确保所有相关测试集成至 verify.ps1，最终达成 142 项全通过；
    服务端开发：参与 WsGameServer 房间管理、匹配队列（MatchmakingService）、GameRecord 持久化与集成测试。
  ],
  [#nb[陈艺博]], [#nb[2024211302 / 2024210931]], [
    前端实现：使用 Vue 3、TypeScript、Vite、Pinia 搭建 jieqi-web 工程，完成登录页（随机昵称 + 预设头像）、大厅页（真人对战/人机对战/AI 对弈/房间对战四入口）、对局页（ChessBoard Canvas 10×9 棋盘渲染、暗子 `?` 显示、选中高亮、可走点提示）、被吃棋子展示区、局内聊天面板、人机难度选择与 AI 对弈入口等功能模块；
    WebSocket 协议联调：对接后端登录、匹配、房间、走子、终局、超时、聊天等全部 messageType，确保前端状态与服务器广播同步；
    Bug 修复：修复棋盘坐标映射错误、Canvas 事件冒泡冲突、线上 WebSocket 地址配置、AI 倒计时不同步、悔棋引发的状态残留等问题；
    部署维护：通过服务器 git pull 更新代码并重启前后端服务，保证项目可在线访问。
  ],
  [#nb[陈雨飞]], [#nb[2024211005]], [
    棋谱与复盘：参与 ReplayTimeline 数据模型设计，编写 ReplayFrame 防御性拷贝与帧编号逻辑的单测（时间线递增、拷贝隔离验证）；在 Web 前端实现复盘播放器 UI —— 步进控件（上一步/下一步/跳至开局/跳至终局）、replayBoard 渲染切换、3s 超时兜底提示、对局中脱敏/终局上帝视角（capturedReveal）切换；
    局内聊天：设计并实现 Web 端聊天面板 —— 快捷消息模板、3×5 共 15 种预设表情面板、自定义文本输入（≤ 120 字符校验）、消息归属显示（己方/对方 + 时间戳）、新消息提示音开关（chatSoundOn）；对控制台客户端 chat 命令进行同步适配；
    测试用例编写：编写 DarkPieceRuleTest（暗子走法边界 + 强化士象规则）、RuleEdgeCaseTest 部分子项（送将拦截、照面检测）；配合秦博宇完成 Web 端手工验收路径的回归测试；参与 verify.ps1 自检脚本的测试结果核对与文档同步。
  ],
)

== Git 提交规范

格式：`type: 简要描述`。type 仅限 `feat` / `fix` / `docs` / `refactor` / `test` 五种。

== 四大任务完成状态

四大任务书（`suanfatasks.typ` / `fupantasks.typ` / `chanpintasks.typ` / `wendangtasks.typ`）是组内*迭代开发的主线看板*：每条任务对应可独立验证的代码单元与验收标准，完成度以「代码落地 + 单测/集成测通过 + 文档同步」三者同时满足为准。

#table(
  columns: (auto, 1fr, auto, auto),
  table.header([*任务文档*], [*范围摘要*], [*子项*], [*进度*]),
  [suanfatasks], [jieqi-ai 三档 Bot + 搜索内核优化 + Agent 编排], [18 项], [#ok],
  [fupantasks], [ReplayTimeline 内存复盘 + JSON 落盘 + WS 协议 + 双端播放器], [14 项], [#ok],
  [chanpintasks], [对局闭环：终局摘要 / 揭晓 / rematch / 复盘 / 演示脚本], [16 项], [#ok],
  [wendangtasks], [00–07 文档体系 + Typst/PDF 编译链 + 统计脚本], [15 项], [#ok],
  [*合计*], [—], [*63 项*], [#ok],
)

详细逐项清单（含编号、代码位置、验收证据）见独立任务书文件 `suanfatasks.typ` / `fupantasks.typ` / `chanpintasks.typ` / `wendangtasks.typ`。此处仅保留摘要表。

#table(
  columns: (0.6fr, 0.4fr, 0.6fr, 1.4fr, 1.6fr),
  table.header([*任务书*], [*子项*], [*进度*], [*核心交付*], [*主要代码位置*]),
  [suanfatasks], [18], [#ok], [三档 Bot + AB 7 项优化 + Belief Sampling + Agent 编排], [`jieqi-ai/` · `AiConfig.java` · `OptimizedAlphaBeta.java`],
  [fupantasks], [14], [#ok], [ReplayTimeline 时间线 + JSON 落盘 + WS 协议 + 双端播放器], [`ReplayTimeline.java` · `ReplayRecordStore.java` · `stores/game.ts`],
  [chanpintasks], [16], [#ok], [终局摘要 + 暗子揭晓 + rematch + demo.ps1 + verify.ps1], [`GameSummary.java` · `Game.java` · `GameView.vue`],
  [wendangtasks], [15], [#ok], [34 份 Typst → 33 PDF + compile-docs.ps1 编译链], [`docs/` · `INTERFACE.typ` · `scripts/`],
  [*合计*], [*63*], [#ok], [—], [—],
)

=== 四大任务交叉验收

#table(
  columns: (auto, 1fr, auto),
  table.header([*验收命令*], [*覆盖任务*], [*预期*]),
  [`mvn test`], [suanfa + fupan + chanpin 核心逻辑], [142/142 BUILD SUCCESS],
  [`powershell -File scripts/verify.ps1`], [chanpin 工程化 + 全模块编译], [OK: verify passed],
  [`powershell -File scripts/compile-docs.ps1`], [wendang 全量 PDF], [33 PDF 产出无报错],
  [`powershell -File scripts/demo.ps1`], [chanpin 闭环演示], [三窗口 WS 对弈可跑通],
  [Web `npm run dev` + 双浏览器], [chanpin Web + fupan 播放器], [登录→对弈→终局→复盘],
)

*遗留项（不计入四大任务完成度，见 FEATURE_MATRIX P2）*：走子错误码细分、jieqi-web Playwright E2E、Hard 残局库、Docker 生产级 Web 同容器部署。

// ═══════════════════════════════════════════════════════════
// 第十二章：演示与答辩
// ═══════════════════════════════════════════════════════════
= 演示与答辩

== 演示时间线（6–8 分钟）

#table(
  columns: (auto, auto, auto, auto),
  table.header([*时间*], [*操作*], [*说词*], [*预期*]),
  [0:00], [运行 verify.ps1], ["首先运行自检脚本，编译、测试、打包全通过"], [OK: verify passed],
  [0:30], [可选展示菜单 1–9], ["项目提供统一入口"], [菜单显示],
  [1:00], [启动 WS 服务器 8887], ["启动 WebSocket 服务器"], [监听中],
  [1:30], [玩家一登录 + 玩家二登录], ["两位玩家连接认证"], [loginResult 成功],
  [2:00], [match → Ready → firstHand], ["匹配、准备、协商先手"], [gameStart + 初始棋盘],
  [3:00], [走子演示：move b7 b4], ["合法走子 + 翻子效果"], [双方同步 + flipResult],
  [3:30], [发非法走法], ["服务器拒绝非法着法"], [moveResult.valid=false],
  [4:00], [AI 演示：ai medium], ["三档 AI 对手"], [AI 5s 内走子],
  [5:00], [触发终局（将死/认输）], ["终局判定 + 广播"], [gameOver + 摘要],
  [5:30], [replay 复盘], ["回放棋盘快照时间线"], [逐步回看 n/p],
  [6:00], [总结], ["规则、网络、AI、复盘、工程化五位一体"], [—],
)

== 关键命令备忘

```text
# 自检
powershell -File scripts/verify.ps1

# 服务端
mvn exec:java -f jieqi-app/pom.xml -am -Dexec.args="server-ws 8887"

# 客户端
mvn exec:java -f jieqi-app/pom.xml -am -Dexec.args="client-ws ws://127.0.0.1:8887 player1 123456"

# 对局命令
match → ready → first → move b 0 b 3 → replay

# Web 前端
cd jieqi-web && npm run dev
```

== 风险预案

#table(
  columns: (auto, auto, auto),
  table.header([*风险*], [*备选*], [*话术*]),
  [Maven 下载慢], [用预构建 Fat JAR], ["构建已完成，直接启动产物"],
  [网络卡住], [改本地人机菜单 6], ["网络环节展示协议设计"],
  [AI 思考久], [切 `ai easy`], ["Easy 毫秒响应，Hard 展示算法"],
  [verify 失败], [展示 mvn-test-output.txt], ["今早全量测试已通过"],
)

== 答辩高频问答

*Q：为什么分 5 个模块？*
A：领域（core）、网络（server/client）、算法（ai）、入口（app）分离。core 不依赖任何外部模块，被所有层复用；server 和 client 只处理通信，不改规则；ai 独立演进，算法升级不影响对局稳定性。

*Q：如何保证规则校验正确？*
A：89 项 core 自动化测试覆盖七种走法、暗子约束、送将/照面拒止、将死/困毙全链路。校验在服务端执行，客户端不走终局逻辑。

*Q：暗子和明子走法上有何不同？*
A：暗子按 virtualType（原位角色）走子，明子按真实 type 走子。暗士限九宫、暗象不过河；翻开后明士可出九宫、明象可过河（强化规则）。

*Q：AI 是否透视对手暗子？*
A：不透视。AI 调用 `createAiPublicView` 将对手暗子 type 置 UNKNOWN。Hard 档用 Belief Sampling 对对手暗子身份多次采样后求期望。

*Q：三档 AI 的本质区别？*
A：Easy 不搜索，纯启发+随机；Medium 在公开视角上 Alpha-Beta 搜索；Hard 对外采样的确定化局面上做 Alpha-Beta 后求期望。

*Q：为什么复盘必须保存棋盘快照而非仅走法文本？*
A：翻子随机性（暗子真实 type 由服务器随机确定，重走无法复现）+ 信息差（客户端只见公开信息）+ 非确定性（同一棋谱重走结果不一致）。

*Q：一键构建 + 自检怎么实现？*
A：`verify.ps1` 依次执行 mvn test → mvn compile → mvn package，三步全过输出 "OK: verify passed"。

// ═══════════════════════════════════════════════════════════
// 第十三章：总结与展望
// ═══════════════════════════════════════════════════════════
= 总结与展望

Unveil 项目以「*规则正确 · 网络互操作 · AI 可解释 · 复盘可追溯 · 工程可自检*」为验收主线，历经需求→设计→实现→测试→文档→答辩六阶段，交付一套可运行、可演示、可组间互联的揭棋对弈系统。本章对全项目成果做收束性总结，并诚实列出已知限制与分版本演进路线。

== 项目成果总览

#table(
  columns: (auto, auto, auto),
  table.header([*维度*], [*交付物*], [*量化指标*]),
  [代码], [5 Maven 模块 + jieqi-web], [63 主代码文件 · ~8 500 LOC · 142 项单测全绿],
  [协议], [INTERFACE.typ v3.0], [8887 WS 公共消息 + 附录 B TCP + 10+ 本组扩展],
  [AI], [三档 Bot + Agent 编排], [Easy ≤ 500ms · Medium/Hard ≈ 5s · 16 项 ai 单测],
  [产品], [控制台 + Web 双端], [登录→对弈→终局→复盘→重赛 全流程],
  [工程], [脚本 + Docker + Fat JAR], [verify.ps1 · demo.ps1 · dev-server.ps1],
  [文档], [00–07 八类 + FINAL 整合], [34 Typst 源 → 33 PDF + 18 Web 截图 + 6 架构图],
)

== 技术亮点总结

以下提炼本项目区别于常规课设的技术深度。

#table(
  columns: (1fr, 2fr),
  table.header([*技术点*], [*说明*]),
  [暗子状态模型], [每个棋子同时持有 `type`（初始化随机分配的真实身份）与 `virtualType`（原位角色决定走法），辅以 `revealed` 标志；`Board.initBoard()` 通过 `Collections.shuffle` 预分配类型，`RandomRevealService` 仅防客户端伪造，不重新随机],
  [双层走法校验], [`RuleValidator.isValidMove` 判定几何合法（蹩腿/炮架/暗子 virtualType），`RuleValidator.isMoveLegal` 通过 makeMove→isInCheck→unmakeMove 确保不送将；generateStrictLegalMoves 为 generate-and-test 范式],
  [终局优先级判定], [`EndgameJudge.checkAfterMove` 按固定优先级链判定：吃将 → 将死 → 困毙 → 80半步无吃子和 → 重复局面（长将/长捉子判定）；positionKey 字符串哈希用于重复计数，每次吃子后清空],
  [Belief Sampling 非完全信息搜索], [Hard AI 通过 `BoardSampler` 从剩余子力池（2车2马2炮5兵2士2象）均匀采样对手暗子身份，对每个 candidate 执行 beliefSamples=4 次确定化 AB 搜索，取期望分最高走法；每采样独立 `new OptimizedAlphaBeta()` 消除 TT 跨采样污染],
  [Alpha-Beta 优化七件套], [迭代加深 + 置换表 TT（2²⁰ 槽 Zobrist 索引）+ Aspiration Window ±80 + PVS + LMR（quiet 降 depth） + Killer/History 启发式 + 静态搜索 + SEE 过滤亏交换],
  [复盘快照而非走法重放], [揭棋暗子随机身份导致单纯走法文本无法重放——同一走法序列每次执行翻子结果不同；因此采用 `ReplayFrame` 快照时间线（stepIndex=0 开局帧 + 每步后独立 Board 拷贝），支持对局中脱敏/终局上帝视角],
  [工程自检体系], [verify.ps1（mvn test → compile → package） + demo.ps1（三窗口自动化） + dev-server.ps1（防 SNAPSHOT 过期） + compile-docs.ps1（34→33 PDF），四条脚本构造可重复验证的验收闭环],
)

== 已完成功能

各模块的详细功能说明与实现细节参见对应设计章节（§4 规则引擎、§5 AI 算法、§6 客户端、§7 棋谱与复盘），产品级功能对比见 §10 产品与用户。此处仅提供答辩速查级总览。

#table(
  columns: (auto, 1fr, auto),
  table.header([*模块*], [*一句话*], [*状态*]),
  [#ok 规则引擎], [七种走法 + 暗子 + 强化士象 + 终局全链路，89 项单测], [#ok],
  [#ok WebSocket 对弈], [8887 公共接口：匹配/房间/超时/聊天/提和/认输/加时/暂停], [#ok],
  [#ok TCP 兼容], [8888 附录 B 文本帧，legacy 联调], [#ok],
  [#ok 三档 AI], [Easy 启发 / Medium AB+7 项优化 / Hard Belief，16 项单测], [#ok],
  [#ok 棋谱与复盘], [棋谱 + 时间线 + JSON + replayRequest/Frame], [#ok],
  [#ok Maven 多模块], [5 模块 + Fat JAR + verify + demo], [#ok],
  [#ok 控制台客户端], [10 模式 + ConsoleUI + replay n/p/g], [#ok],
  [#ok Web 前端], [Vue3 全流程 + 18 张界面截图入 FINAL], [#warn],
  [#ok 文档体系], [34 Typst → 33 PDF，八大类], [#ok],
  [#ok 测试], [142/142 BUILD SUCCESS], [#ok],
)

== 已知限制

诚实列出当前边界——不影响课程主验收，但答辩时应主动说明。

=== P1 — 短期应强化

#table(
  columns: (1fr, 1.5fr, 1.5fr, 1fr),
  table.header([*限制*], [*现状*], [*影响*], [*缓解*]),
  [走子错误原因不细分], [`RuleValidator` 返回 boolean；`processMove` 仅「非法走法/不能送将」], [客户端无法精确提示；与 errorCode 2001/2002 未对齐], [V1.1 引入 RejectionReason 枚举],
  [长捉分类简化], [`findChaseTarget` 用 isValidMove 近似「捉」], [隔子捉/连环捉/将杀捉未区分；极端局面需人工裁], [V1.1 补 10+ 边界用例 + 裁判三分],
  [Web 复盘部署依赖], [UI 与协议已就绪], [旧 SNAPSHOT 服务端无 handleReplayRequest 则超时], [dev-server.ps1 重编译部署],
  [双端校验反馈不一致], [服务端权威；客户端预校验弱], [无效 WS 往返多], [V1.1 客户端映射相同 reason],
  [验收标准 C12 长将长捉], [主路径单测通过], [FEATURE_MATRIX 仍标"待强化"], [补集成测后改"已实现"],
)

=== P2 — 中期可优化

#table(
  columns: (1fr, 2fr, 2fr),
  table.header([*限制*], [*说明*], [*影响范围*]),
  [Hard AI Belief 开销], [beliefSamples=4, maxCandidatesForBelief=6；每采样独立迭代加深，实际深度由时间预算与局面分支数决定], [Hard 棋力上限；验收可演示算法],
  [残局库缺失], [EndgameAgent 仅加深时间，无表库], [残局精确度依赖搜索到底],
  [generateAllMoves 暴力], [每子枚举 90 格], [AI 节点吞吐；Medium 深度上限],
  [局面哈希双轨], [Game 用字符串 key；AI 用 Zobrist], [重复判定与 TT 未统一],
  [jieqi-client 无单测], [依赖 server 集成间接覆盖], [客户端回归风险],
  [jieqi-web 无 E2E], [无 Playwright 自动化], [UI 回归靠手工截图],
  [Docker 不完整], [仅 WS 8887；无 Web 同容器；records 未挂卷], [生产部署需扩展 compose],
)

=== P3 — 已知不追求（课设边界）

#table(
  columns: (0.8fr, 2fr),
  table.header([*项*], [*说明*]),
  [商业级 GUI], [不追求 3D/动画/皮肤商城；Web 满足演示],
  [用户增长/付费], [无账号体系、无排行榜（V2 再议）],
  [Redis 分布式房间], [单机内存 RoomManager 已满足验收],
  [断线重连保局], [当前断线倾向判负；非 P0],
  [Null-Move / ISMCTS], [AI 任务书明确不做],
  [强化士象争议], [按组内协议实现；与传统揭棋可能不一致],
)

== 后续规划

=== 版本路线图

#table(
  columns: (0.3fr, 0.5fr, 0.8fr, 1.2fr),
  table.header([*版本*], [*时间*], [*目标*], [*成功标准*]),
  [V1.0], [当前], [课程验收交付], [verify 全绿 · 8 分钟演示 · INTERFACE 对齐],
  [V1.1], [短期 1–2 周], [规则可观测 + 复盘生产 + 长捉边界], [errorCode 2001/2002 · Web 复盘稳定 · 长捉测例 +10],
  [V2.0], [中期 1–2 月], [产品化 + 互操作], [旁观大厅 · 联调矩阵 · Web 体验 polish],
  [V3.0], [远期], [竞技与智能升级], [残局库 · NN 评估 · 移动端],
)

=== V1.1（短期）— 规则与复盘加固

#table(
  columns: (auto, 1fr, auto),
  table.header([*任务*], [*内容*], [*负责模块*]),
  [R1], [`RuleValidator` → `ValidationResult(reason, code)`], [jieqi-core],
  [R2], [WsGameServer error 消息对齐 INTERFACE 错误码], [jieqi-server + INTERFACE.typ],
  [R3], [Web/控制台 toast 显示具体规则名], [jieqi-web / jieqi-client],
  [R4], [长捉：isMoveLegal 过滤 + 将/杀/捉分类], [EndgameJudge],
  [R5], [RuleEdgeCaseTest 补隔子捉/连环捉等 10 用例], [jieqi-core test],
  [R6], [Web 复盘：dev-server 部署文档 + 集成冒烟清单], [docs + scripts],
  [R7], [FEATURE_MATRIX 长将/长捉/错误码 待强化→已实现], [docs],
)

=== V2.0（中期）— 产品化与互操作

#table(
  columns: (auto, 1fr),
  table.header([*方向*], [*规划内容*]),
  [旁观大厅], [watch 从实验命令升级为 Web 入口；房间列表 + 只读棋盘],
  [排行榜], [Elo/胜率统计；需持久化用户战绩（可选 SQLite）],
  [多组联调矩阵], [与 2–3 组按 INTERFACE v3.0 互操作测试表；记录兼容差异],
  [Web 完整体验], [音效/动画 polish · 移动端响应式布局 · 断线提示优化],
  [走子错误 UX], [棋盘高亮违规格 · 建议合法着法列表],
  [Docker 全栈], [compose 含 jieqi-web nginx + records volume + 8887/8888],
)

=== V3.0（远期）— 竞技与智能

#table(
  columns: (auto, 1fr),
  table.header([*方向*], [*规划内容*]),
  [残局数据库], [车兵/马兵等典型残局表；EndgameAgent 查表 + 搜索 hybrid],
  [神经网络评估], [替代/辅助 PST 子力评估；需训练数据与推理框架],
  [移动端], [Vue 响应式或 Uni-app；触屏走子手势],
  [分布式], [Redis 房间状态 · 多实例 WS 负载均衡（超出课设）],
  [更强 Hard AI], [ISMCTS / 更深 Belief · 对手建模非均匀采样],
)

=== 四大任务与版本对应

#table(
  columns: (auto, auto, auto),
  table.header([*任务书*], [*V1.0 状态*], [*V1.1+ 演进*]),
  [suanfatasks], [#ok 三档 Bot + AB 优化], [Hard 深度/采样调参 · 走法生成性能],
  [fupantasks], [#ok 时间线 + 协议 + 落盘], [Web E2E · 对局中脱敏复盘 UI],
  [chanpintasks], [#ok 闭环 + demo/verify], [错误码 UX · stats/record 命令],
  [wendangtasks], [#ok 34 Typst + PDF], [V1.1 同步 FEATURE_MATRIX 状态变更],
)

== 关键子系统关联总览

聊天室、测试、复盘三项功能在架构上*相互独立*，各自职责清晰：

#arch-diagram(
  "
  +------------------------------------------------------------------+
  |                        Unveil 系统                                |
  +------------------+------------------+----------------------------+
  |      聊天室       |       测试        |          复盘              |
  |   (实时通信)      |   (质量保障)       |       (对局回顾)            |
  +------------------+------------------+----------------------------+
  |  WebSocket/TCP   |  JUnit 5 + CI     |  纯前端 Pinia Store         |
  |  仅真人模式      |  core/server/ai    |  BoardState 树形快照        |
  |  无持久化        |  3/6 模块有测试    |  主链回放 + 分支探索         |
  |  服务端时间戳    |  无覆盖率工具      |  无 AI 参与复盘              |
  +------------------+------------------+----------------------------+
  ",
  caption: [聊天室、测试、复盘三项功能架构关系],
  size: 7.5pt,
)

- *聊天室*是实时通信层，依赖 WebSocket 广播机制，服务端与前端双重校验仅真人可用
- *测试*是横切关注点，覆盖核心领域逻辑（89 项）与协议集成（37 项），CI 自动化保障
- *复盘*是前端交互层，以 BoardState 树记录对局快照并支持事后探索，与服务端持久化解耦

== 结语

Unveil 在课程要求的*面向对象设计、网络对弈、规则校验、AI 博弈、文档与测试*各维度均给出可运行、可审计、可演示的交付物。V1.0 的目标是*验收通过*而非商业产品完备；V1.1 聚焦「规则可解释、复盘可生产、长捉可辩护」三项答辩高频追问；V2.0 及以后视课程后续或开源维护意愿再迭代。

*项目仓库*：`Unveil/` · *主协议*：`docs/INTERFACE.typ` v3.0 · *自检*：`powershell -File scripts/verify.ps1` · *演示*：`powershell -File scripts/demo.ps1`

// ═══════════════════════════════════════════════════════════
// 附录
// ═══════════════════════════════════════════════════════════
= 附录

== A. TCP 文本帧扩展协议（摘要）

TCP 端口 8888，帧格式：`msgType|payloadByteLength|payload\n`

#table(
  columns: (auto, auto, auto),
  table.header([*消息类型*], [*msgType*], [*说明*]),
  [MSG_LOGIN], [1], [客户端登录],
  [MSG_MOVE], [2], [走子请求],
  [MSG_GAME_STATE], [3], [游戏状态同步],
  [MSG_ERROR], [4], [错误消息],
  [MSG_QUIT], [5], [退出],
  [MSG_GAME_OVER], [6], [游戏结束],
  [MSG_BOARD_STATE], [7], [棋盘状态同步],
  [MSG_DRAW_REQUEST], [8], [提和],
  [MSG_RESIGN], [9], [认输],
  [MSG_CHAT], [10], [聊天],
)

TCP 扩展支持多盘 `gameId` 字段，完整规范见 INTERFACE.typ 附录 B。

== B. 文档体系完整清单

#table(
  columns: (auto, 1fr, auto),
  table.header([*类别*], [*文档*], [*格式*]),
  [00-概览], [PROJECT_OVERVIEW · FEATURE_MATRIX · GLOSSARY], [Typst + PDF + MD],
  [01-需求], [REQUIREMENTS · ACCEPTANCE_CRITERIA], [Typst + PDF + MD],
  [02-设计], [ARCHITECTURE · DOMAIN_MODEL · AI_DESIGN · RULE_ENGINE_DESIGN · REPLAY_DESIGN], [Typst + PDF + MD],
  [03-接口], [INTERFACE · MESSAGE_EXAMPLES · INTEROP], [Typst + PDF + MD],
  [04-部署], [BUILD_AND_RUN · DOCKER_DEPLOYMENT · TROUBLESHOOTING], [Typst + PDF + MD],
  [05-测试], [TEST_PLAN · TEST_CASES · TEST_REPORT · COMPLETION_REPORT], [Typst + PDF + MD],
  [06-产品], [PRODUCT_REQUIREMENTS · USER_JOURNEY · COMPETITOR_ANALYSIS], [Typst + PDF + MD],
  [07-答辩], [FINAL_REPORT · DEMO_SCRIPT · DEFENSE_QA], [Typst + PDF + MD],
  [根目录], [README · TEAM · TASKS_COMPLETION_STATUS], [Typst + PDF + MD],
  [任务拆解], [suanfatasks · fupantasks · chanpintasks · wendangtasks], [Typst + PDF + MD],
)

合计：34 份 Typst 源文件 → 33 份 PDF + `template.typ` 共享模板。

== C. 术语速查

#table(
  columns: (auto, 1fr),
  table.header([*术语*], [*定义*]),
  [揭棋], [中国象棋变体：开局仅将/帅明置，其余 15 子暗置并按原位角色走子；首次移动/吃子后随机翻开],
  [暗子], [未翻开的棋子：真实 type=UNKNOWN，按 virtualType（原位角色）走子],
  [明子], [已翻开的棋子：按真实 type 走子；明士可出九宫、明象可过河（强化规则）],
  [virtualType], [棋子所在格*开局原位*对应的象棋角色类型，暗子走子依据],
  [强化士象], [揭棋特有规则：翻开后的士可出九宫斜走全场、象可过河走田字；暗士仍限九宫、暗象不过河],
  [翻子], [暗子首次移动 `revealed = true`，真实 `type` 在 `Board.initBoard()` 阶段已通过 `Collections.shuffle` 随机分配并写入棋盘；`RandomRevealService` 仅清除客户端伪造 `type`，走子后写回服务端真实类型],
  [复盘时间线], [ReplayTimeline：List⟨ReplayFrame⟩，对局每步（含开局）的棋盘完整快照],
  [Belief Sampling], [Hard AI 算法：对对手暗子身份多次随机采样，在每个确定化局面上 AB 搜索后取期望收益最高的走法],
  [ZobristHash], [64 位局面哈希，用于置换表索引和长将/长捉重复局面判定],
  [capturedReveal], [终局 gameOver 消息字段：对局中所有被吃暗子的真实身份揭晓（上帝视角）],
)

== D. 构建命令速查

```text
# 全量测试
mvn test

# 编译
mvn compile

# 打包 Fat JAR
mvn package -pl jieqi-app -am -DskipTests

# 启动服务端（WS 8887）
java -jar jieqi-app/target/unveil-jieqi.jar server-ws 8887

# 自检
powershell -File scripts/verify.ps1

# 演示
powershell -File scripts/demo.ps1

# 编译全部文档 PDF
powershell -File scripts/compile-docs.ps1

# 编译协议权威 PDF
typst compile docs/INTERFACE.typ docs/INTERFACE.pdf --root docs

# Web 前端
cd jieqi-web && npm install && npm run dev
```

== E. 版本历史

*版本号方案*：项目对外交付版本自 *V0.1（2026-05-22）* 起算，V1.0 为课程验收基线。INTERFACE 协议独立维护 `v0.0.0 → v3.1` 版本线（见 INTERFACE.typ 附录 C）。

#table(
  columns: (1.1cm, 2.2cm, 1fr),
  stroke: (x, y) => if y < 1 { (bottom: 0.5pt + black) },
  align: (center + horizon, center + horizon, left),
  table.header([*版本*], [*日期*], [*主要变更*]),
  [V0.1], [2026-05-22], [
    Maven 多模块骨架（core / server / client / ai / app / record）；
    Board、ChessPiece、RuleValidator、Game 领域模型与棋规；
    TCP 文本帧协议（msgType\|len\|payload）与 GameServer / GameClient；
    Alpha-Beta 基础搜索、局面评估函数与 Zobrist 哈希；
    控制台 ASCII 棋盘与交互菜单 1–10
  ],
  [V0.2], [2026-05-29], [
    INTERFACE.typ v3.0：WebSocket + JSON 升为正文主协议，默认端口 8887；
    TCP 协议迁移至附录 B；WsGameServer / WsGameClient WebSocket 实现；
    课程公共 messageType 全量对接（login → gameOver）与 errorCode 体系；
    组间联调清单与典型时序图
  ],
  [V0.3], [2026-06-08], [
    AI 三档 Bot：Easy Top-K 随机 / Medium 迭代加深 AB+TT / Hard Belief 采样；
    AgentOrchestrator 编排（Probability → Endgame → Search）；
    GameRecord 棋谱记法、ReplayTimeline 内存时间线、replay.json 落盘；
    局内聊天 chatMessage、提和/认输/加时/暂停辅助功能；
    jieqi-web Vue 3 前端骨架：Login/Lobby/Game 三页与 Canvas 棋盘
  ],
  [V0.4], [2026-06-15], [
    Web 前端产品闭环：随机昵称 + emoji 头像、被吃棋子信息差展示；
    终局弹窗（胜负 + 原因 + 上帝视角 capturedReveal）；
    聊天快捷语 + 15 种 emoji 面板；
    登录/匹配/房间创建二次确认防误触；
    BoardAiPublicViewTest 暗子脱敏校验、AiFairnessTest 公平性测例
  ],
  [V1.0], [2026-06-18], [
    *课程验收交付基线*；142 项测试全绿（core 89 + ai 16 + server 37）、BUILD SUCCESS；
    34 份 Typst 文档与 33 份 PDF，含本 FINAL_REPORT 整合终稿；
    18 张 Web 截图 + 6 张架构图入终稿；
    verify.ps1 自检 / demo.ps1 演示 / dev-server.ps1 开发部署脚本；
    Fat JAR 单文件启动、Docker Compose WS 8887；
    INTERFACE.typ v3.1：27 条自检清单、§14 实现状态标注、附录 C 版本历史
  ],
  [V1.1], [计划 2026-06-25], [
    RuleValidator 返回 RejectionReason 枚举，errorCode 2001/2002 对齐 INTERFACE；
    长将/长捉分类强化（将/杀/捉三分、隔子捉/连环捉 10+ 边界用例）；
    Web 复盘生产部署稳定、双端校验反馈一致；
    FEATURE_MATRIX 长将/长捉/错误码 待强化→已实现
  ],
  [V2.0], [计划 1–2 月], [
    旁观大厅（房间列表 + 只读棋盘 Web 入口）；
    多组联调矩阵（2–3 组 INTERFACE v3.1 互操作测试表）；
    Elo/胜率排行榜（SQLite 持久化）；
    Web 体验 polish（移动端响应式、音效/动画、走子错误 UX）；
    Docker 全栈 compose（jieqi-web nginx + records volume + 8887/8888）
  ],
  [V3.0], [远期], [
    残局数据库（车兵/马兵典型残局表 + EndgameAgent 查表 hybrid）；
    神经网络局面评估（替代/辅助手工权重 PST）；
    移动端（Vue 响应式或 Uni-app，触屏走子手势）；
    更强 Hard AI（ISMCTS / 更深 Belief / 对手建模非均匀采样）；
    分布式（Redis 房间状态、多实例 WS 负载均衡）
  ],
)

// ═══════════════════════════════════════════════════════════
#align(center)[
  #v(2em)
  #line(length: 40%, stroke: 0.5pt + rgb("#cbd5e1"))
  #v(1em)
  #text(size: 12pt, fill: rgb("#475569"))[Unveil 揭棋对弈系统 — 最终报告（初版）]
  #v(0.3em)
  #text(size: 10pt, fill: rgb("#94a3b8"))[第一组 · 张恒基 秦博宇 陈艺博 陈雨飞 · 2026-06-18]
]
