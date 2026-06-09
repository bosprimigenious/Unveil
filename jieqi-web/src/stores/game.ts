import { defineStore } from 'pinia'
import { ws, type WsMessage } from '../services/ws'
import {
  initialJieqiBoard, type Piece, type PieceType,
  type MoveRecord, type BoardState, type PieceStatus,
  pieceId, nextStateId,
} from '../types/chess'
import { getMoveErrorMessage, getValidMoves, isInCheck, isCheckmate, isStalemate, pieceAt } from '../utils/chessRules'

export type Color = 'red' | 'black'

export interface RoomInfo {
  roomId: string
  opponentId: string
  opponentNickname: string
  mode: 'human' | 'humanAi' | 'aiBattle'
}

export interface GameStartInfo {
  redPlayerId: string
  blackPlayerId: string
  yourColor: Color
  firstHand: boolean
}

export type ConnectionStatus = 'connecting' | 'open' | 'closed' | 'error'

export interface ChatMessage {
  id: string
  fromUserId: string
  fromColor: Color
  content: string
  timestamp: number
  mine: boolean
}

const COLS = ['a','b','c','d','e','f','g','h','i']

function defaultServerUrl(): string {
  const configured = import.meta.env.VITE_WS_URL
  if (configured) return configured
  if (typeof window === 'undefined') return 'ws://127.0.0.1:8887'
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  const host = window.location.hostname || '127.0.0.1'
  return `${protocol}//${host}:8887`
}

// 把老师协议里的英文 type 转成内部 PieceType
function mapType(t: string | undefined): PieceType | undefined {
  if (!t) return undefined
  const m: Record<string, PieceType> = {
    king: 'king', advisor: 'advisor', guard: 'advisor', bishop: 'bishop',
    rook: 'rook', knight: 'knight', cannon: 'cannon', pawn: 'pawn',
  }
  return m[t.toLowerCase()]
}

function mapColor(c: string | undefined): Color | undefined {
  if (!c) return undefined
  const normalized = c.toLowerCase()
  if (normalized === 'red') return 'red'
  if (normalized === 'black') return 'black'
  return undefined
}

function colToIdx(x: string | number): number {
  if (typeof x === 'number') return x
  return COLS.indexOf(String(x).toLowerCase())
}

function rowToProtocolY(row: number): number {
  return row
}

function protocolYToRow(y: string | number): number {
  return Number(y)
}

function coordText(col: number, row: number): string {
  return `${COLS[col] ?? '?'}${row}`
}

function connectionStatusText(status: ConnectionStatus): string {
  const labels: Record<ConnectionStatus, string> = {
    connecting: '连接中',
    open: '已连接',
    closed: '未连接',
    error: '连接异常',
  }
  return labels[status]
}

function gameOverReasonText(reason?: string): string {
  const labels: Record<string, string> = {
    checkmate: '将死',
    stalemate: '困毙',
    timeout: '超时',
    resign: '认输',
    disconnect: '断线',
    king_captured: '吃将',
    draw_no_capture: '无吃子和棋',
    repetition_loss: '重复局面判负',
    repetition_draw: '重复局面和棋',
    draw_agreed: '双方同意和棋',
    unknown: '未知原因',
  }
  return labels[reason || ''] || '未知原因'
}

function normalizeServerMessage(message: string | undefined): string {
  if (!message) return '未知错误'
  return message
    .replaceAll('请先 Login', '请先登录')
    .replaceAll('move 字段不完整', '走法数据不完整')
    .replaceAll('未轮到本方走子', '还没轮到你走棋')
    .replaceAll('不是你的回合', '还没轮到你')
    .replaceAll('游戏未在进行中', '对局未开始')
    .replaceAll('AI 对战观战模式', 'AI 自动对弈')
    .replaceAll('AI 对战不支持提和', 'AI 对局不支持提和')
}

