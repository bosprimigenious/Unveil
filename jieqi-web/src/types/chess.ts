// 揭棋棋子类型与初始局面定义

export type Color = 'red' | 'black'

export type PieceType =
  | 'king'    // 帅/将
  | 'advisor' // 仕/士
  | 'bishop'  // 相/象
  | 'rook'    // 俥/車
  | 'knight'  // 傌/馬
  | 'cannon'  // 炮/砲
  | 'pawn'    // 兵/卒

export interface Piece {
  type: PieceType
  color: Color
  revealed: boolean // false = 暗子（背面）
  row: number       // 0~9, 0=红方底线
  col: number       // 0~8, 0=列 a
}

/** 生成棋子唯一标识（color + 初始信息在快照中用于追踪同一枚棋子） */
export function pieceId(p: Piece): string {
  return `${p.color}-${p.type}-${p.row}-${p.col}`
}

/** 棋子状态快照的一部分 */
export type PieceStatus = 'FaceDown' | 'FaceUp' | 'Captured'

/** 每一步的移动记录 */
export interface MoveRecord {
  player: 'P1' | 'P2'
  before: {
    pieceId: string
    position: { row: number; col: number }
    status: PieceStatus
  }
  after: {
    pieceId: string
    position: { row: number; col: number }
    status: PieceStatus
  }
  timestamp: number
}

/** 棋盘完整快照节点（树结构） */
export interface BoardState {
  id: string
  board: Piece[]          // 完整棋盘快照（深拷贝）
  parent: string | null   // 父状态 ID
  mainNext: string | null // 主链下一状态 ID
  branches: string[]       // 复盘时产生的分支状态 ID
  moveRecord?: MoveRecord  // 产生该状态的走法记录
}

/** 生成唯一状态 ID */
let stateSeq = 0
export function nextStateId(): string {
  return `S${++stateSeq}`
}

// 红方明子文字 / 黑方明子文字
export const PIECE_CHAR: Record<Color, Record<PieceType, string>> = {
  red:   { king: '帅', advisor: '仕', bishop: '相', rook: '俥', knight: '傌', cannon: '炮', pawn: '兵' },
  black: { king: '将', advisor: '士', bishop: '象', rook: '車', knight: '馬', cannon: '砲', pawn: '卒' },
}

// 揭棋初始局面：帅/将露明，其余 15+15 子全暗，按原始位置摆放
// （暗子的 type 是它的"潜在身份"——前端只用于走子规则估算；服务端有权威 type）
export function initialJieqiBoard(): Piece[] {
  const pieces: Piece[] = []
  const backRow: PieceType[] = ['rook','knight','bishop','advisor','king','advisor','bishop','knight','rook']

  // 红方底线 row=0
  backRow.forEach((type, col) => {
    pieces.push({
      type, color: 'red', row: 0, col,
      revealed: type === 'king', // 只有帅是露明的
    })
  })
  // 红方炮 row=2，col=1 和 7
  pieces.push({ type: 'cannon', color: 'red', row: 2, col: 1, revealed: false })
  pieces.push({ type: 'cannon', color: 'red', row: 2, col: 7, revealed: false })
  // 红方兵 row=3，col=0,2,4,6,8
  ;[0,2,4,6,8].forEach(col => {
    pieces.push({ type: 'pawn', color: 'red', row: 3, col, revealed: false })
  })

  // 黑方底线 row=9
  backRow.forEach((type, col) => {
    pieces.push({
      type, color: 'black', row: 9, col,
      revealed: type === 'king',
    })
  })
  // 黑方炮 row=7
  pieces.push({ type: 'cannon', color: 'black', row: 7, col: 1, revealed: false })
  pieces.push({ type: 'cannon', color: 'black', row: 7, col: 7, revealed: false })
  // 黑方卒 row=6
  ;[0,2,4,6,8].forEach(col => {
    pieces.push({ type: 'pawn', color: 'black', row: 6, col, revealed: false })
  })

  return pieces
}