export const useGameStore = defineStore('game', {
  state: () => ({
    serverUrl: defaultServerUrl(),
    userId: '' as string,
    loggedIn: false as boolean,
    matching: false as boolean,
    ready: false as boolean,
    opponentReady: false as boolean,
    room: null as RoomInfo | null,
    pendingRoomMode: 'human' as 'human' | 'humanAi' | 'aiBattle',
    gameStart: null as GameStartInfo | null,
    currentTurn: null as Color | null,
    lastError: '' as string,
    gameOver: null as { winner: string; reason: string; winnerId?: string } | null,
    connectionStatus: 'closed' as ConnectionStatus,
    drawOfferFrom: '' as string,
    myDrawOffered: false as boolean,
    drawDeclinedBy: '' as string,
    chatMessages: [] as ChatMessage[],

    // 棋盘状态
    board: [] as Piece[],
    selectedCoord: '' as string, // 'a0' 之类，空字符串=未选
    hintCoords: [] as string[],   // 选中棋子时高亮的可走目标
    lastMove: null as { from: string; to: string } | null,
    battleEffect: null as null | { kind: 'move' | 'capture' | 'check'; seq: number },
    battleEffectSeq: 0 as number,

    // 将军状态
    inCheck: null as Color | null,  // 谁正被将军
    // 终局判定（前端规则推断，仅用于提示，不直接结束对局）
    endgameVerdict: null as null | { kind: 'checkmate' | 'stalemate'; loserColor: Color },

    // Rematch（再来一局）状态
    myRematchAsked: false as boolean,   // 本方已请求 rematch
    rematchOfferFrom: '' as string,     // 收到对方邀请（对方 userId）
    rematchDeclinedBy: '' as string,    // 对方拒绝了我方邀请（对方 userId）

    // 倒计时
    turnStartedAt: 0 as number,     // 当前回合开始时刻（毫秒）
    stepTimeLimitMs: 65000 as number, // 步时上限（与服务端一致）
    nowMs: 0 as number,             // setInterval 推动的当前毫秒（用于响应式计算剩余）

    // AI 对弈暂停（仅 AI 模式下可见）
    paused: false as boolean,

    // ── 复盘模式 ─────────────────────────────────────────────
    boardStates: [] as BoardState[],
    currentStateId: '' as string,
    isReplayMode: false as boolean,
    replayClockValue: 0 as number, // 冻结时的 remainSeconds
    replayCurrentTurn: null as Color | null, // 分支中当前应走子方
    branchKingCaptured: false as boolean,    // 分支中将帅被吃，禁止继续走子
  }),

  getters: {
    selectedPiece(state): Piece | null {
      if (!state.selectedCoord) return null
      const col = COLS.indexOf(state.selectedCoord[0])
      const row = Number(state.selectedCoord.slice(1))
      return state.board.find(p => p.row === row && p.col === col) || null
    },
    /** 当前回合剩余秒数（轮到自己/对手都按服务端步时倒数）；游戏未开始返回 -1 */
    remainSeconds(state): number {
      if (state.isReplayMode) return state.replayClockValue
      if (!state.gameStart || !state.turnStartedAt) return -1
      const elapsed = Math.max(0, state.nowMs - state.turnStartedAt)
      const remain = Math.max(0, state.stepTimeLimitMs - elapsed)
      return Math.floor(remain / 1000)
    },
    connectionStatusText(state): string {
      return connectionStatusText(state.connectionStatus)
    },
    gameOverReasonText(state): string {
      return gameOverReasonText(state.gameOver?.reason)
    },
    /** 当前复盘状态下是否可以回退 */
    canGoPrev(state): boolean {
      if (!state.isReplayMode) return false
      const cur = state.boardStates.find(s => s.id === state.currentStateId)
      return cur != null && cur.parent != null
    },
    /** 当前复盘状态下是否可以前进 */
    canGoNext(state): boolean {
      if (!state.isReplayMode) return false
      const cur = state.boardStates.find(s => s.id === state.currentStateId)
      return cur != null && cur.mainNext != null
    },
    /** 当前 BoardState 节点 */
    currentBoardState(state): BoardState | undefined {
      return state.boardStates.find(s => s.id === state.currentStateId)
    },
  },

  actions: {
    bind() {
      ws.onStatus((s) => { this.connectionStatus = s })
      ws.onMessage((msg) => this.handleMessage(msg))
    },
    async connect(url: string) {
      this.serverUrl = url
      await ws.connect(url)
    },
    login(userId: string, password: string) {
      this.userId = userId
      ws.send({ messageType: 'Login', userId, password })
    },
    startMatch() {
      this.matching = true
      this.pendingRoomMode = 'human'
      this.lastError = ''
      ws.send({ messageType: 'startMatch' })
    },
    startAiGame() {
      this.matching = false
      this.ready = false
      this.opponentReady = true
      this.pendingRoomMode = 'humanAi'
      this.lastError = ''
      ws.send({ messageType: 'startAiGame' })
    },
    startAiBattle() {
      this.matching = false
      this.ready = true
      this.opponentReady = true
      this.pendingRoomMode = 'aiBattle'
      this.lastError = ''
      ws.send({ messageType: 'startAiBattle' })
    },
    createRoom() {
      this.matching = false
      this.ready = false
      this.opponentReady = false
      this.pendingRoomMode = 'human'
      this.lastError = ''
      ws.send({ messageType: 'createRoom' })
    },
    joinRoom(roomId: string) {
      const code = roomId.trim()
      if (!/^\d{6}$/.test(code)) {
        this.lastError = '请输入 6 位房间号'
        return
      }
      this.matching = false
      this.ready = false
      this.opponentReady = false
      this.pendingRoomMode = 'human'
      this.lastError = ''
      ws.send({ messageType: 'joinRoom', roomId: code })
    },
    setReady() {
      this.ready = true
      ws.send({ messageType: 'Ready' })
    },
    resign() {
      ws.send({ messageType: 'Resign' })
    },
    offerDraw() {
      if (this.gameOver) return
      if (this.drawOfferFrom) {
        this.lastError = '对方已请求提和，请先同意或拒绝'
        return
      }
      this.myDrawOffered = true
      this.drawDeclinedBy = ''
      this.lastError = ''
      ws.send({ messageType: 'drawOffer' })
    },
    acceptDraw() {
      this.drawOfferFrom = ''
      this.myDrawOffered = false
      ws.send({ messageType: 'drawAccept' })
    },
    declineDraw() {
      this.drawOfferFrom = ''
      ws.send({ messageType: 'drawDecline' })
    },
    sendChat(content: string) {
      if (this.room?.mode !== 'human') {
        this.lastError = '仅真人对局支持聊天'
        return
      }
      const text = content.replace(/\s+/g, ' ').trim()
      if (!text) {
        this.lastError = '聊天内容不能为空'
        return
      }
      ws.send({ messageType: 'chat', content: text.slice(0, 120) })
    },
    ping() {
      ws.send({ messageType: 'ping', timestamp: Date.now() })
    },

    // ── Rematch ─────────────────────────────────────────
    /** 邀请/同意"再来一局"。第一次发表示发起，第二次发（对方已邀请）表示同意。 */
    requestRematch() {
      this.myRematchAsked = true
      this.rematchDeclinedBy = ''
      ws.send({ messageType: 'rematchRequest' })
    },
    /** 拒绝对方的"再来一局"邀请。 */
    declineRematch() {
      this.rematchOfferFrom = ''
      ws.send({ messageType: 'rematchDecline' })
    },

    /** 主动通知服务端离开房间（清理 AI 房间 / 真人房间认输等）。 */
    leaveRoom() {
      if (this.room) {
        ws.send({ messageType: 'leaveRoom' })
      }
    },

    /** 暂停 AI 对弈。不在本地乐观切换，等服务端 gamePaused 确认。 */
    pauseAi() {
      ws.send({ messageType: 'pauseGame' })
    },

    /** 恢复 AI 对弈。等服务端 gameResumed 确认。 */
    resumeAi() {
      ws.send({ messageType: 'resumeGame' })
    },

    // ── 走子相关 ─────────────────────────────────────────
    selectCell(row: number, col: number) {
      // 复盘模式：走自由走子逻辑
      if (this.isReplayMode) {
        this.handleReplayCellClick(row, col)
        return
      }

      const coord = `${COLS[col]}${row}`
      const piece = this.board.find(p => p.row === row && p.col === col)
      const yourColor = this.gameStart?.yourColor
      if (this.room?.mode === 'aiBattle') {
        this.selectedCoord = coord
        this.hintCoords = []
        this.lastError = ''
        return
      }

      // 调试信息（浏览器 Console 可见）
      console.log('[selectCell]', {
        click: coord, row, col,
        pieceColor: piece?.color, pieceType: piece?.type, revealed: piece?.revealed,
        yourColor, currentTurn: this.currentTurn,
        currentSelected: this.selectedCoord,
      })

      // 当前没有选中：自己的子进入走子选择；对方棋子只做查看式选中，不提示可走点。
      if (!this.selectedCoord) {
        if (!piece) {
          // 点空格不报错，静默忽略
          return
        }
        if (this.currentTurn !== yourColor) {
          this.lastError = '还没轮到你'
          return
        }
        if (piece.color !== yourColor) {
          // 查看式选中对方子，不报错
          this.selectedCoord = coord
          this.hintCoords = []
          this.lastError = ''
          return
        }
        this.selectedCoord = coord
        this.lastError = ''
        this.computeHints(piece)
        return
      }

      // 已经选中一个子：
      // 1. 再次点击同一格 → 取消选中；标准揭棋不允许原地翻子
      if (this.selectedCoord === coord) {
        this.selectedCoord = ''
        this.hintCoords = []
        return
      }

      // 2. 点击其他自己的子 → 改选这个
      if (piece && piece.color === yourColor) {
        this.selectedCoord = coord
        this.computeHints(piece)
        return
      }

      // 3. 点击空格或敌子 → 发走子
      const fromCol = COLS.indexOf(this.selectedCoord[0])
      const fromRow = Number(this.selectedCoord.slice(1))
      const selected = this.selectedPiece
      const shouldFlipAfterMove = selected ? !selected.revealed : false

      if (!selected || selected.color !== yourColor) {
        this.lastError = '不能移动对方棋子'
        this.selectedCoord = ''
        this.hintCoords = []
        return
      }

      // 明暗子统一前端规则预校验：
      // 揭棋规则下，暗子按 virtualType（=所在位置的初始类型）走，
      // 前端 piece.type 对暗子已是 virtualType，因此可一致用 hintCoords 校验。
      if (selected) {
        const targetCoord = `${COLS[col]}${row}`
        if (!this.hintCoords.includes(targetCoord)) {
          // 送将单独保留精确提示；其他一律归一为"走法无效"
          const detail = getMoveErrorMessage(this.board, selected, row, col)
          this.lastError = detail === '不能送将' ? '不能送将' : '走法无效'
          return
        }
      }

      this.sendMove(fromCol, fromRow, col, row, shouldFlipAfterMove)
      this.selectedCoord = ''
      this.hintCoords = []
    },

    /** 计算选中棋子的可走目标，更新 hintCoords */
    computeHints(piece: Piece) {
      const moves = getValidMoves(this.board, piece)
      this.hintCoords = moves.map(m => `${COLS[m.col]}${m.row}`)
    },

    /** 重置回合计时器（轮换或新对局时调用） */
    resetTurnClock() {
      if (this.isReplayMode) return
      this.turnStartedAt = Date.now()
      this.nowMs = Date.now()
    },

    /** 由 setInterval 推动 nowMs，触发倒计时响应式更新 */
    tickClock() {
      if (this.isReplayMode) return
      this.nowMs = Date.now()
    },

    sendMove(fromCol: number, fromRow: number, toCol: number, toRow: number, isFlip: boolean) {
      this.lastError = ''
      ws.send({
        messageType: 'move',
        fromX: COLS[fromCol],
        fromY: rowToProtocolY(fromRow),
        toX: COLS[toCol],
        toY: rowToProtocolY(toRow),
        isFlip,
      })
    },

    clearSelection() {
      this.selectedCoord = ''
      this.hintCoords = []
    },

    reset() {
      this.matching = false
      this.ready = false
      this.opponentReady = false
      this.room = null
      this.pendingRoomMode = 'human'
      this.gameStart = null
      this.gameOver = null
      this.drawOfferFrom = ''
      this.myDrawOffered = false
      this.drawDeclinedBy = ''
      this.chatMessages = []
      this.board = []
      this.selectedCoord = ''
      this.hintCoords = []
      this.lastMove = null
      this.battleEffect = null
      this.battleEffectSeq = 0
      this.currentTurn = null
      this.inCheck = null
      this.endgameVerdict = null
      this.myRematchAsked = false
      this.rematchOfferFrom = ''
      this.rematchDeclinedBy = ''
      this.paused = false
      this.boardStates = []
      this.currentStateId = ''
      this.isReplayMode = false
      this.replayClockValue = 0
      this.replayCurrentTurn = null
      this.branchKingCaptured = false
    },

    // ── 棋盘快照工具 ─────────────────────────────────────
    /** 深拷贝棋盘数组 */
    deepCopyBoard(board: Piece[]): Piece[] {
      return board.map(p => ({ ...p }))
    },

    /** 记录当前棋盘快照为新的 BoardState */
    recordBoardSnapshot(moveRecord?: MoveRecord) {
      const parentId = this.currentStateId || null
      const id = nextStateId()
      const snapshot: BoardState = {
        id,
        board: this.deepCopyBoard(this.board),
        parent: parentId,
        mainNext: null,
        branches: [],
        moveRecord,
      }
      // 链接父节点的 mainNext
      if (parentId) {
        const parent = this.boardStates.find(s => s.id === parentId)
        if (parent) {
          parent.mainNext = id
        }
      }
      this.boardStates.push(snapshot)
      this.currentStateId = id
    },

    // ── 复盘导航 ─────────────────────────────────────────

    /** 进入复盘模式（对局结束后可用） */
    enterReplay() {
      if (this.boardStates.length === 0) return
      this.isReplayMode = true
      this.replayClockValue = this.remainSeconds
      this.branchKingCaptured = false
      // 跳转到主链最新末端
      const latest = this.findLatestMainState()
      if (latest) {
        this.currentStateId = latest.id
        this.board = this.deepCopyBoard(latest.board)
      } else {
        this.currentStateId = this.boardStates[this.boardStates.length - 1].id
      }
      // 初始化走子方：与当前对局回合一致
      this.replayCurrentTurn = this.currentTurn
    },

    /** 退出复盘模式，回到最新状态并恢复计时 */
    exitReplay() {
      this.isReplayMode = false
      this.branchKingCaptured = false
      this.replayCurrentTurn = null
      // 恢复到主链最新状态
      const latestMain = this.findLatestMainState()
      if (latestMain) {
        this.currentStateId = latestMain.id
        this.board = this.deepCopyBoard(latestMain.board)
      }
      this.selectedCoord = ''
      this.hintCoords = []
    },

    /** 沿主链找到最后一个状态 */
    findLatestMainState(): BoardState | undefined {
      if (this.boardStates.length === 0) return undefined
      // 从第一个状态出发沿 mainNext 走到尽头
      let cur = this.boardStates.find(s => s.parent === null)
      if (!cur) cur = this.boardStates[0]
      while (cur.mainNext) {
        const next = this.boardStates.find(s => s.id === cur!.mainNext)
        if (!next) break
        cur = next
      }
      return cur
    },

    /** 上一步：回到父状态 */
    goPrev() {
      if (!this.canGoPrev) return
      const cur = this.boardStates.find(s => s.id === this.currentStateId)
      if (!cur || !cur.parent) return
      const parent = this.boardStates.find(s => s.id === cur.parent)
      if (!parent) return
      this.currentStateId = parent.id
      this.board = this.deepCopyBoard(parent.board)
      this.selectedCoord = ''
      this.hintCoords = []
      this.lastMove = null
      // 回到主链父状态时清除分支结束标志
      this.branchKingCaptured = false
      // 回退一步 = 撤销一步棋 = 轮换走子方
      this.replayCurrentTurn = this.replayCurrentTurn === 'red' ? 'black' : 'red'
    },

    /** 下一步：沿主链前进 */
    goNext() {
      if (!this.canGoNext) return
      const cur = this.boardStates.find(s => s.id === this.currentStateId)
      if (!cur || !cur.mainNext) return
      const next = this.boardStates.find(s => s.id === cur.mainNext)
      if (!next) return
      this.currentStateId = next.id
      this.board = this.deepCopyBoard(next.board)
      this.selectedCoord = ''
      this.hintCoords = []
      this.lastMove = null
      // 主链上前进，清除分支状态
      this.branchKingCaptured = false
      // 前进一步 = 应用一步棋 = 轮换走子方
      this.replayCurrentTurn = this.replayCurrentTurn === 'red' ? 'black' : 'red'
    },

    /** 复盘中的自由走子处理（轮流走子 + 将帅被吃后锁死） */
    handleReplayCellClick(row: number, col: number) {
      // 将帅已被吃，分支结束，只允许回退或退出
      if (this.branchKingCaptured) {
        this.lastError = '将帅已被吃，分支结束。请回退或退出复盘。'
        return
      }

      const coord = `${COLS[col]}${row}`
      const clicked = pieceAt(this.board, row, col)

      // 没有选中：只能选当前走子方的棋子
      if (!this.selectedCoord) {
        if (!clicked) return
        if (clicked.color !== this.replayCurrentTurn) {
          this.lastError = clicked.color === 'red' ? '当前轮到黑方走子' : '当前轮到红方走子'
          return
        }
        this.selectedCoord = coord
        const moves = getValidMoves(this.board, clicked)
        this.hintCoords = moves.map(m => `${COLS[m.col]}${m.row}`)
        return
      }

      // 已选中：再次点击同格 → 取消
      if (this.selectedCoord === coord) {
        this.selectedCoord = ''
        this.hintCoords = []
        return
      }

      // 点击己方其他棋子 → 改选（同一走子方）
      if (clicked && clicked.color === this.replayCurrentTurn) {
        this.selectedCoord = coord
        const moves = getValidMoves(this.board, clicked)
        this.hintCoords = moves.map(m => `${COLS[m.col]}${m.row}`)
        return
      }

      // 点击空格或对方棋子 → 执行自由走子
      const fromCol = COLS.indexOf(this.selectedCoord[0])
      const fromRow = Number(this.selectedCoord.slice(1))
      const selected = pieceAt(this.board, fromRow, fromCol)

      if (!selected) {
        this.selectedCoord = ''
        this.hintCoords = []
        return
      }

      // 合法性检查
      const targetCoord = `${COLS[col]}${row}`
      if (!this.hintCoords.includes(targetCoord)) {
        const err = getMoveErrorMessage(this.board, selected, row, col)
        if (err) {
          this.lastError = err
          return
        }
      }

      // 执行复盘自由走子
      this.executeReplayMove(selected, fromRow, fromCol, row, col)
      this.selectedCoord = ''
      this.hintCoords = []
    },

    /**
     * 在复盘模式下执行自由走子，创建分支状态。
     *
     * 规则：轮流走子、暗子移动后揭开（身份由服务端 initialBoard 下发，piece.type 已含真实身份）、
     * 将帅被吃后分支锁死。
     */
    executeReplayMove(piece: Piece, fromRow: number, fromCol: number, toRow: number, toCol: number) {
      const newBoard = this.deepCopyBoard(this.board)
      const movedPiece = newBoard.find(p => p.row === fromRow && p.col === fromCol)
      if (!movedPiece) return

      const wasRevealed = movedPiece.revealed
      const wasType = movedPiece.type
      const beforeStatus: PieceStatus = movedPiece.revealed ? 'FaceUp' : 'FaceDown'

      // 吃子
      const targetIdx = newBoard.findIndex(p => p.row === toRow && p.col === toCol)
      const captured = targetIdx >= 0 ? newBoard.splice(targetIdx, 1)[0] : null

      // 移动
      movedPiece.row = toRow
      movedPiece.col = toCol

      // 未揭开棋子移动后自动揭开（身份由服务端 initialBoard 下发，piece.type 已含真实身份）
      if (!movedPiece.revealed) {
        movedPiece.revealed = true
      }

      // 检查是否吃掉了将帅
      let kingDied = false
      if (captured && captured.type === 'king' && captured.revealed) {
        kingDied = true
      }

      const afterStatus: PieceStatus = movedPiece.revealed ? 'FaceUp' : 'FaceDown'

      // 构建 MoveRecord
      const moveRecord: MoveRecord = {
        player: this.replayCurrentTurn === 'red' ? 'P1' : 'P2',
        before: {
          pieceId: pieceId({ color: piece.color, type: wasType, revealed: wasRevealed, row: fromRow, col: fromCol }),
          position: { row: fromRow, col: fromCol },
          status: beforeStatus,
        },
        after: {
          pieceId: pieceId(movedPiece),
          position: { row: toRow, col: toCol },
          status: afterStatus,
        },
        timestamp: Date.now(),
      }

      // 创建分支状态
      const curState = this.boardStates.find(s => s.id === this.currentStateId)
      const branchId = nextStateId()
      const branchState: BoardState = {
        id: branchId,
        board: newBoard,
        parent: this.currentStateId,
        mainNext: null,
        branches: [],
        moveRecord,
      }
      this.boardStates.push(branchState)

      // 将分支添加到父节点的 branches 中
      if (curState) {
        curState.branches.push(branchId)
      }

      // 切换到新状态
      this.currentStateId = branchId
      this.board = newBoard
      this.lastMove = { from: `${'abcdefghi'[fromCol]}${fromRow}`, to: `${'abcdefghi'[toCol]}${toRow}` }
      this.lastError = ''

      // 轮流走子
      this.replayCurrentTurn = this.replayCurrentTurn === 'red' ? 'black' : 'red'

      // 将帅被吃 → 分支锁死
      if (kingDied) {
        this.branchKingCaptured = true
        this.lastError = '将帅已被吃，分支结束。请使用 ← 回退或退出复盘。'
      }
    },


    returnToLobby() {
      // 先告诉服务端我要离开，避免下次匹配被 [3002] 已在房间中 拦截
      this.leaveRoom()
      this.reset()
      this.lastError = ''
    },

    // ── 消息处理 ─────────────────────────────────────────
    handleMessage(msg: WsMessage) {
      switch (msg.messageType) {
        case 'loginResult':
          this.loggedIn = msg.success === true
          if (!msg.success) this.lastError = normalizeServerMessage(msg.message) || '登录失败'
          break

        case 'matchSuccess':
          this.matching = false
          this.room = {
            roomId: msg.roomId,
            opponentId: msg.opponentId,
            opponentNickname: msg.opponentNickname || msg.opponentId,
            mode: this.pendingRoomMode,
          }
          this.matching = false
          if (this.room?.mode === 'aiBattle') {
            this.ready = true
            this.opponentReady = true
          }
          // 人机对战：无需用户手动准备，匹配成功后自动 Ready 让服务端立刻开局
          if (this.room?.mode === 'humanAi') {
            this.setReady()
          }
          this.lastError = ''
          break

        case 'roomInfo':
          this.opponentReady = msg.opponentReady === true
          break

        case 'gameStart':
          this.gameStart = {
            redPlayerId: msg.redPlayerId,
            blackPlayerId: msg.blackPlayerId,
            yourColor: msg.yourColor as Color,
            firstHand: msg.firstHand === true,
          }
          this.currentTurn = 'red'
          // 初始棋盘：优先用服务端推的，没有就用默认布局
          this.board = msg.initialBoard && Array.isArray(msg.initialBoard) && msg.initialBoard.length > 0
            ? parseInitialBoard(msg.initialBoard)
            : initialJieqiBoard()
          this.selectedCoord = ''
          this.hintCoords = []
          this.lastMove = null
          this.battleEffect = null
          this.battleEffectSeq = 0
          this.inCheck = null
          this.endgameVerdict = null
          this.gameOver = null
          this.drawOfferFrom = ''
          this.myDrawOffered = false
          this.drawDeclinedBy = ''
          this.chatMessages = []
          this.myRematchAsked = false
          this.rematchOfferFrom = ''
          this.rematchDeclinedBy = ''
          this.resetTurnClock()
          // 记录初始棋盘快照
          this.boardStates = []
          this.currentStateId = ''
          this.isReplayMode = false
          this.replayClockValue = 0
          this.replayCurrentTurn = null
          this.branchKingCaptured = false
          this.recordBoardSnapshot()
          break

        case 'moveResult':
          console.log('[moveResult]', msg)
          if (msg.valid === false || msg.success === false) {
            this.lastError = normalizeServerMessage(msg.message) || '走法无效'
            this.selectedCoord = ''
            break
          }
          if (msg.move) this.applyMove(msg.move, msg.flipResult)
          this.lastError = ''
          break

        case 'flipResult': {
          // 兼容单独 flipResult 消息：{ x, y, type } 或 { x, y, piece }
          const col = colToIdx(msg.x ?? msg.toX ?? msg.fromX)
          const y = msg.y ?? msg.toY ?? msg.fromY
          const row = protocolYToRow(y)
          const t = mapType(msg.type ?? msg.piece ?? msg.flipResult)
          const target = this.board.find(p => p.row === row && p.col === col)
          if (target && t) {
            target.type = t
            target.revealed = true
          }
          break
        }

        case 'chatMessage': {
          const content = String(msg.content || '').trim()
          if (!content) break
          this.chatMessages.push({
            id: `${msg.timestamp || Date.now()}-${this.chatMessages.length}`,
            fromUserId: msg.fromUserId || '对手',
            fromColor: mapColor(msg.fromColor) || 'red',
            content,
            timestamp: Number(msg.timestamp || Date.now()),
            mine: msg.fromUserId === this.userId,
          })
          if (this.chatMessages.length > 60) {
            this.chatMessages = this.chatMessages.slice(-60)
          }
          break
        }

        case 'timeout':
          this.lastError = `超时：${msg.loserId || '当前玩家'} 判负`
          break

        case 'gameOver':
          this.gameOver = { winner: msg.winner, reason: msg.reason, winnerId: msg.winnerId }
          this.selectedCoord = ''
          this.hintCoords = []
          this.drawOfferFrom = ''
          this.myDrawOffered = false
          this.drawDeclinedBy = ''
          // 新局 rematch 状态清空（旧局结束）
          this.myRematchAsked = false
          this.rematchOfferFrom = ''
          this.rematchDeclinedBy = ''
          break

        case 'drawOffered':
          if (msg.fromUserId === this.userId) {
            this.myDrawOffered = true
            this.drawOfferFrom = ''
          } else {
            this.drawOfferFrom = msg.fromUserId || '对手'
            this.myDrawOffered = false
          }
          this.drawDeclinedBy = ''
          break

        case 'drawDeclined':
          this.myDrawOffered = false
          this.drawDeclinedBy = msg.fromUserId || '对手'
          this.lastError = '对方拒绝提和'
          break

        case 'rematchOffer':
          this.rematchOfferFrom = msg.fromUserId || '对手'
          break

        case 'rematchDeclined':
          this.rematchDeclinedBy = msg.fromUserId || '对手'
          this.myRematchAsked = false
          break

        case 'gamePaused':
          this.paused = true
          break

        case 'gameResumed':
          this.paused = false
          break

        case 'error':
          this.lastError = normalizeServerMessage(msg.message)
          this.matching = false
          this.selectedCoord = ''
          break
      }
    },

    applyMove(move: any, flipResult?: string) {
      // 老师 JSON 协议的 y 与前端内部 row 都采用棋盘显示行号：0=红方底线，9=黑方底线。
      const fromCol = colToIdx(move.fromX)
      const fromRow = protocolYToRow(move.fromY)
      const toCol = colToIdx(move.toX)
      const toRow = protocolYToRow(move.toY)
      if (fromCol < 0 || toCol < 0 || Number.isNaN(fromRow) || Number.isNaN(toRow)) {
        this.lastError = '服务端走法数据异常'
        return
      }

      const piece = this.board.find(p => p.row === fromRow && p.col === fromCol)
      if (!piece) {
        this.lastError = `本地棋盘不同步：${coordText(fromCol, fromRow)} 没有棋子`
        return
      }
      const revealedType = mapType(move.type ?? move.piece ?? flipResult)
      let captured = false

      // 兼容旧服务端/旧记录：当前标准规则已禁止原地翻子，正常对局不会进入此分支。
      if (fromCol === toCol && fromRow === toRow) {
        piece.revealed = true
        if (revealedType) piece.type = revealedType
        this.lastMove = { from: coordText(fromCol, fromRow), to: coordText(toCol, toRow) }
      } else {
        // 移动：吃掉目标位置上的子（如果有）
        const target = this.board.find(p => p.row === toRow && p.col === toCol)
        if (target) {
          captured = true
          this.board = this.board.filter(p => p !== target)
        }
        piece.row = toRow
        piece.col = toCol
        // 暗子被移动后会被翻开（由 flipResult 进一步处理 type）
        if (revealedType) {
          piece.type = revealedType
          piece.revealed = true
        }
        this.lastMove = { from: coordText(fromCol, fromRow), to: coordText(toCol, toRow) }
      }

      // 切换回合 + 重置计时器
      this.currentTurn = this.currentTurn === 'red' ? 'black' : 'red'
      this.resetTurnClock()

      // 走完后，新回合方（被走方）的状态：将军 / 将死 / 困毙
      const sideToMove: Color = this.currentTurn
      const inCheckNow = isInCheck(this.board, sideToMove)
      this.inCheck = inCheckNow ? sideToMove : null
      if (inCheckNow) {
        this.battleEffect = { kind: 'check', seq: ++this.battleEffectSeq }
      } else if (captured) {
        this.battleEffect = { kind: 'capture', seq: ++this.battleEffectSeq }
      } else if (!(fromCol === toCol && fromRow === toRow)) {
        this.battleEffect = { kind: 'move', seq: ++this.battleEffectSeq }
      }

      // 终局判定（只看新回合方有没有合法走法）
      if (isCheckmate(this.board, sideToMove)) {
        this.endgameVerdict = { kind: 'checkmate', loserColor: sideToMove }
      } else if (isStalemate(this.board, sideToMove)) {
        this.endgameVerdict = { kind: 'stalemate', loserColor: sideToMove }
      } else {
        this.endgameVerdict = null
      }

      // 记录棋盘快照
      this.recordBoardSnapshot()
    },
  },
})

// 解析服务端推送的 initialBoard 数组
//
// 老师 JSON 协议：
//   { x: 'a'-'i', y: 0-9, piece: 'king'/'rook'/..., visible: bool }
// 这里的 y 与前端内部 row 都采用棋盘显示行号：0=红方底线，9=黑方底线。
// 服务端新版会发 color；兼容旧服务端时才按初始半区推断。
// 注意：棋子可能已经跨河，不能长期依赖行号推断颜色。
function parseInitialBoard(cells: any[]): Piece[] {
  const result: Piece[] = []
  for (const cell of cells) {
    if (!cell || typeof cell !== 'object') continue
    const col = colToIdx(cell.x ?? cell.col)
    const y = Number(cell.y ?? cell.row)
    if (col < 0 || isNaN(y)) continue
    const row = protocolYToRow(y)
    const color: Color = mapColor(cell.color) || (row < 5 ? 'red' : 'black')
    const t = mapType(cell.piece ?? cell.type) || 'pawn'    // 字段名是 piece 不是 type
    const visible = cell.visible === true || cell.revealed === true
    result.push({ type: t, color, row, col, revealed: visible })
  }
  return result.length > 0 ? result : initialJieqiBoard()
}
